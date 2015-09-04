//
//  SyncManager.m
//  CRMiPad
//
//  Created by Sy Pauv Phou on 4/8/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "SyncProcess.h"



@implementation SyncProcess

@synthesize error;
@synthesize listener;
@synthesize running;
@synthesize waiting;
@synthesize cancelled;
@synthesize phase;
@synthesize errCode;


static SyncProcess *_sharedSingleton = nil;

+ (SyncProcess *)getInstance {
	@synchronized([SyncProcess class]) {
		if (!_sharedSingleton)
			[[self alloc] init];
        
		return _sharedSingleton;
	}
    
	return nil;
}

+ (id)alloc {
	@synchronized([SyncProcess class]) {
		NSAssert(_sharedSingleton == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedSingleton = [super alloc];
		return _sharedSingleton;
	}
    
	return nil;
}


- (id)init {
    self = [super init];
    self.listener = Nil;
    self.error = Nil;
    self.waiting = [[NSMutableArray alloc] initWithCapacity:1];
    self.running = [[NSMutableArray alloc] initWithCapacity:1];
    return self;
}



- (void)buildTasks {

    if (self.phase == 1) {
        
        // Request server time at the beginning of the sync
        ServerTimeRequest *startSyncRequest = [[ServerTimeRequest alloc] initWithListener:self];
        [self.waiting addObject:startSyncRequest];
        
        // Current User 
        CurrentUserRequest *currentUser = [[CurrentUserRequest alloc] init:self];
        [self.waiting addObject:currentUser];
        
        // Validate license
        LicenseCheck *license = [[LicenseCheck alloc] init:self];
        [self.waiting addObject:license];
        
        // User
        EntityRequest *request = [[EntityRequest alloc] initWithEntity:@"User" listener:self];
        [request setIdFilter:YES];
        [self.waiting addObject:request];
        
        // Read configuration with role
        GetConfig *getConfig = [[GetConfig alloc] init:self useRole:YES];
        [self.waiting addObject:getConfig];
    
    } else if (self.phase == 2) {
        
        // Read configuration without role
        GetConfig *getConfig = [[GetConfig alloc] init:self useRole:NO];
        [self.waiting addObject:getConfig];
        
    } else {
        
        // Create sync tasks
        // This is called after GetConfig has been successfull
        //
        // 5 metadata
        // 6 company, currency, record type, fields, industry, picklist, other picklist, sales stage
        // 8 outgoing objects
        // 9 sublist deletion, outgoing sublist
        // 10 deleted items
        // 10 read entities
        // 100 update license
        
        //Test Pharma
        PharmaRequest *pharma = [[PharmaRequest alloc]initWithListener:self];
        [self.waiting addObject:pharma];
        
        // Company
        CompanyRequest *company = [[CompanyRequest alloc] init:self];
        [self.waiting addObject:company];
        
        
        // Outgoing data insert & update
        for (NSString *entity in [Configuration getEntities]) {
            OutgoingEntityRequest *outgoingRequest = [[OutgoingEntityRequest alloc] initWithEntity:entity listener:self isDelete:NO];
            [self.waiting addObject:outgoingRequest];
            // sublist updates
            for (NSString *sublist in [[Configuration getInfo:entity] getSublists]) {
                OutgoingSublistRequest *outgoingSublist = [[OutgoingSublistRequest alloc] initWithEntity:entity sublist:sublist listener:self];
                [self.waiting addObject:outgoingSublist];
                DeletedSublistRequest *deletedSublist = [[DeletedSublistRequest alloc] initWithEntity:entity sublist:sublist listener:self];
                [self.waiting addObject:deletedSublist];
            }
        }
        
        //assessments request
        AssessmentsRequest *assessment = [[AssessmentsRequest alloc] initWithListener:self];
        [self.waiting addObject:assessment];

        // Outgoing data delete
        for (NSString *entity in [Configuration getEntities]) {
            OutgoingEntityRequest *outgoingRequestDelete = [[OutgoingEntityRequest alloc] initWithEntity:entity listener:self isDelete:YES];
            [self.waiting addObject:outgoingRequestDelete];
        }
        
        // Get fields
        for (NSString *entity in [Configuration getEntities]) {
            FieldRequest *fieldRequest = [[FieldRequest alloc] initWithEntity:entity listener:self];
            [self.waiting addObject:fieldRequest];
            
            for (NSString *sublist in [[Configuration getInfo:entity] getSublists]) {
                if ([sublist isEqualToString:@"Attachment"]) continue;
                if ([sublist isEqualToString:@"Contact"]) continue;
 
                NSString *sublistCode = [FieldsManager getSublistCode:entity sublist:sublist];
                
                FieldRequest *fieldRequest = [[FieldRequest alloc] initWithEntity:sublistCode listener:self];
                [self.waiting addObject:fieldRequest];
                
            }
        }
        
        // Field management
        FieldManagementRequest *fieldManagement = [[FieldManagementRequest alloc] initWithListener:self];
        [self.waiting addObject:fieldManagement];
        
        // Custom record types
        CustomRecordTypeRequest *cusRecordType = [[CustomRecordTypeRequest alloc] initListener:self];
        [self.waiting addObject:cusRecordType];
        
        // Sales Stage request
        SalesStageRequest *salesStage = [[SalesStageRequest alloc] initWithListener:self];
        [self.waiting addObject:salesStage];
        
        // Currency picklist
        CurrencyCodeRequest *reqCurrency = [[CurrencyCodeRequest alloc] initWithListener:self];
        [self.waiting addObject:reqCurrency];
        
        // Industry picklist
        IndustryRequest *reqIndustries = [[IndustryRequest alloc] initWithListener:self];
        [self.waiting addObject:reqIndustries];
        
        // Standard picklists
        BOOL relationShip = NO;
        for (NSString *entity in [Configuration getEntities]) {
            PicklistRequest *picklistRequest = [[PicklistRequest alloc] initWithEntity:entity listener:self];
            [self.waiting addObject:picklistRequest];
            for (NSString *sublist in [[Configuration getInfo:entity] getSublists]) {
                if ([sublist isEqualToString:@"ProductRevenue"]) {
                    PicklistRequest *picklistRequest = [[PicklistRequest alloc] initWithEntity:@"Revenue" listener:self];
                    [self.waiting addObject:picklistRequest];
                }
                if (([entity isEqualToString:@"Account"] || [entity isEqualToString:@"Opportunity"]) && ([sublist isEqualToString:@"Partner"] || [sublist isEqualToString:@"Competitor"])) {
                    relationShip = YES;
                }
            }
        }
        if (relationShip) {
            PicklistRequest *picklistRequest = [[PicklistRequest alloc] initWithEntity:@"AccountRelationship" listener:self];
            [self.waiting addObject:picklistRequest];
        }
        
        //Cascading picklists
        CascadingPicklistRequest *cascading = [[CascadingPicklistRequest alloc] init:self];
        [self.waiting addObject:cascading];
        
        // Other picklists
        for (NSString *entity in [Configuration getEntities]) {
            NSArray *missing = nil;
            if ([entity isEqualToString:@"Activity"]) {
                missing = [NSArray arrayWithObjects:@"Status", nil];
            } else if ([entity isEqualToString:@"ServiceRequest"]) {
                missing = [NSArray arrayWithObjects:@"Status", @"Type", @"Cause", nil];
            } else if ([entity isEqualToString:@"Opportunity"]) {
                missing = [NSArray arrayWithObjects:@"Type", nil];
            } else if ([entity isEqualToString:@"Account"]) {
                missing = [NSArray arrayWithObjects:@"PrimaryBillToCountry", @"PrimaryBillToState", nil];                
            } else if ([entity isEqualToString:@"Campaign"]) {
                missing = [NSArray arrayWithObjects:@"CampaignType", nil];
            } else if ([entity isEqualToString:@"Contact"]) {
                missing = [NSArray arrayWithObjects:@"AlternateCountry", @"AlternateStateProvince", nil];
            } else if ([entity isEqualToString:@"Lead"]) {
                missing = [NSArray arrayWithObjects:@"Status", @"Country", nil];
            }
            if (missing != nil) {
                for (NSString *field in missing) {
                    OtherPicklistRequest *otherpicklist = [[OtherPicklistRequest alloc] initWithEntity:entity field:field listener:self];
                    [self.waiting addObject:otherpicklist];
                }
            }
        }
        
        //metaData request
        MetadataChangeRequest *metaData = [[MetadataChangeRequest alloc] init:self];
        [self.waiting addObject:metaData];

        
        // Deleted items
        DeletedItemsRequest *deletedItem = [[DeletedItemsRequest alloc] initWithListener:self];
        [self.waiting addObject:deletedItem];
        
        // Incoming data
        for (NSString *entity in [Configuration getEntities]) {
            EntityRequest *request = [[EntityRequest alloc] initWithEntity:entity listener:self];
            [self.waiting addObject:request];
        }
        
        // update free sync
        UpdateSyncTime *update = [[UpdateSyncTime alloc] init:self];
        [self.waiting addObject:update];
        
    }
    
}


- (void)start:(NSObject <SyncListener> *)newListener {
    if ([self isRunning]) return;

    [TestFlight passCheckpoint:@"Start Synchronization"];
    
    self.phase = 1;
    completed = 0;
    percentage = 0;
    cancelled = [NSNumber numberWithBool:NO];
    taskNum = 0;
    [LogManager purge];
    [LogManager info:NSLocalizedString(@"SYNC_STARTED", @"Synchronization started") task:taskNum];
    self.error = Nil;
    self.listener = newListener;
    [self.waiting removeAllObjects];
    [self.running removeAllObjects];
    
    [self buildTasks];
    
    [self checkRunning];
    [self.listener syncStart];  
}

- (void)soapSuccess:(NSObject <SyncTask> *)request lastPage:(BOOL)lastPage objectCount:(int)objectCount {
    if (self.error != Nil || [cancelled boolValue]) {
        return;
    }
    completed++;
    int startCount = 0;
    
    if ([request isKindOfClass:[LicenseCheck class]]) {
        if ( ![Configuration isLicensed]) {
            self.error = @"Invalid License";
        }
    }
    if ([request isKindOfClass:[GetConfig class]]) {
        if (((GetConfig *)request).useRole && objectCount == 0) {
            self.phase = 2;
        } else {
            self.phase = 3;
        }
        [self buildTasks];
        if (objectCount == 1) {
            // the new config may require the creation of new tables,
            // for added entities
            [EntityManager initTables];
            [SublistManager initTables];
            // init the possibly missing entities
            [PropertyManager initData];
            // refresh the relations
            [Relation resetRelations];
            // refresh the tabs
             [self performSelector:@selector(refreshTabs) withObject:nil afterDelay:0.1];
            
        }
    }

    if ([request isKindOfClass:[CustomRecordTypeRequest class]]) {
        // the object names may have changed, we need to refresh the tabs
        [self.listener syncConfig];
    }
    if ([request isKindOfClass:[EntityRequest class]]
        && [((EntityRequest *)request).entity isEqualToString:@"User"]) {
        // clean the user the cache
        [CurrentUserManager initData];
    }
    if ([request isKindOfClass:[EntityRequest class]]) {
        startCount = [((EntityRequest *)request).startRow intValue];
    }
    if ([request isKindOfClass:[DeletedItemsRequest class]]) {
        startCount = [((DeletedItemsRequest *)request).startRow intValue];
    }
    
    if (![request isMemberOfClass:[UpdateSyncTime class]] && ![request isMemberOfClass:[LicenseCheck class]]) {
        [LogManager success:[request getName] task:[[request task] intValue] count:startCount + objectCount];
    }

    [self.running removeObject:request];
    if (lastPage == NO) {
        [self.waiting addObject:request];
        completed--;        
    } else {
        if ([request isKindOfClass:[EntityRequest class]]) {
            EntityRequest *eRequest = (EntityRequest *)request;
            if (eRequest.idFilter == NO) {
                [LastSyncManager save:eRequest.entity date:[PropertyManager read:@"SyncStart"]];
            }
        }
    }
    
    [self checkRunning];
    [self.listener syncProgress:[request requestEntity]];
    [request release];
    [self computePercent];
    if (![self isRunning]) {
        [self end];
    }
}

- (void)refreshTabs {
    [self.listener syncConfig];
}
    
- (void)soapFailure:(NSObject <SyncTask> *)request errorCode:(NSString *)errorCode errorMessage:(NSString *)errorMessage {
    if (self.error != Nil || [cancelled boolValue]) {
        return;
    }
    NSLog(@"Failure %@: %@", [request getName], errorMessage);
    
    [self.running removeObject:request];
    [self.listener syncProgress:[request requestEntity]];
    
    if ([self isBlocking:errorCode errorMessage:errorMessage]) {
        
        if ([request isMemberOfClass:[PicklistRequest class]] || [request isMemberOfClass:[FieldRequest class]] || [request isMemberOfClass:[OtherPicklistRequest class]]){
            [PropertyManager save:@"LOVLastUpdated" value:@""];
            
        }
        [LogManager error:[NSString stringWithFormat:@"Error code: %@ - %@", errorCode, errorMessage] task:[[request task] intValue]];
        // abandon
        if (self.error == nil) {
            if ([errorCode isEqualToString:@"-1202"]) {
                self.error = NSLocalizedString(@"BAD_SERVER", nil);
            } else {
                self.error = [NSString stringWithString:errorMessage];
            }
            self.errCode = [NSString stringWithString:errorCode];
        }
        [request release];
    } else if (self.error == nil && [self shouldRetry:errorCode errorMessage:errorMessage]) {
        // retry 
        if ([[request retryCount] intValue] < 5) {
            [LogManager success:@"Retry" task:[[request task] intValue] count:-1];
            [self.waiting addObject:request];
        } else {
            
            if ([request isMemberOfClass:[PicklistRequest class]] || [request isMemberOfClass:[FieldRequest class]]||[request isMemberOfClass:[OtherPicklistRequest class]]){
                [PropertyManager save:@"LOVLastUpdated" value:@""];
            }
            [LogManager error:[NSString stringWithFormat:@"Error code: %@ - %@", errorCode, errorMessage] task:[[request task] intValue]];
            if (self.error == Nil) {
                self.error = [NSString stringWithString:errorMessage];
                self.errCode = [NSString stringWithString:errorCode];
            }
        }
    } else if (([request isMemberOfClass:[CustomRecordTypeRequest class]] || [request isMemberOfClass:[IndustryRequest class]] || [request isMemberOfClass:[CurrencyCodeRequest class]] || [request isMemberOfClass:[PharmaRequest class]] || [request isMemberOfClass:[CompanyRequest class]] || ([request isMemberOfClass:[FieldRequest class]] && [((FieldRequest *)request).entity isEqualToString:@"Revenue"]) || [request isMemberOfClass:[CompanyRequest class]] || [request isMemberOfClass:[PicklistRequest class]] || [request isMemberOfClass:[AssessmentsRequest class]])
               && ([errorCode isEqualToString:@"SBL-ODU-01011"] || [errorCode isEqualToString:@"env:Server"] || [errorCode isEqualToString:@"404"] || [errorCode isEqualToString:@"SOAP-ENV:Server"] || [errorMessage rangeOfString:@"CurrentOrganization"].location != NSNotFound)) {
        // skip
        [LogManager success:@"No rights" task:[[request task] intValue] count:-2];
        [request release];
    } else {
    
        if ([request isMemberOfClass:[OutgoingEntityRequest class]]) {
            
            // Outgoing request : mark the item as "Error"
            OutgoingEntityRequest *outgoingRequest = (OutgoingEntityRequest *)request;
            NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithCapacity:1];
            [tmp setObject:[outgoingRequest.item.fields objectForKey:@"gadget_id"] forKey:@"gadget_id"];
            [tmp setObject:errorMessage forKey:@"error"];
            // if it is a deletion, undelete it
            [tmp setObject:[NSNull null] forKey:@"deleted"];
            Item *tmpItem = [[Item alloc] init:outgoingRequest.entity fields:tmp];
            
            //RSK: if parent outgoing request failed cacell all sublist outgoing request
            for (id req in [NSArray arrayWithArray:self.waiting]) {
                if ([req isKindOfClass:[OutgoingSublistRequest class]]) {
                    if ([((OutgoingSublistRequest *)req).entity isEqualToString:outgoingRequest.entity]) {
                        [self.waiting removeObject:req];
                        [self.running removeObject:req];
                    }
                }
            }
            
            //RSK: for request delete if error code return 'SBL-EAI-04378' mean that record is deleted by other device so delete direct from local database
            
            if ([errorCode isEqualToString:@"SOAP-ENV:Server"] && [errorMessage rangeOfString:@"SBL-EAI-04378"].length > 0 ) {
                [EntityManager remove:tmpItem];
            } else {
                [EntityManager update:tmpItem modifiedLocally:NO];
                [self.waiting addObject:request];
            } 
            
            [LogManager warning:[NSString stringWithFormat:@"Error code: %@ - %@", errorCode, errorMessage] task:[[request task] intValue] withId:[tmpItem.fields objectForKey:@"gadget_id"] entity:tmpItem.entity];
            
            [tmpItem release];
            [tmp release];
            
        } else {
            
            [LogManager warning:[NSString stringWithFormat:@"Error code: %@ - %@", errorCode, errorMessage] task:[[request task] intValue] withId:nil entity:nil];
        
        }
    }
    

    [self checkRunning];
    if (![self isRunning]) {
        [self end];
    }
}

