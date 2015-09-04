//
//  GetConfig.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 7/20/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "GetConfig.h"


@implementation GetConfig

@synthesize task;
@synthesize callNum;
@synthesize webData;
@synthesize listener;
@synthesize useRole;
@synthesize currentResponse;

- (id)init:(NSObject <SOAPListener> *)newListener useRole:(BOOL)pUseRole {
    self = [super init];
    self.listener = newListener;
    self.useRole = pUseRole;
    self.currentResponse = nil;
    return self;
}

- (void)doRequest {
    self.webData = [[NSMutableData alloc] init];
    self.callNum = [NSNumber numberWithInt:1];
    NSString *address = [NSString stringWithFormat:@"%@/%@", [PropertyManager read:@"URL"], @"OnDemand/authenticate"];
	NSURL *url = [NSURL URLWithString:address];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *encodedUsername = [GetConfig escape:[PropertyManager read:@"Login"]];
    NSString *encodedPassword = [GetConfig escape:[PropertyManager read:@"Password"]];
    NSString *args = [NSString stringWithFormat:@"j_username=%@&j_password=%@", encodedUsername, encodedPassword];
    [request setHTTPBody: [args dataUsingEncoding:NSUTF8StringEncoding]];
	[request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    //[request setValue:@"Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.2.18) Gecko/20110614 Firefox/3.6.18" forHTTPHeaderField:@"User-Agent"];
	[request setHTTPMethod:@"POST"];
    
	[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];  
}


- (void)getFile {
    self.callNum = [NSNumber numberWithInt:[self.callNum intValue] + 1];
    NSString *address = [NSString stringWithFormat:@"%@/%@%@", [PropertyManager read:@"URL"], @"OnDemand/user/content/",[GetConfig escape:[self fixConfigName]]];
	NSURL *url = [NSURL URLWithString:address];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"max-age=0" forHTTPHeaderField:@"Cache-Control"];
    //[request setValue:@"Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.2.18) Gecko/20110614 Firefox/3.6.18" forHTTPHeaderField:@"User-Agent"];
	[request setHTTPMethod:@"GET"];  
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];  
}

+ (NSString *)escape:(NSString *)s {
    return (NSString *)CFURLCreateStringByAddingPercentEscapes(
       NULL,
       (CFStringRef)s,
       NULL,
       (CFStringRef)@"!*'();:@&=+$,/?%#[]",
       kCFStringEncodingUTF8);
}




- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.currentResponse = (NSHTTPURLResponse *)response;
    NSLog(@"%d", [currentResponse statusCode]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([self.callNum intValue] == 1) {
        if ([currentResponse statusCode] == 200) {
            [self getFile];
            return;
        }
    } else if ([self.callNum intValue] == 2) {
        if ([currentResponse statusCode] == 200) {
            [self getFile];
            return;
        }
    } else if ([self.callNum intValue] == 3) {
        if (self.currentResponse != nil && [self.currentResponse statusCode] == 200) {
            NSString *contentType = [[self.currentResponse allHeaderFields] objectForKey:@"Content-Type"];
            if ([contentType rangeOfString:@"text/html"].location == NSNotFound) {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *overridePath = [documentsDirectory stringByAppendingPathComponent:@"ipad.xml"];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSError *error = nil;
                if (![fileManager removeItemAtPath:overridePath error:&error]) {
                    NSLog(@"%@", error);
                }
                [webData writeToFile:overridePath atomically:YES];
                [Configuration reload];
                [LayoutFieldManager apply:[Configuration getInstance]];
                [PropertyManager initData];
                [TabManager initData];
                [self.listener soapSuccess:self lastPage:YES objectCount:1];
                return;
            }
        }
    }
    [self.listener soapSuccess:self lastPage:YES objectCount:0];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)nsError
{
    [listener soapFailure:self errorCode:[NSString stringWithFormat:@"%i", [nsError code]] errorMessage:[nsError localizedDescription]];
}
         
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if ([self.callNum intValue] == 3) {
        [webData appendData:data];
    }
}


- (NSString *)fixConfigName {
    NSString *configName = [PropertyManager read:@"xmlName"];
    Item *userInfo = [CurrentUserManager getCurrentUserInfo];
    if (![[configName lowercaseString] hasSuffix:@".xml"]) {
        configName = [NSString stringWithFormat:@"%@.xml", configName];
    }
    if (self.useRole) {
        NSString *roleName = [userInfo.fields objectForKey:@"Role"];
        roleName = [roleName stringByReplacingOccurrencesOfString:@" " withString:@""];
        configName = [NSString stringWithFormat:@"%@_%@.xml", 
                      [configName substringToIndex:[configName length] - 4],
                      roleName];
    }
    return configName;
}

- (int)getStep {
    return 4;
}

- (BOOL)prepare {
    return YES;
}

- (NSString *)getName {
    return [NSString stringWithFormat:@"%@ : %@", NSLocalizedString(@"READING_REMOTE_CONFIGURATION", nil), [self fixConfigName]];
}

- (NSString *)requestEntity {
    return nil;
}

- (NSNumber *)retryCount {
    return [NSNumber numberWithInt:0];
}

- (NSTimeInterval)getDelay {
    return .01;
}


@end
