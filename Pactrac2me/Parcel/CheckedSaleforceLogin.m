//
//  CheckedSaleforceLogin.m
//  Parcel
//
//  Created by Gaeasys on 1/8/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "CheckedSaleforceLogin.h"
#import "AppDelegate.h"
#import "ValuesCriteria.h"
#import "ParcelEntityManager.h"
#import "SettingManager.h"

@implementation CheckedSaleforceLogin

@synthesize internetActive;
@synthesize hostActive;
@synthesize error;
@synthesize cancelled;


- (BOOL) doAlertInternetFailed{
    //Check if internet connection reachable
    if(!self.internetActive){
        //open alert to confirm
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NETWORK_UNREACHABLE  message:nil
                                                       delegate:self cancelButtonTitle:MSG_OK
                                              otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        return YES;
    }
    return NO;
}


- (void) updateInterfaceWithReachability: (Reachability*) curReach{
    
}

- (void) startNotifier{
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReach = [[Reachability reachabilityForInternetConnection] retain];
    [internetReach startNotifer];
    
    // check if a pathway to a random host exists
    hostReach = [[Reachability reachabilityWithHostName: @"www.apple.com"] retain];
    [hostReach startNotifer];
    
    
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
                error = NETWORK_UNREACHABLE;
                
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
                error = NETWORK_UNREACHABLE;
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


- (void) userRequest {
    
    Item *user = [MainViewController getInstance].user;
    NSString *sql = [NSString stringWithFormat:@"SELECT Id,Email__c,First_Name__c,Last_Name__c,Password__c FROM Parcel_User__c WHERE Email__c = '%@'",[user.fields objectForKey:@"email"]];
    
    QueryRequest *query = [[QueryRequest alloc] initWithSQL:sql sobject:@"Parcel_User__c"];
    [query doRequest:self];
    [query release];
}


- (void) checkSaleForceLogin {
    
    NSString *sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    if(!sessionId){
        
        LoginRequest *login = [[LoginRequest alloc] init];
        [login doRequest:self];
        [login release];
        
    }else{
        [self userRequest];
    }
    
}


-(void)registerDeviceToken{
    
    Item *user = [MainViewController getInstance].user;
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    Item *item = [[Item alloc] init:@"Mobile_Device__c" fields:[NSDictionary dictionaryWithObjectsAndKeys:delegate.deviceTokenData,@"Name",[user.fields objectForKey:@"id"],@"Parcel_User__c" ,nil]];
    
    CreateRecordRequest *create = [[CreateRecordRequest alloc] initWithItem:item];
    [create doRequest:self];
    [create release];
    
}

-(void)checkDeviceToken {
    
    Item *user = [MainViewController getInstance].user;
    
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSString *sql = [NSString stringWithFormat:@"select id,Name from Mobile_Device__c where Name = '%@' and Parcel_User__c = '%@'",delegate.deviceTokenData,[user.fields objectForKey:@"id"]];
    
    QueryRequest *query = [[QueryRequest alloc] initWithSQL:sql sobject:@"Mobile_Device__c"];
    [query doRequest:self];
    [query release];
    
}



-(void)registerUser {
    
    Item *user = [MainViewController getInstance].user;
    NSString *uid = [user.fields objectForKey:@"id"];
    
    NSString *firstName = [user.fields objectForKey:@"first_name"];
    firstName = firstName ? firstName : @"";
    
    NSString *lastName = [user.fields objectForKey:@"last_name"];
    lastName = lastName ? lastName : @"";
    
    NSString *password = [user.fields objectForKey:@"password"];
    password = !password ? @"" : password;
    
    NSMutableDictionary *fields = [NSMutableDictionary dictionary];
    
    [fields setObject:firstName forKey:@"first_name"];
    [fields setObject:lastName.length == 0 ? @" ": lastName forKey:@"last_name"];
    [fields setObject:[user.fields objectForKey:@"email"] forKey:@"email"];
    [fields setObject:password forKey:@"password"];
    if(uid) [fields setObject:uid forKey:@"id"];
    
    Item *item = [[Item alloc] init:@"User" fields:fields];
    
    CreateRecordRequest *create = [[CreateRecordRequest alloc] initWithItem:item];
    [create doRequest:self];
    [create release];
}

- (BOOL)isRunning {
    return NO;
}

- (void) onSuccess:(id)req {
   
    SalesforceAPIRequest *request = req;
    Item *user = [MainViewController getInstance].user;

    if([request isKindOfClass:[QueryRequest class]]){
    
      QueryRequest *queryReq = (QueryRequest*)request;
    
        if([queryReq.sobject isEqualToString:@"Parcel_User__c"]){
            
            if(request.records.count > 0){
            
                if ([[user.fields valueForKey:@"modified"] isEqualToString:@"2"]){
                    
                    if (!(([[user.fields valueForKey:@"password"] isEqualToString:@""] || [user.fields valueForKey:@"password"] == nil )&&  ([[queryReq.records objectAtIndex:0] valueForKey:@"Password__c" ] == [NSNull null]))) {
                       

                        if (![[user.fields valueForKey:@"password"] isEqualToString:[[queryReq.records objectAtIndex:0] valueForKey:@"Password__c"]]) {
                            [self onFailure:@"INVALID_PASSWORD" request:req];
                            return;
                        }
                    }
                
                }
                
                [user.fields setObject:[[request.records objectAtIndex:0] objectForKey:@"Id"] forKey:@"id"];
                if (![[user.fields valueForKey:@"modified"] isEqualToString:@"1"]) {
                    if ([[request.records objectAtIndex:0] objectForKey:@"Password__c"] != nil)
                        [user.fields setObject:[[request.records objectAtIndex:0] objectForKey:@"Password__c"] forKey:@"password"];
                    if ([[request.records objectAtIndex:0] objectForKey:@"Last_Name__c"] != nil)
                    [user.fields setObject:[[request.records objectAtIndex:0] objectForKey:@"Last_Name__c"] forKey:@"last_name"];
                    if ([[request.records objectAtIndex:0] objectForKey:@"First_Name__c"] != nil)
                        [user.fields setObject:[[request.records objectAtIndex:0] objectForKey:@"First_Name__c"] forKey:@"first_name"];
                    [user.fields setObject:@"0" forKey:@"modified"];
                    [UserManager update:user];
                }
                
                if([[user.fields objectForKey:@"modified"] isEqualToString:@"1"]){
                    CreateRecordRequest *updateUser = [[CreateRecordRequest alloc] initWithItem:user];
                    [updateUser doRequest:self];
                    [updateUser release];
                }else{
                    [self checkDeviceToken];
                }
                
            }else{
                [self registerUser];
            }
            
        } 
    } else if([request isKindOfClass:[CreateRecordRequest class]]) {
        
            if([request.item.entity isEqualToString:@"Parcel_User__c"] || [request.item.entity isEqualToString:@"User"]) {
                [user.fields setObject:[request.item.fields objectForKey:@"id"] forKey:@"id"];
                [user.fields setObject:@"0" forKey:@"modified"];
                [UserManager update:user];
                
                [MainViewController getInstance].user = user;
                
                //update parcel user_email field to id
                NSMutableDictionary *criteria = [NSMutableDictionary dictionary];
                [criteria setObject:[[[ValuesCriteria alloc] initWithString:[user.fields objectForKey:@"local_id"]] autorelease] forKey:@"user_email"];
                NSArray *listParcel = [ParcelEntityManager list:@"Parcel" criterias:criteria];
                for(Item *item in listParcel){
                    [item.fields setObject:[user.fields objectForKey:@"id"] forKey:@"user_email"];
                    [ParcelEntityManager update:item modifiedLocally:NO];
                    [item release];
                }
                
                Item *settingItem = [SettingManager find:@"Setting" column:@"user_email" value:[user.fields objectForKey:@"local_id"]];
                if(settingItem){
                    [settingItem.fields setObject:[user.fields objectForKey:@"id"] forKey:@"user_email"];
                    [SettingManager update:settingItem];
                    [settingItem release];
                }
                
                if ([request.item.entity isEqualToString:@"User"]) [self checkDeviceToken];
            }
    
    }
}

- (void) onFailure:(NSString *)errorMessage request:(id)req {
    
    if([errorMessage isEqualToString:@"INVALID_SESSION_ID"]){
        
        LoginRequest *login = [[LoginRequest alloc] init];
        [login doRequest:self];
        [login release];
        
    }else if ([errorMessage rangeOfString:@"INVALID_PASSWORD"].location != NSNotFound) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:CONNECT_ERROR message:INVALID_PASSWORD_MESSAGE delegate:self cancelButtonTitle:MSG_OK otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [hostReach release];
    [internetReach release];
    [super dealloc];
}


@end
