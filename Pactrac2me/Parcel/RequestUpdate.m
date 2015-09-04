//
//  RequestUpdate.m
//  Parcel
//
//  Created by Gaeasys on 1/8/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "RequestUpdate.h"
#import "LoginViewController.h"
#import "MyParcelViewController.h"
#import "ParcelEntityManager.h"
#import "SearchFields.h"
#import "AttachmentEntitymanager.h"

@implementation RequestUpdate


- (id) initWithEntity: (NSString*)entity parentClass:(id) parentRef {
    
    entityName = entity;
    parentVC   = parentRef;
    
    return self;
}


- (void) start {
    
    if ([entityName isEqualToString:@"Parcel__c"]) {
        
        if ([parentVC isKindOfClass:[LoginViewController class]]) {
            /* parcel query request*/
            Item *user = [MainViewController getInstance].user;

            NSString *sql = [NSString stringWithFormat:@"SELECT Id,Name,TrackingNo__c,Status__c,Receiver__c,Forwarder__c,Reminder_Date__c, Shipping_Date__c,Note__c,Parcel_User__c, (Select Id , Description , ParentId From Attachments ) FROM Parcel__c WHERE Parcel_User__c = '%@'",[user.fields objectForKey:@"id"]];

            SalesforceAPIRequest *request = [[QueryRequest alloc] initWithSQL:sql sobject:@"Parcel__c"];
            [request doRequest:self];
            [request release];
            
        }else {
            
            Item* user = [MainViewController getInstance].user ;
            NSString *sql = [NSString stringWithFormat:@"SELECT Id,Status__c FROM %@ WHERE Parcel_User__c = '%@'",entityName,[user.fields objectForKey:@"id"]];
            SalesforceAPIRequest *request = [[QueryRequest alloc] initWithSQL:sql sobject:entityName];
            [request doRequest:self];
            [request release];
        }
    }
    
    
    
}

- (void) onSuccess:(id)req {
    
    SalesforceAPIRequest *request = req;
    
    if([request isKindOfClass:[LoginRequest class]]){
        [self userRequest];
    }else if([request isKindOfClass:[QueryRequest class]]){
        QueryRequest *queryReq = (QueryRequest*)request;
        if([queryReq.sobject isEqualToString:@"Parcel_User__c"]){
            if ([parentVC isKindOfClass:[LoginViewController class]]) {
                
                Item* findUser = [UserManager find:@"User" column:@"email" value:[[MainViewController getInstance].user.fields valueForKey:@"email"]];
                if(request.records.count == 0 && !findUser){
                    [parentVC registerScreen:[MainViewController getInstance].user];
                } else if (request.records.count == 0 && findUser) {
                    [self registerUser];
                }else if (request.records.count > 0 && !findUser) {
                    Item* newLocalUser = [self setLocalUserFields:[request.records objectAtIndex:0]];
                    [newLocalUser.fields setValue:@"0" forKey:@"modified"];
                    [UserManager insert:newLocalUser];
                    [MainViewController getInstance].user = newLocalUser;
                    entityName = @"Parcel__c";
                    [self start];
                    //                    [parentVC login2Mainscreen:newLocalUser];
                }else if (request.records.count > 0 && findUser) {
                    Item* newLocalUser = [self setLocalUserFields:[request.records objectAtIndex:0]];
                    [newLocalUser.fields setValue:@"0" forKey:@"modified"];
                    [UserManager update:newLocalUser];
                    [parentVC login2Mainscreen:newLocalUser];
                }
            } else [super onSuccess:req];
            
        }else if([queryReq.sobject isEqualToString:@"Mobile_Device__c"]){
            if(request.records.count > 0){
                [self start];
            }else{
                [self registerDeviceToken];
            }
        }else if ([queryReq.sobject isEqualToString:@"Parcel__c"]){
            
            NSArray*listUpdate = queryReq.records;
            [self updateData:listUpdate];
        }
        
    }else if([request isKindOfClass:[CreateRecordRequest class]]) {
        if([request.item.entity isEqualToString:@"Mobile_Device__c"]){
            [self start];
        } else if([request.item.entity isEqualToString:@"User"]){
            if ([parentVC isKindOfClass:[LoginViewController class]]) {
                Item *user = request.item;
                [user.fields setObject:@"0" forKey:@"modified"];
                [user.fields setObject:@"2" forKey:@"loginCount"];
                [UserManager insert:user];
                [parentVC login2Mainscreen:user];
            }else
                [super onSuccess:req];
        }
    }
    
}