- (void)checkRunning {
    if (self.error != Nil || [cancelled boolValue]) {
        return;
    }
    BOOL again;
    do {
        NSLog(@"Waiting: %d Running: %d", [self.waiting count], [self.running count]);
    
        again = NO;
        @synchronized([SyncProcess class]) {
            if ([self.running count] < PIPELINE_SIZE && [self.waiting count] > 0) {
                int maxStep = 9999;
                // get the number of the next step
                if ([self.running count] > 0) {
                    maxStep = [[self.running objectAtIndex:0] getStep];
                } else {
                    for (NSObject <SyncTask> *tmp in self.waiting) {
                        if ([tmp getStep] < maxStep) {
                            maxStep = [tmp getStep];
                        }
                    }
                }
                // get the next task corresponding to this step
                NSObject <SyncTask> *request = Nil;
                for (NSObject <SyncTask> *tmp in self.waiting) {
                    if ([tmp getStep] <= maxStep) {
                        request = tmp;
                        break;
                    }
                   
                }
                if (request != Nil) {
                    [self.waiting removeObject:request];
                    if ([request prepare]) {
                        NSLog(@"Requesting [%@]", [request getName]);
                        [self.running addObject:request];
                        taskNum++;
                        [request setTask:[NSNumber numberWithInt:taskNum]];
                        if (![request isMemberOfClass:[UpdateSyncTime class]]
                            && ![request isMemberOfClass:[LicenseCheck class]]) {
                            [LogManager info:[request getName] task:taskNum];
                        }
                        [request performSelector:@selector(doRequest) withObject:nil afterDelay:request.getDelay];
                    }
                   
                    again = YES;
                } 
            }
        }
       
        
    } while (again);
}

