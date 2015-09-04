//
//  CallSFMethodClass.m
//  Pactrac2me
//
//  Created by Hun Sokunpheaktra on 3/20/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "CallSFMethodRequest.h"

@implementation CallSFMethodRequest

-(id)initWithUrlMapping:(NSString*)urlMapping userEmail:(NSString*)userEmail{
    self.urlMapping = urlMapping;
    self.userEmail = userEmail;
    return self;
}

-(void)doRequest:(NSObject<SyncListener> *)listen{
    
    self.synListener = listen;
    
    NSString *baseUrl = [NSString stringWithFormat:@"%@/services/apexrest/%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"instance_url"],self.urlMapping];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:baseUrl]];
    request.HTTPMethod = [self getMethod];
    NSMutableString *requestBody = [NSMutableString string];
    [requestBody appendFormat:@"{\"userEmail\":\"%@\"}",self.userEmail];
    NSString *bodyLength = [NSString stringWithFormat:@"%d", [requestBody length]];
    
    NSString *sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"OAuth %@", sessionId] forHTTPHeaderField:@"Authorization"];
    [request addValue:bodyLength forHTTPHeaderField:@"Content-Length"];
    
    request.HTTPBody = [requestBody dataUsingEncoding:NSUTF8StringEncoding];
    
    self.theConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
}

-(NSString *)getProccessName{
    return @"CallSFMethod";
}
-(NSString *)getMethod{
    return @"POST";
}

@end
