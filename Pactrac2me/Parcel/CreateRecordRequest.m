//
//  CreateRecordRequest.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 12/6/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "CreateRecordRequest.h"
#import "NSObject+SBJson.h"
#import "MainViewController.h"

@implementation CreateRecordRequest

@synthesize sobject;

-(id)initWithItem:(Item *)item{
    self=[super init];
    if (self) {
        self.item = item;
    }
    return self;
}

-(void)doRequest:(NSObject<SyncListener> *)listen{

    self.synListener=listen;
    
    Item *user = [MainViewController getInstance].user;
    NSMutableDictionary *fields = [NSMutableDictionary dictionaryWithDictionary:self.item.fields];
    sobject = self.item.entity;
    NSString *baseUrl = @"";
    
    if([sobject isEqualToString:@"Parcel"]){
        
        [fields removeAllObjects];
        sobject = @"Parcel__c";
        [fields setObject:[user.fields objectForKey:@"id"] forKey:@"Parcel_User__c"];

        NSMutableArray* sfFieldName = [NSMutableArray arrayWithCapacity:1];
        [sfFieldName addObject:@"Name"];
        [sfFieldName addObject:@"TrackingNo__c"];
        [sfFieldName addObject:@"Status__c"];
        [sfFieldName addObject:@"Receiver__c"];
        [sfFieldName addObject:@"Forwarder__c"];
        [sfFieldName addObject:@"Reminder_Date__c"];
        [sfFieldName addObject:@"Shipping_Date__c"];
        [sfFieldName addObject:@"Note__c"];
        
        NSMutableArray* lcFieldName = [NSMutableArray arrayWithCapacity:1];
        [lcFieldName addObject:@"description"];
        [lcFieldName addObject:@"trackingNo"];
        [lcFieldName addObject:@"status"];
        [lcFieldName addObject:@"receiver"];
        [lcFieldName addObject:@"forwarder"];
        [lcFieldName addObject:@"reminderDate"];
        [lcFieldName addObject:@"shippingDate"];
        [lcFieldName addObject:@"note"];

        for (int i =0 ; i < sfFieldName.count ; i++) {
            NSString *value = [self.item.fields objectForKey:[lcFieldName objectAtIndex:i]];
            value = value!=nil ? value : @"";
            [fields setObject:[self.item.fields objectForKey:[lcFieldName objectAtIndex:i]] forKey:[sfFieldName objectAtIndex:i]];
        }
        
        NSString *pId = [self.item.fields objectForKey:@"id"];
        pId = pId==nil ? @"" : pId;
        
        //insert
        if([pId isEqualToString:@""]){
        
            baseUrl = [NSString stringWithFormat:@"%@%@%@/", [[NSUserDefaults standardUserDefaults] objectForKey:@"instance_url"], URL_SERVICE,sobject];
        //update
        }else{
            baseUrl = [NSString stringWithFormat:@"%@%@%@/%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"instance_url"], URL_SERVICE,sobject,pId];
            [fields removeObjectForKey:@"id"];
        }
        
        
    }else if ([sobject isEqualToString:@"User"] || [sobject isEqualToString:@"Parcel_User__c"]) {
        
        if ([sobject isEqualToString:@"User"]){
            sobject = @"Parcel_User__c";
            
            NSString *firstName = [self.item.fields objectForKey:@"first_name"];
            firstName = firstName ? firstName : @"";
            
            NSString *lastName = [self.item.fields objectForKey:@"last_name"];
            lastName = lastName ? lastName : @"";
            
            NSString *password = [self.item.fields objectForKey:@"password"];
            password = !password ? @"" : password;
            
            [fields removeAllObjects];
            [fields setObject:[NSString stringWithFormat:@"%@ %@",firstName,lastName] forKey:@"Name"];
            [fields setObject:firstName forKey:@"First_Name__c"];
            [fields setObject:lastName.length == 0 ? @" ": lastName forKey:@"Last_Name__c"];
            [fields setObject:[self.item.fields objectForKey:@"email"] forKey:@"Email__c"];
            [fields setObject:password forKey:@"Password__c"];
        
        }
        
        NSString *uId = [self.item.fields objectForKey:@"id"];
        uId = uId==nil ? @"" : uId;
        
        //insert
        if([uId isEqualToString:@""]){
            
            baseUrl = [NSString stringWithFormat:@"%@%@%@/", [[NSUserDefaults standardUserDefaults] objectForKey:@"instance_url"], URL_SERVICE,sobject];
        //update
        }else{
            baseUrl = [NSString stringWithFormat:@"%@%@%@/%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"instance_url"], URL_SERVICE,sobject,uId];
            [fields removeObjectForKey:@"id"];
        }
    
    }else{

        baseUrl = [NSString stringWithFormat:@"%@%@%@/", [[NSUserDefaults standardUserDefaults] objectForKey:@"instance_url"], URL_SERVICE,sobject];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:baseUrl]];
    request.HTTPMethod = [self getMethod];
    
    NSMutableString *requestBody = [NSMutableString string];
    NSString *bodyLength = [NSString stringWithFormat:@"%d", [requestBody length]];
    // request create record
    
    [requestBody appendString:fields.JSONRepresentation];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"OAuth %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"]] forHTTPHeaderField:@"Authorization"];
    [request addValue:bodyLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request addValue:@"Content-Type" forHTTPHeaderField:@"application/x-www-form-urlencoded"];
    
    self.theConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

}

-(NSString *)getProccessName{
    return @"Insert";
}

-(NSString *)getMethod{
    
    NSString *pId = [self.item.fields objectForKey:@"id"];
    pId = pId==nil ? @"" : pId;
    return ![pId isEqualToString:@""] ? @"PATCH" : @"POST";
    
}


@end