+ (BOOL)isBadLogin:(NSString *)errorMessage {
    NSString *lower = [errorMessage lowercaseString];
    // we need to test the localized message, Oracle does not return a specific error code for bad login...
    return [lower rangeOfString:@"unknown user"].location != NSNotFound
        || [lower rangeOfString:@"id de connexion"].location != NSNotFound
        || [lower rangeOfString:@"unbekannter benutzername"].location != NSNotFound
        || [lower rangeOfString:@"un id accesso"].location != NSNotFound
        || [lower rangeOfString:@"contraseña o id"].location != NSNotFound
        || [lower rangeOfString:@"caps lock"].location != NSNotFound;
}

- (BOOL)isBlocking:(NSString *)errorCode errorMessage:(NSString *)errorMessage {
    // non blocking errors
    if ([errorCode isEqualToString:@"404"] 
        || [errorCode isEqualToString:@"wsse:FailedAuthentication"]
        || [errorCode isEqualToString:@"-1001"]
        || [errorCode isEqualToString:@"ORACLE_DOWN"] // #5232
        || [errorCode isEqualToString:@"SBL-ODU-01005"]
        || [errorCode isEqualToString:@"SBL-ODU-01011"]
        || ([errorCode isEqualToString:@"SBL-ODU-01006"]
            && ![SyncProcess isBadLogin:errorMessage])
        || [errorCode isEqualToString:@"SOAP:Server"]
        || [errorCode isEqualToString:@"env:Server"] // CustomRecordType : There is no customized record type for the user
        || [errorCode isEqualToString:@"SOAP-ENV:Server"]
        || [errorMessage rangeOfString:@"CurrentOrganization"].location != NSNotFound) {
        return false;
    }
    return true; // all the rest is blocking
}

