//
//  DeleteRecordRequest.m
//  Parcel
//
//  Created by Sy Pauv on 1/15/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "DeleteRecordRequest.h"

@implementation DeleteRecordRequest
@synthesize sObject,recId;

-(id)initWithSObject:(NSString *)name id:(NSString *)rId{
    self = [super init];
    sObject = name;
    recId = rId;
    
    return self;
}

-(id)initWithItem:(Item*)item {
    self = [super init];
    sObject = item.entity;
    self.item = item;
    if ([sObject isEqualToString:@"Parcel"]) sObject = @"Parcel__c";
    recId   = [item.fields valueForKey:@"id"];
    
    return self;
}

-(void)doRequest:(NSObject<SyncListener> *)listen{
    
    self.synListener=listen;
    
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@%@/%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"instance_url"],URL_SERVICE,sObject,recId];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:baseUrl]];
    request.HTTPMethod = [self getMethod];
    // request query record
    [request addValue:[NSString stringWithFormat:@"OAuth %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"]] forHTTPHeaderField:@"Authorization"];
    
    [request addValue:@"Content-Type" forHTTPHeaderField:@"application/x-www-form-urlencoded"];
    self.theConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
}

-(NSString *)getProccessName{
    return  @"Delete";
}

-(NSString *)getMethod{
    return @"DELETE";
}

@end
