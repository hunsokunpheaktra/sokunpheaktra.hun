//
//  QueryRequest.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 12/5/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "QueryRequest.h"
#import "AppDelegate.h"

@implementation QueryRequest

-(id)initWithSQL:(NSString *)s sobject:(NSString*)object{
    self=[super init];
    if (self) {
        self.sql = s;
        self.sobject = object;
    }
    return self;
}

-(void)doRequest:(NSObject<SyncListener> *)listen{
    
    self.synListener=listen;
    NSString *encodedSQL = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)self.sql,
                                                              NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8);
    
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"instance_url"], URL_SERVICE_SOQL, encodedSQL];
    [encodedSQL release];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:baseUrl]];
    request.HTTPMethod = [self getMethod];
    // request query record
    [request addValue:[NSString stringWithFormat:@"OAuth %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"]] forHTTPHeaderField:@"Authorization"];
    
    [request addValue:@"Content-Type" forHTTPHeaderField:@"application/x-www-form-urlencoded"];
    self.theConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

-(NSString *)getProccessName{
   return  @"Query";
}

@end
