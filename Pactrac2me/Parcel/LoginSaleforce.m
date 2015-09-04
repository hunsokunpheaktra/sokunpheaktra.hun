//
//  LoginSaleforce.m
//  Parcel
//
//  Created by Gaeasys on 12/26/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "LoginSaleforce.h"

@implementation LoginSaleforce


-(void)doRequest:(NSObject<SyncListener> *)listen{
    
    self.webData = [[NSMutableData alloc] init];
    self.synListener = listen;
    
    NSString *pass = [NSString stringWithFormat:@"%@%@",MASTER_Pass,MASTER_TOKEN];
    NSString *baseURL = [NSString stringWithFormat:@"%@%@",LOGIN_HOST,AUTH_SERVICE];
    NSArray *keys = [NSArray arrayWithObjects:@"client_id", @"client_secret", @"grant_type", @"username", @"password", nil];
    NSArray *values = [NSArray arrayWithObjects:CONSUMER_KEY, CLIENT_SECRET, @"password", MASTER_USR, pass, nil];
    NSDictionary *params = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:baseURL]];
    request.HTTPMethod = [self getMethod];
    
    NSMutableString *requestBody = [[NSMutableString alloc] init];
    NSString *bodyLength = [NSString stringWithFormat:@"%d", [requestBody length]];
    
    // request get session id9
    [requestBody appendString:[NSString stringWithFormat:@"client_id=%@&", [params objectForKey:@"client_id"]]];
    [requestBody appendFormat:@"client_secret=%@&", [params objectForKey:@"client_secret"]];
    [requestBody appendFormat:@"grant_type=%@&", [params objectForKey:@"grant_type"]];
    [requestBody appendFormat:@"username=%@&", [params objectForKey:@"username"]];
    [requestBody appendFormat:@"password=%@", [params objectForKey:@"password"]];
    
    [request addValue:bodyLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request addValue:@"Content-Type" forHTTPHeaderField:@"application/x-www-form-urlencoded"];
    
    self.theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
}
-(NSString *)getProccessName{
    return @"Login";
}

-(NSString *)getMethod{
    return @"POST";
}



@end




