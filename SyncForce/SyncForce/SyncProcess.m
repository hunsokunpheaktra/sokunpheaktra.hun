//
//  SynProcess.m
//  kba
//
//  Created by Sy Pauv on 10/3/11.
//  Copyright 2011 GAEASYS. All rights reserved.
//

#import "SyncProcess.h"
#import "LogManager.h"
#import "DatetimeHelper.h"
#import "IsNullCriteria.h"
#import "GreaterThanCriteria.h"
#import "Item.h"
#import "EntityManager.h"
#import "MediaHelper.h"
#import "PropertyManager.h"
#import "MetadataRequest.h"
#import "EntityStorage.h"
#import "TransactionInfoManager.h"
#import "EntityRequestDeleted.h"
#import "DescribeLayoutRequest.h"
#import "GenerateFileLocal.h"
#import "Reachability.h"
#import "GlobalRequest.h"
#import "AppDelegate.h"
#import "SfMergeRecords.h"
#import "FilterManager.h"

@implementation SyncProcess

@synthesize error;
@synthesize running;
@synthesize waiting;
@synthesize cancelled;
@synthesize syncCon,syncList;
@synthesize internetActive,hostActive;
@synthesize listrecods;


static SyncProcess *_sharedSingleton = nil;

+ (SyncProcess *)getInstance
{
	@synchronized([SyncProcess class])
	{
		if (!_sharedSingleton)
			[[self alloc] init];
        
		return _sharedSingleton;
	}
    
	return nil;
}


