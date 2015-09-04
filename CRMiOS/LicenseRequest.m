//
//  LicenseRequest.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/26/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "LicenseRequest.h"

@implementation LicenseRequest
@synthesize task;
@synthesize callNum;
@synthesize webData;
@synthesize listener;
@synthesize status;


- (id)init:(NSObject <SOAPListener> *)newListener {
    self = [super init];
    self.listener = newListener;
    return self;
}

- (void)doRequest {
    
    self.webData = [[NSMutableData alloc] init];
    NSString *address = [NSString stringWithFormat:@"%@%@", LICENSE_URL, [self getURLSuffix]];
    NSString* escapedUrlString = [address stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding];
	NSURL *url = [NSURL URLWithString:escapedUrlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"GET"];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if (theConnection == Nil) {
		NSLog(@"theConnection is NULL");
	}	
}


- (NSString *)getURLSuffix {
    
    NSString *url = [[PropertyManager read:@"URL"] substringWithRange:NSMakeRange(15, 9)];
    NSString *login = [PropertyManager read:@"Login"];
    NSString *company = login, *user = nil; 
    if ([company rangeOfString:@"/"].location != NSNotFound) {
        NSArray *parts = [company componentsSeparatedByString:@"/"];
        company = [parts objectAtIndex:0];
        user = [parts objectAtIndex:1];
    }
    if ([company rangeOfString:@"\\"].location != NSNotFound) {
        NSArray *parts = [company componentsSeparatedByString:@"\\"];
        company = [parts objectAtIndex:0];
        user = [parts objectAtIndex:1];
    }
    
    NSString *device = [self getDeviceName];
    return  [NSString stringWithFormat:@"/%@?url=%@&company=%@&device=%@&user=%@", [self getAction], url, company, device, user];
    
}

- (NSString *)getAction {

    return NSStringFromClass([self class]);

}


- (NSString *)getDeviceName {
    
    //determine device's type ipad/iphone
    BOOL iPad = NO;
    #ifdef UI_USER_INTERFACE_IDIOM
        iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    #endif
    return [NSString stringWithFormat:@"CRM %@", iPad ? @"ipad" : @"iphone"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if ([self.status intValue] == 200) {
        ResponseParser *parser = [self getParser];
        if (parser!=nil) {
            [parser setListener:self];
            [parser parse:self.webData];
            [parser release];
        }
        [self.listener soapSuccess:self lastPage:YES objectCount:1]; 
    }else{
  
        NSString *theXML = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
        NSLog(@"HTTP Status: %d", [status intValue]);
        NSLog(@"%@", theXML);
        
        [Configuration writeLicense:@"yes"];
        [self.listener soapSuccess:self lastPage:YES objectCount:1]; 
       
    }
       
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.status = [NSNumber numberWithInt:((NSHTTPURLResponse *)response).statusCode];
	[self.webData setLength: 0];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)nsError
{
    [listener soapFailure:self errorCode:[NSString stringWithFormat:@"%i", [nsError code]] errorMessage:[nsError localizedDescription]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [webData appendData:data];
}

- (int)getStep {
    return 100;
}

- (BOOL)prepare {
    return YES;
}

- (NSString *)getName {
    return @"";
}

- (NSString *)requestEntity {
    return nil;
}

- (NSNumber *)retryCount {
    return [NSNumber numberWithInt:0];
}

- (ResponseParser *)getParser {
    return nil;
}

- (void)parserSuccess:(BOOL)lastPage objectCount:(int)objectCount {
    
    [self.listener soapSuccess:self lastPage:lastPage objectCount:objectCount];
    
}

- (void)parserFailure:(NSString *)errorCode errorMessage:(NSString *)errorMessage {
    
    [self.listener soapFailure:self errorCode:errorCode errorMessage:errorMessage];
    
}

- (void)dealloc{
    [self.webData release];
    [super dealloc];
}

- (NSTimeInterval)getDelay {
    return .01;
}

@end
