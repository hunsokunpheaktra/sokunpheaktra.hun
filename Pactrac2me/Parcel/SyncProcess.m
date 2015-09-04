//
//  SynProcess.m
//  kba
//
//  Created by Sy Pauv on 10/3/11.
//  Copyright 2011 GAEASYS. All rights reserved.
//

#import "SyncProcess.h"
#import "NSObject+SBJson.h"
#import "ParcelEntityManager.h"
#import "ParcelEntityManager.h"
#import "Base64.h"
#import "DownloadFileRequest.h"
#import "SearchFields.h"
#import "AttachmentEntitymanager.h"
#import "NewParcelViewController.h"
#import "ParcelItem.h"
#import "MyParcelViewController.h"

@implementation SyncProcess

@synthesize running;
@synthesize waiting;
@synthesize listrecods,syncCon;

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
    
    return self;
}



- (void) onSuccess:(id)req{
    
    if ([cancelled boolValue]) {
        return;
    }
    
    SalesforceAPIRequest *request = req;
    Item *user = [MainViewController getInstance].user;
    
    if([request isKindOfClass:[LoginRequest class]]){
        
        [self userRequest];
        
    }else if([request isKindOfClass:[QueryRequest class]]){
        
        QueryRequest *queryReq = (QueryRequest*)request;
        if([queryReq.sobject isEqualToString:@"Parcel_User__c"]){
            
            [super onSuccess:req];
            
        }else if([queryReq.sobject isEqualToString:@"Mobile_Device__c"]){
            
            if(request.records.count > 0){
                
                [self start];
                [syncCon doSync];
                
            }else{
                [self registerDeviceToken];
            }
            
        }else if ([queryReq.sobject isEqualToString:@"Parcel__c"]){
            
            NSArray *newListRecords = request.records;
            
            NSMutableArray* sfFieldName = [NSMutableArray arrayWithCapacity:1];
            [sfFieldName addObject:@"Id"];
            [sfFieldName addObject:@"Name"];
            [sfFieldName addObject:@"TrackingNo__c"];
            [sfFieldName addObject:@"Status__c"];
            [sfFieldName addObject:@"Receiver__c"];
            [sfFieldName addObject:@"Forwarder__c"];
            [sfFieldName addObject:@"Reminder_Date__c"];
            [sfFieldName addObject:@"Shipping_Date__c"];
            [sfFieldName addObject:@"Note__c"];
            [sfFieldName addObject:@"UpdateStatus_Date__c"];
            [sfFieldName addObject:@"Location__c"];
            
            NSMutableArray* lcFieldName = [NSMutableArray arrayWithCapacity:1];
            [lcFieldName addObject:@"id"];
            [lcFieldName addObject:@"description"];
            [lcFieldName addObject:@"trackingNo"];
            [lcFieldName addObject:@"status"];
            [lcFieldName addObject:@"receiver"];
            [lcFieldName addObject:@"forwarder"];
            [lcFieldName addObject:@"reminderDate"];
            [lcFieldName addObject:@"shippingDate"];
            [lcFieldName addObject:@"note"];
            [lcFieldName addObject:@"statusDate"];
            [lcFieldName addObject:@"location"];
            
            for(NSMutableDictionary *fields in newListRecords){

                NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:1];
                for (int i =0 ; i < sfFieldName.count ; i++) {
                    if ([fields objectForKey:[sfFieldName objectAtIndex:i]] == [NSNull null]) {
                        [fields setValue:@"" forKey:[sfFieldName objectAtIndex:i]];
                    }
                    NSString *value = [fields objectForKey:[sfFieldName objectAtIndex:i]];
                    value = value == nil ? @"" : value;
                    [dic setObject:value forKey:[lcFieldName objectAtIndex:i]];
                }
                
                NSString *userId = [user.fields objectForKey:@"id"];
                userId = userId==nil ? @"" : userId;
                userId = [userId isEqualToString:@""] ? [user.fields objectForKey:@"local_id"] : userId;
                 
                [dic setObject:userId forKey:@"user_email"];
                [dic setObject:@"0" forKey:@"error"];
                [dic setObject:@"0" forKey:@"deleted"];
                [dic setObject:@"0" forKey:@"modified"];
                
                NSArray* searchField = [[SearchFields read] retain];
                NSString* searchString = @"";
                for (NSString* st in searchField) {
                    if ([st isEqualToString:@"user_email"])
                        searchString  = [searchString stringByAppendingString:[[user.fields valueForKey:@"email"] lowercaseString]];
                    else {
                        searchString  = [searchString stringByAppendingString:[[dic valueForKey:st] lowercaseString]];
                        searchString  = [searchString stringByAppendingString:@" "];
                    }
                    
                }
                
                [dic setValue:searchString forKey:@"search"];
                [searchField release];
                
                
                LogItem *log = [[LogItem alloc] init];
                log.message = [NSString stringWithFormat:@"Succeeded in Retrieving Parcel : %@",[fields objectForKey:@"Name"]];
                log.date = [NSDate date];
                log.type = @"Success";
                [self.syncCon.listLogs addObject:log];
                [log release];
                 
                 Item *item = [[Item alloc] initCustom:@"Parcel" fields:dic];
                 BOOL isLocal = [ParcelEntityManager find:@"Parcel" column:@"Id" value:[fields objectForKey:@"Id"]] != nil;
                 if(isLocal) [ParcelEntityManager update:item modifiedLocally:false];
                 else [ParcelEntityManager insert:item modifiedLocally:false];
                 
                 [dic release];
                 
                 // Attachment from record
                 if ([fields objectForKey:@"Attachments"] !=nil && ![[fields objectForKey:@"Attachments"] isKindOfClass:[NSNull class]])  {
                     NSDictionary *attachment= (NSDictionary *)[fields objectForKey:@"Attachments"];
                     for (NSDictionary *dic in [attachment objectForKey:@"records"]) {
                         
                         NSMutableDictionary* criteria = [[[NSMutableDictionary alloc] init] autorelease];
                         [criteria setValue:[[[ValuesCriteria alloc] initWithString:[dic objectForKey:@"ParentId"]] autorelease] forKey:@"ParentId"];
                          [criteria setValue:[[[ValuesCriteria alloc] initWithString:[dic objectForKey:@"Description"]] autorelease] forKey:@"Description"];
                         [criteria setValue:[[[ValuesCriteria alloc] initWithString:@"0"] autorelease] forKey:@"deleted"];
                         NSArray* list = [NSArray arrayWithArray:[AttachmentEntitymanager list:@"Attachment" criterias:criteria]];
                         if ([list count]>0) {
                             
                             Item *att = [list objectAtIndex:0];
                             [att.fields setObject:[dic objectForKey:@"ParentId"] forKey:@"ParentId"];
                             [att.fields setObject:[dic objectForKey:@"Id"] forKey:@"Id"];
                             [att.fields setObject:@"0" forKey:@"error"];
                             [att.fields setObject:@"0" forKey:@"deleted"];
                             [att.fields setObject:@"0" forKey:@"modified"];
                             [AttachmentEntitymanager update:att modifiedLocally:NO];
                             
                         }else{
                             
                             NSMutableDictionary *data = [NSMutableDictionary dictionary];
                             [data setObject:[dic objectForKey:@"Description"] forKey:@"Description"];
                             [data setObject:[dic objectForKey:@"Id"] forKey:@"Id"];
                             [data setObject:[dic objectForKey:@"ParentId"] forKey:@"ParentId"];
                             [data setObject:@"0" forKey:@"error"];
                             [data setObject:@"0" forKey:@"deleted"];
                             [data setObject:@"0" forKey:@"modified"];
                             Item *att = [[Item alloc]init:@"Attachment" fields:data];
                             GetAttachmentBody *getAttBody = [[GetAttachmentBody alloc]initWithID:att];
                             [self.waiting addObject:getAttBody];
                             [getAttBody release];

                         }
                      }
                 }
             }

        }
        
    }else if([request isKindOfClass:[CreateRecordRequest class]]) {
        
        if([request.item.entity isEqualToString:@"Mobile_Device__c"]){
            
            [self start];
            [syncCon doSync];
            
        }
        
        else if([request.item.entity isEqualToString:@"Parcel"]){
            
            LogItem *log = [[LogItem alloc] init];
            log.message = [NSString stringWithFormat:@"Succeeded in Sending : %@",[request.item.fields objectForKey:@"description"]];
            log.date = [NSDate date];
            log.type = @"Success";
            [self.syncCon.listLogs addObject:log];
            [log release];
            
            [request.item.fields setObject:@"0" forKey:@"modified"];
            [ParcelEntityManager update:request.item modifiedLocally:NO];
            
            //update attachment request when insert parcel complete
            if (request.item.attachments!=nil) {
                for (id req in self.waiting) {
                    if ([req isKindOfClass:[UpsertAttachmentRequest class]]) {
                        Item *it = ((UpsertAttachmentRequest *)req).item;
                        if ([[it.fields objectForKey:@"ParentId"] isEqualToString:[request.item.fields objectForKey:@"local_id"]]) {
                            [it.fields setObject:[request.item.fields objectForKey:@"id"] forKey:@"ParentId"];
                            [AttachmentEntitymanager update:it modifiedLocally:NO];
                        }
                    }
                }
            }
        }
        else {
            [super onSuccess:req];
        }
        
    }else if ([request isKindOfClass:[DeleteRecordRequest class]]) {
        
        LogItem *log = [[LogItem alloc] init];
        log.message = [NSString stringWithFormat:@"Succeeded in Deleting : %@",[request.item.fields objectForKey:@"description"]];
        log.date = [NSDate date];
        log.type = @"Success";
        [self.syncCon.listLogs addObject:log];
        [log release];
        
        [request.item.fields setObject:@"1" forKey:@"deleted"];
        [ParcelEntityManager update:request.item modifiedLocally:NO];

        
        //if request delete parcel completed set deleted status to childs attachment
        for (Item *it in request.item.attachments.allValues) {
            [it.fields setObject:@"1" forKey:@"deleted"];
            [AttachmentEntitymanager update:it modifiedLocally:NO];
        }
        
    }else if([request isKindOfClass:[UpsertAttachmentRequest class]]){
        
        LogItem *log = [[LogItem alloc] init];
        log.message = @"Succeeded in Sending : Attachment";
        log.date = [NSDate date];
        log.type = @"Success";
        [self.syncCon.listLogs addObject:log];
        [log release];
        
    }
    
    if (![req isKindOfClass:[LoginRequest class]]) {
        
        if  (([[request getProccessName] isEqualToString:@"Query"] && ([[((QueryRequest*)request) sobject] isEqualToString:@"Mobile_Device__c"] || [[((QueryRequest*)request) sobject] isEqualToString:@"Parcel_User__c"])) || ([[request getProccessName] isEqualToString:@"Insert"] && ([[((CreateRecordRequest*)request) sobject] isEqualToString:@"Parcel_User__c"] || [[((CreateRecordRequest*)request) sobject] isEqualToString:@"Mobile_Device__c"]))) {
            
        } else {
            
            [self.running removeObject:request];
            completed++;
            
            [self computePercent];
            [self checkRunning];
            
        }
    }

}

