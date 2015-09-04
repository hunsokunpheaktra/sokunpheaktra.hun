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
#import "EntityRelationRequest.h"
#import "DescribeLayoutRequest.h"
#import "GenerateFileLocal.h"
#import "Reachability.h"
#import "GlobalRequest.h"
#import "AppDelegate.h"
#import "EntityLevel.h"
#import "FieldInfoManager.h"

@implementation SyncProcess

@synthesize error;
@synthesize running;
@synthesize waiting;
@synthesize cancelled;
@synthesize syncCon,syncList;
@synthesize internetActive,hostActive;
@synthesize listrecods;
@synthesize list_ignore_layout;
@synthesize list_ignore_child_query;
@synthesize list_ignore_sobject;

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

+ (id)alloc
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
    
    
    
    list_ignore_child_query = [[NSArray alloc] initWithObjects: @"RecordType"
                               ,@"Attachment"
                               ,@"Group"
                               ,@"User",nil];
    
    list_ignore_layout = [[NSArray alloc] initWithObjects:@"User"
                          ,@"Group"  
                          ,@"RecordType"
                          ,@"Attachment"
                          ,nil];
    
    list_ignore_sobject = [[NSArray alloc] initWithObjects:@"OpenActivity"
                           ,@"User"
                           ,@"NoteAndAttachment"  
                           ,@"Asset"
                           ,@"Lead"
                           ,@"ActivityHistory"
                           ,@"EmailStatus"
                           ,@"Group"
                           ,@"cron__Batch_Job__c"
                           ,@"Attachment_Thumbnail__c"
                           ,@"ContentVersion"
                           ,@"Idea"
                           ,@"Solution"
                           ,nil];
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
    [LogManager info:@"Synchronization started" task:taskNum entity:nil];
    
    self.error = Nil;
    [self.waiting removeAllObjects];
    [self.running removeAllObjects];
    
    if([DatetimeHelper stringToDateTime:[PropertyManager read:@"LastSync"]] == nil) { 
      
        // Meta
        [self.waiting addObject:[[MetadataRequest alloc] initWithEntity:@"Survey__c" listener:self level:0]];
        [self.waiting addObject:[[MetadataRequest alloc] initWithEntity:@"Event" listener:self level:0]];
        [self.waiting addObject:[[MetadataRequest alloc] initWithEntity:@"RecordType" listener:self level:0]];
        [self.waiting addObject:[[MetadataRequest alloc] initWithEntity:@"Attachment" listener:self level:0]];
        
        // Layout
        [self.waiting addObject:[[DescribeLayoutRequest alloc] initWithEntity:@"Survey__c" listener:self level:0]];
        [self.waiting addObject:[[DescribeLayoutRequest alloc] initWithEntity:@"Event" listener:self level:0]];
        
        // Sync Data
        [self.waiting addObject:[[EntityRequest alloc] initWithEntity:@"Survey__c" listener:self level:0]];
        [self.waiting addObject:[[EntityRequest alloc] initWithEntity:@"Event" listener:self level:0]];
        [self.waiting addObject:[[EntityRequest alloc] initWithEntity:@"RecordType" listener:self level:0]];
        
    } else {
            
 //       NSObject<SFRequest>* queryUser 

            // Case 1
            
        
            // Case 2
            NSMutableArray* creates = [[NSMutableArray alloc] init];
            NSMutableArray* updates = [[NSMutableArray alloc] init];
            [creates addObject:[[EntityRequestCreate alloc] init:@"Attachment" listener:self]];
            
            for (Item* item in [EntityLevel readEntities]) {
                NSString* entity = [item valueForKey:@"EntityName"];
                [creates addObject:[[EntityRequestCreate alloc] init:entity listener:self]];
                [updates addObject:[[EntityRequestUpdate alloc] init:entity listener:self]];
            }
        
            [self.waiting addObjectsFromArray:creates];
            [self.waiting addObjectsFromArray:updates];
            
            [self.waiting addObject:[[EntityRequest alloc] initWithEntity:@"Survey__c" listener:self level:0]];
            [self.waiting addObject:[[EntityRequest alloc] initWithEntity:@"Event" listener:self level:0]];
            [self.waiting addObject:[[EntityRequest alloc] initWithEntity:@"RecordType" listener:self level:0]];
        
            // Case 3
        
        
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


-(void)addRequests:(NSArray*)list level:(int)level{
    
        NSMutableArray *metas   = [[NSMutableArray alloc] init];
        NSMutableArray *layouts = [[NSMutableArray alloc] init];
        NSMutableArray *entities = [[NSMutableArray alloc] init];
        
        for (NSObject<SFRequest>*request in self.waiting) {
            if ([request isKindOfClass:[MetadataRequest class]]) {
                [metas addObject:request];
            }else if ([request isKindOfClass:[DescribeLayoutRequest class]]) {
                [layouts addObject:request];
            }else if ([request isKindOfClass:[EntityRequest class]]) {
                [entities addObject:request];
            }    
        }

    
        if (level < 4) {
            for (NSString *entity in list) {
                [metas addObject:[[MetadataRequest alloc] initWithEntity:entity listener:self level:level+1]];
                if (![list_ignore_layout containsObject:entity]) {
                    [layouts addObject:[[DescribeLayoutRequest alloc] initWithEntity:entity listener:self level:level+1]];
                }   
            }    
        }
    
        [self.waiting removeAllObjects];
        [self.waiting addObjectsFromArray:metas];
        [self.waiting addObjectsFromArray:layouts];
        [self.waiting addObjectsFromArray:entities];
    
}

- (void) addEntityRelation:(NSString*) child parentEntity:(NSString*)pEntity parentId:(NSString*)pId level:(int)level{
    
    if (level < 4) {
        [self.waiting addObject:[[EntityRelationRequest alloc] initWithEntity:child parentEntity:pEntity parentId:pId listener:self level:level+1]];
    }

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