- (void) onFailure:(NSString *)errorMessage request:(id)req {
    
    if([errorMessage isEqualToString:@"INVALID_SESSION_ID"]){
        [super onFailure:errorMessage request:req];
    }
    else if ([errorMessage rangeOfString:@"The Internet connection appears to be offline."].location != NSNotFound) {
        [parentVC finishUpdating];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:CONNECT_ERROR message:OFFLINE_ERROR_MESSAGE delegate:self cancelButtonTitle:MSG_OK otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }else {
        if ([parentVC isKindOfClass:[MyParcelViewController class]])
            [parentVC finishUpdating];
        [super onFailure:errorMessage request:req];
    }
}


- (void) updateData : (NSArray*)listUpdate{
    
    if ([parentVC isKindOfClass:[LoginViewController class]]) {
        
        NSArray *newListRecords = listUpdate;
        
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
        [sfFieldName addObject:@"Parcel_User__c"];
        
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
        [lcFieldName addObject:@"user_email"];
        
        Item* user = [MainViewController getInstance].user;
        
        for(NSMutableDictionary *fields in newListRecords){
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            for (int i =0 ; i < sfFieldName.count ; i++) {
                if ([fields objectForKey:[sfFieldName objectAtIndex:i]] == [NSNull null]) {
                    [fields setValue:@"" forKey:[sfFieldName objectAtIndex:i]];
                }
                NSString *value = [fields objectForKey:[sfFieldName objectAtIndex:i]];
                value = value == nil ? @"" : value;
                [dic setObject:value forKey:[lcFieldName objectAtIndex:i]];
            }
        
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
            
            Item *item = [[Item alloc] initCustom:@"Parcel" fields:dic];
            BOOL isLocal = [ParcelEntityManager find:@"Parcel" column:@"Id" value:[fields objectForKey:@"Id"]] != nil;
            if(isLocal) [ParcelEntityManager update:item modifiedLocally:false];
            else [ParcelEntityManager insert:item modifiedLocally:false];
            
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
                        [getAttBody doRequest:nil];
                        [getAttBody release];
                        
                    }
                }
            }
            
        }
        
        [parentVC login2Mainscreen:user];
        
    } else {
        
        for (NSDictionary*data in listUpdate) {
            Item* item = [ParcelEntityManager find:@"Parcel" column:@"id" value:[data valueForKey:@"Id"]];
            if (item) {
                [item.fields setValue:[data valueForKey:@"Status__c"] forKey:@"status"];
                [ParcelEntityManager update:item modifiedLocally:NO];
            }
        }
        
        [parentVC finishUpdating];
        
    }
}


- (Item*) setLocalUserFields : (NSDictionary*) record {
    
    Item* new = [[Item alloc] init:@"User" fields:[NSDictionary dictionary]];
    
    if ([[record allKeys] containsObject:@"id"])
        [new.fields setValue:[record valueForKey:@"id"] forKey:@"id"];
    else if ([[record allKeys] containsObject:@"Id"]) [new.fields setValue:[record valueForKey:@"Id"] forKey:@"id"];
    [new.fields setValue:[record valueForKey:@"Email__c"] forKey:@"email"];
    [new.fields setValue:[record valueForKey:@"First_Name__c"] forKey:@"first_name"];
    [new.fields setValue:[record valueForKey:@"Last_Name__c"] forKey:@"last_name"];
    [new.fields setValue:[record valueForKey:@"Password__c"] forKey:@"password"];
    
    return new;
}



@end