- (BOOL)isRunning {
    return error == nil && ([self.running count] > 0 || [self.waiting count] > 0) && [cancelled boolValue] == NO;
}


- (void)onFailure:(NSString *)errorMessage request:(id)req{
    
    
    if([errorMessage isEqualToString:@"INVALID_SESSION_ID"]){
        [super onFailure:errorMessage request:req];
    }
    
    else if ([errorMessage rangeOfString:@"The Internet connection appears to be offline."].location != NSNotFound) {
        SalesforceAPIRequest *request = req;
        [syncCon.hud hide:YES];
        [self.running removeObject:request];
        [self checkRunning];
        [self.syncCon refresh];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:CONNECT_ERROR message:OFFLINE_ERROR_MESSAGE delegate:self cancelButtonTitle:MSG_OK otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    else if ([errorMessage rangeOfString:@"INVALID_PASSWORD"].location != NSNotFound) {
        [syncCon.hud hide:YES];
        cancelled = [NSNumber numberWithBool:NO];
        [self.syncCon connectFail];
        self.error = INVALID_PASSWORD_MESSAGE;
        [self.syncCon refresh];
        [super onFailure:errorMessage request:req];
    }
    else {
        
        SalesforceAPIRequest *request = req;
        Item *item = request.item;
        
        LogItem *log = [[LogItem alloc] init];
        log.message = [NSString stringWithFormat:@"Error Sending : %@",errorMessage];
        log.date = [NSDate date];
        log.type = @"Error";
        
        [self.syncCon.listLogs addObject:log];
        [log release];
        
        [item.fields setObject:@"1" forKey:@"error"];
        [ParcelEntityManager update:item modifiedLocally:NO];
        
        [self.running removeObject:request];
        [self checkRunning];
        
    }
    
    //if insert parcel Failed cancel all childs attachment
    if ([req isKindOfClass:[CreateRecordRequest class]]) {
        for (id request in self.waiting) {
            if ([request isKindOfClass:[UpsertAttachmentRequest class]]) {
                Item *it = ((UpsertAttachmentRequest *)request).item;
                if ([[it.fields objectForKey:@"ParentId"] isEqualToString:[((CreateRecordRequest *)req).item.fields objectForKey:@"local_id"]] || [[it.fields objectForKey:@"ParentId"] isEqualToString:[((CreateRecordRequest *)req).item.fields objectForKey:@"id"]]) {
                    [self.waiting removeObject:request];
                }
            }
        }
    }

}

- (BOOL)isBlocking:(NSString *)errorCode {
    return false;
}

- (BOOL)shouldRetry:(NSString *)errorCode {
    return false;
}


- (void)start{
    
    [self.waiting removeAllObjects];
    [self.running removeAllObjects];
    self.error = nil;
    
    
    if ([[[MainViewController getInstance].user.fields valueForKey:@"modified"] isEqualToString:@"1"]) {
        SalesforceAPIRequest *request = [[CreateRecordRequest alloc] initWithItem:[MainViewController getInstance].user];
        [request doRequest:self];
        [request release];
    }
    
    /* parcel request delete*/
    
    Item *user = [MainViewController getInstance].user;
    
    NSString *userId = [user.fields objectForKey:@"id"];
    userId = userId==nil ? @"" : userId;
    userId = [userId isEqualToString:@""] ? [user.fields objectForKey:@"local_id"] : userId;
    
    NSDictionary* criteria = [NSDictionary dictionaryWithObjectsAndKeys:[[[ValuesCriteria alloc] initWithString:@"2"] autorelease],@"deleted",[[[ValuesCriteria alloc] initWithString:userId] autorelease],@"user_email", nil];
    NSMutableArray* listItems  = [[NSMutableArray alloc] initWithArray:[ParcelEntityManager list:@"Parcel" criterias:criteria]];
    
    if ([listItems count] > 0) {
        for(Item *item in listItems){
            if (![[item.fields valueForKey:@"id"] isEqualToString:@""] && [item.fields valueForKey:@"id"] != nil) {
                SalesforceAPIRequest *request = [[DeleteRecordRequest alloc] initWithItem:item];
                [self.waiting addObject:request];
            }
        }
    }
    
    /* parcel request create*/
    criteria = [NSDictionary dictionaryWithObjectsAndKeys:[[[ValuesCriteria alloc] initWithString:@"2"] autorelease],@"modified",[[[ValuesCriteria alloc] initWithString:userId] autorelease],@"user_email", nil];
    listItems  = [[NSMutableArray alloc] initWithArray:[ParcelEntityManager list:@"Parcel" criterias:criteria]];
    
    if ([listItems count] > 0) {
        for(Item *item in listItems){
            SalesforceAPIRequest *request = [[CreateRecordRequest alloc] initWithItem:item];
            [self.waiting addObject:request];
            [request release];

            //insert attachments
            if (request.item.attachments!=nil) {
                for (Item *item in [request.item.attachments allValues]) {
                    UpsertAttachmentRequest *upsertatt = [[ UpsertAttachmentRequest alloc]initWithItem:item];
                    [self.waiting addObject:upsertatt];
                    [upsertatt release];
                }
            }            

        }
    }
    
    /* parcel request update*/
    [listItems release];
    
    criteria = [NSDictionary dictionaryWithObjectsAndKeys:[[[ValuesCriteria alloc] initWithString:@"1"] autorelease],@"modified",[[[ValuesCriteria alloc] initWithString:userId] autorelease],@"user_email",nil];
    NSArray *list = [[NSMutableArray alloc] initWithArray:[ParcelEntityManager list:@"Parcel" criterias:criteria]];
    
    if ([list count] > 0) {
        for(Item *item in list){
            SalesforceAPIRequest *request = [[CreateRecordRequest alloc] initWithItem:item];
            [self.waiting addObject:request];
            [request release];
            
            NSDictionary *listatt =[AttachmentEntitymanager findAttachmentByParentId:[item.fields objectForKey:@"id"]];
            //do update childs attachment
            for (Item *t in listatt.allValues) {
                if ([[t.fields objectForKey:@"modified"] isEqualToString:@"1"] || [[t.fields objectForKey:@"modified"] isEqualToString:@"2"]) {
                    UpsertAttachmentRequest *upAtt = [[UpsertAttachmentRequest alloc]initWithItem:t];
                    [self.waiting addObject:upAtt];
                    [upAtt release];
                }
            }

        }
    }
    [list release];
    
    /* parcel query request*/

    NSString *sql = [NSString stringWithFormat:@"SELECT Id,Name,TrackingNo__c,Status__c,Receiver__c,Forwarder__c,Reminder_Date__c, Shipping_Date__c,Note__c, (Select Id , Description , ParentId From Attachments ) FROM Parcel__c WHERE Parcel_User__c = '%@' and (NOT Status__c Like '%%Delivered%%')",[user.fields objectForKey:@"id"]];

    SalesforceAPIRequest *request = [[QueryRequest alloc] initWithSQL:sql sobject:@"Parcel__c"];
    [self.waiting addObject:request];
    [request release];
    
    completed = 0;
    percentage = 0;
    [self computePercent];
    [self checkRunning];
}

- (void)checkRunning {
    
    BOOL more_again;
    do {
        [self.syncCon refresh];
        more_again = YES;
        
        @synchronized([SyncProcess class]) {
            
            if ([self.running count] < 1 && [self.waiting count] > 0) {
                SalesforceAPIRequest *request = nil;
                for (SalesforceAPIRequest *tmp in self.waiting) {
                    request = tmp;
                    break;
                    
                }
                if (request != nil) {
                    [self.running addObject:request];
                    [request doRequest:self];
                    [self.waiting removeObject:request];
                    more_again = NO;
                }
            }else{
                more_again = NO;
            }
        }
        
    } while (more_again);
    
    if(self.waiting.count == 0 && self.running.count == 0){
        
        LogItem *log = [[LogItem alloc] init];
        log.message = @"Synchonization succeeded";
        log.date = [NSDate date];
        log.type = @"Info";
        
        [self.syncCon.listLogs addObject:log];
        [log release];
        [self.syncCon refresh];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Synchronized Finish" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.tag = 1;
        [alert show];
        [alert release];
        
    }
    
}

- (void)stop {
    cancelled = [NSNumber numberWithBool:YES];
    [self.syncCon refresh];
    cancelled = [NSNumber numberWithBool:NO];
}
- (double) computePercent{
    
    double tmp = ((double)completed) / ((double)(completed + [self.waiting count] + [self.running count]));
    if (tmp > percentage) {
        percentage = tmp;
    }
    return percentage;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if([syncCon.type isEqualToString:@"logout"]){
        [[MainViewController getInstance] logout];
        [MainViewController clearInstance];
    }else{
        [syncCon.navigationController popToRootViewControllerAnimated:YES];
    }
    
}


//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateInterfaceWithReachability: curReach];
}



-(void)dealloc{
    [super dealloc];
    [self.waiting release];
    [self.running release];
}
@end