+(id)alloc
{
	@synchronized([SyncProcess class])
	{
		NSAssert(_sharedSingleton == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedSingleton = [super alloc];
		return _sharedSingleton;
	}
    
	return nil;
}


- (id)init {
    self = [super init];
    self.error = Nil;
    self.waiting = [[NSMutableArray alloc] initWithCapacity:1];
    self.running = [[NSMutableArray alloc] initWithCapacity:1];
    self.syncCon = nil;
    self.syncList = [[NSMutableArray alloc] init];
    return self;
}



- (void)start:(NSObject<SynchronizeViewInterface> *)psyncCon {
    if ([self isRunning]) return;
    self.syncCon = psyncCon;
    shouldRetrieveContent = 0;
    isContentRetrieved = NO;
    completed = 0;
    percentage = 0;
    retryCount = 0;
    cancelled = [NSNumber numberWithBool:NO];
    taskNum = 0;
    [LogManager purge];
    [LogManager info:NSLocalizedString(@"SYNC_STARTED", @"Synchronization started") task:taskNum entity:nil];
    
    self.error = Nil;
    [self.waiting removeAllObjects];
    [self.running removeAllObjects];
    
    // Incoming Metadata
    for (NSString *entity in syncList) {
        NSObject<SFRequest> *request = [[MetadataRequest alloc] initWithEntity:entity listener:self];
        [self.waiting addObject:request];
    }
    
    //Incoming Layout
    for (NSString *entity in syncList) {
        NSObject<SFRequest> *request = [[DescribeLayoutRequest alloc] initWithEntity:entity listener:self];
        [self.waiting addObject:request];
    }
        
    // Create data Storage
    NSObject<SFRequest> *request = [[EntityStorage alloc] init:self];
    [self.waiting addObject:request];
    
    
    // Check records to merge
    for (NSString *entity in syncList) {//for (int i = 0; i < [[SyncProcess getInstance].syncList count] ; i++ ) {
        if ([[PropertyManager read:@"ForceSync"] isEqualToString :@"no"] ){
            SfMergeRecords* recordsSf = [[SfMergeRecords alloc] initWithSynProcess:entity listener:self];
            [self.waiting addObject:recordsSf];
        }
        
    }
    
    // Get Deleted
    for (NSString *entity in syncList) {
        NSObject<SFRequest> *request = [[EntityRequestDeleted alloc] initWithEntity:entity listener:self];
        [self.waiting addObject:request];
    }
    
    // Create request
    // we process one record per call only
    for (NSString *entity in syncList) {
        NSObject<SFRequest> *request = [[EntityRequestCreate alloc] init:entity listener:self];
        [self.waiting addObject:request];
    }
    
    // Update request
    // we process one record per call only
    for (NSString *entity in syncList) {
        NSObject<SFRequest> *request = [[EntityRequestUpdate alloc] init:entity listener:self];
        [self.waiting addObject:request];
    }
    
    // Incoming data
    for (NSString *entity in syncList) {
        NSObject<SFRequest> *request = [[EntityRequest alloc] initWithEntity:entity listener:self];
        [self.waiting addObject:request];
    }
    
    // Document , Attachment, And ContentVersion : Locally creation
    for (NSString *entity in syncList) {
        NSObject<SFRequest> *request = [[GenerateFileLocal alloc] initWithEntity:entity listener:self];
        [self.waiting addObject:request];
    }
    
    [self checkRunning];
}

- (void)onSuccess:(int)objectCount request:(NSObject<SFRequest> *)newRequest again:(_Bool)again{
    if ([cancelled boolValue]) {
        return;
    }
    
    retryCount = 0;
    completed++;
    int startCount = 0;
    
    NSString *logmessage = [NSString stringWithFormat:@"Succeeded : %@", [newRequest getName]];
    if(objectCount > -1){
        logmessage = [NSString stringWithFormat:@"%@ (%d records)", logmessage,objectCount];
    }
    [LogManager log:logmessage type:@"Info" task:completed 
             count:startCount + objectCount 
             withId:nil 
             entity:[newRequest getEntity]];
    
    [TransactionInfoManager save:[NSDictionary dictionaryWithObjectsAndKeys:[newRequest getName],@"TaskName", [DatetimeHelper serverDateTime:[NSDate date]],@"LastSyncDate", nil]];
    
    [self.running removeObject:newRequest];
    
    // if YES waiting.add newRequest
    if(again){
        [self.waiting insertObject:newRequest atIndex:0];
        completed--;
    }
    
    [self checkRunning];
    //[newRequest release];
    
    [self computePercent];
}

- (void)onFailure:(NSString *)errorMessage request:(NSObject<SFRequest> *)newRequest again:(_Bool)again{
    
        if ([cancelled boolValue]) {
            [LogManager error:[NSString stringWithFormat:@"Error code: %@", errorMessage] task:0];
            return;
        }
        
        [LogManager warning:[NSString stringWithFormat:@"Error :\n %@", errorMessage] task:(int)[newRequest getTasknum] withId:[[[newRequest getCurrentitem] fields] objectForKey:@"local_id"] entity:[newRequest getEntity]];
        
        [self.running removeObject:newRequest];
        
        if(again){
            [self.waiting insertObject:newRequest atIndex:0];
            completed--;
        }
        
         NSLog(@"Waiting: %d Running: %d", [self.waiting count], [self.running count]);
        [self checkRunning];
}

- (void)checkRunning {
    BOOL more_again;
    do {
        [self.syncCon refresh];
        NSLog(@"Waiting: %d Running: %d", [self.waiting count], [self.running count]);
        more_again = NO;
        
        @synchronized([SyncProcess class]) {
            if ([self.running count] < PIPELINE_SIZE && [self.waiting count] > 0) {
                EntityRequest *request = Nil;
                for (EntityRequest *tmp in self.waiting) {
                        request = tmp;
                        [request setTask:[NSNumber numberWithInt:taskNum]] ;
                        break;
                   
                }
                if (request != Nil) {
                    if ([request prepare]) {
                        [self.running addObject:request];
                        taskNum++;
                        [LogManager info:[request getName] task:taskNum entity:[request getEntity]];
                        [request doRequest];
                    }
                    [self.waiting removeObject:request];
                    more_again = YES;
                }
            }
        }
        
    } while (more_again);
    if(self.waiting.count == 0 && self.running.count == 0){
        NSString *dateString = [DatetimeHelper serverDateTime:[NSDate date]];
        [PropertyManager save:@"LastSync" value:dateString];
        NSLog(@" saved sync : %@" , dateString);
        
        NSMutableDictionary *criteria = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
        [criteria setValue:[[[ValuesCriteria alloc] initWithString:@"yes"] autorelease] forKey:@"value"];
        
        for(Item *item in [FilterManager list:criteria]){
            [item.fields setValue:dateString forKey:@"lastSyn"];
            [FilterManager update:item modifiedLocally:NO];
        }
        
        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [delegate refreshTabs];        
    }
}


- (BOOL)isBlocking:(NSString *)errorCode {
   
    return false;
}


- (BOOL)shouldRetry:(NSString *)errorCode {
       return false;
}


- (BOOL)isRunning {
    return error == nil && ([self.running count] > 0 || [self.waiting count] > 0) && [cancelled boolValue] == NO;
}

- (void)stop {
    cancelled = [NSNumber numberWithBool:YES];
    [self.syncCon refresh];
    
}
- (double)computePercent{
    double tmp = ((double)completed) / ((double)(completed + [self.waiting count] + [self.running count]));
    if (tmp > percentage) {
        percentage = tmp;
    }
    return percentage;
}

- (NSObject<SynchronizeViewInterface> *) getSyncController{
    return syncCon;
}

+ (NSString *)getLibSuccess:(int)count {
    if (count < 0) {
        if (count == -1) return @"Retry";
        if (count == -2) return @"Skip";
        return @"";
    } else {
        if (count == 0) return @"No item";
        if (count == 1) return @"1 item";
        return [NSString stringWithFormat:@"%d items", count];
    }
    
}

- (void) startNotifier{
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReach = [[Reachability reachabilityForInternetConnection] retain];
    [internetReach startNotifier];
    
    // check if a pathway to a random host exists
    hostReach = [[Reachability reachabilityWithHostName: @"www.apple.com"] retain];
    [hostReach startNotifier];
    
}

- (void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    
    NetworkStatus internetStatus = [internetReach currentReachabilityStatus];
    switch (internetStatus)
    
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            self.internetActive = NO;
            if(self.isRunning) {
                error = NSLocalizedString(@"INTERNET_DOWN", Nil);
                [self.syncCon refresh];
                
            }
            break;
            
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            self.internetActive = YES;
            
            break;
            
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            self.internetActive = YES;
            
            break;
            
        }
    }
    
    NetworkStatus hostStatus = [hostReach currentReachabilityStatus];
    switch (hostStatus)
    
    {
        case NotReachable:
        {
            NSLog(@"A gateway to the host server is down.");
            self.hostActive = NO;
            if(self.isRunning){
                error = NSLocalizedString(@"INTERNET_DOWN", Nil);
                [self.syncCon refresh];
            }
            break;
            
        }
        case ReachableViaWiFi:
        {
            NSLog(@"A gateway to the host server is working via WIFI.");
            self.hostActive = YES;
            
            break;
            
        }
        case ReachableViaWWAN:
        {
            NSLog(@"A gateway to the host server is working via WWAN.");
            self.hostActive = YES;
            
            break;
            
        }
    }
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateInterfaceWithReachability: curReach];
}

- (BOOL) doAlertInternetFailed{
    //Check if internet connection reachable
    if(!self.internetActive){
        NSLog(@"The internet is down.");
        //open alert to confirm 
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"INTERNET_DOWN", Nil)  message:nil
                                                       delegate:self cancelButtonTitle:NSLocalizedString(@"OK", Nil) 
                                              otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        return YES;
    }
    return NO;
}

- (void) updateInterfaceWithReachability: (Reachability*) curReach{
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [hostReach release];
    [internetReach release];
    [syncCon release];
    [syncList release];
    [super dealloc];
}
@end