- (BOOL)shouldRetry:(NSString *)errorCode errorMessage:(NSString *)errorMessage {
    if ([errorCode isEqualToString:@"SBL-ODU-01005"]
        || [errorMessage rangeOfString:@"SBL-DAT-00523"].location != NSNotFound // #5124
        || [errorCode isEqualToString:@"SBL-ODU-01006"]
        || [errorCode isEqualToString:@"-1001"]
        || [errorCode isEqualToString:@"ORACLE_DOWN"] // #5232
        || [errorCode isEqualToString:@"wsse:FailedAuthentication"]
        || [errorMessage rangeOfString:@"Session already invalidated"].location != NSNotFound // #5088
        || [errorMessage rangeOfString:@"Nested timers"].location != NSNotFound) { // #5088
        return true;
    }
    return false;
}

- (void)end {
    [TestFlight passCheckpoint:@"End Synchronization"];
    [PropertyManager save:@"PreviousSyncStart" value:[PropertyManager read:@"SyncStart"]];
    if (error == nil) {
        if (![cancelled boolValue]) {
            [LogManager info:NSLocalizedString(@"SYNC_SUCCESS", @"Synchronization success") task:taskNum];
        } else {
            [LogManager error:NSLocalizedString(@"SYNC_STOP", @"Synchronization stopped") task:taskNum];
        }
    }
    BOOL sendReport = YES;
    if ([SyncProcess isBadLogin:error] || [errCode isEqualToString:@"76"] || [errCode isEqualToString:@"-1202"] || [errCode isEqualToString:@"-1005"] || [errCode isEqualToString:@"-1001"] || [errCode isEqualToString:@"-1003"] || [errCode isEqualToString:@"-1009"] || [errCode isEqualToString:@"ORACLE_DOWN"]) {
        sendReport = NO;
    }
    [self.listener syncEnd:error sendReport:sendReport];
}

- (BOOL)isRunning {
    return error == nil && ([self.running count] > 0 || [self.waiting count] > 0) && [cancelled boolValue] == NO;
}

- (void)stop {
    cancelled = [NSNumber numberWithBool:YES];
    [self end];
   
}
- (double)computePercent{
    double tmp = ((double)completed) / ((double)(completed + [self.waiting count] + [self.running count]));
    if (self.phase == 1 || self.phase == 2) {
        tmp *= .25;
    } else {
        tmp = 0.25 + tmp * 0.75;
    }
    if (tmp > percentage) {
        percentage = tmp;
    }
    return percentage;
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

@end
