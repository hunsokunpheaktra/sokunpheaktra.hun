//
//  SOAPManager.m
//  CRMiPad
//
//  Created by Sy Pauv Phou on 4/6/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "SOAPRequest.h"


@implementation SOAPRequest

@synthesize retryCount;
@synthesize webData;
@synthesize listener;
@synthesize task;

- (id)init:(NSObject <SOAPListener> *)newListener {
    self = [super init];
    self.listener = newListener;
    self.webData = [[NSMutableData alloc] init];
    self.retryCount = [NSNumber numberWithInt:0];
    return self;
}

- (void)doRequest {
    // wait a few milliseconds, if we are retrying
    [NSThread sleepForTimeInterval:[self.retryCount intValue] * [self.retryCount intValue] * .1];

    [self.webData setLength:0];
	NSString *soapMessage = [self generateMessage];
    NSString *address = [NSString stringWithFormat:@"%@/%@", [PropertyManager read:@"URL"], [self getURLSuffix], Nil];
	NSURL *url = [NSURL URLWithString:address];
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
	NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];    
	[theRequest addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[theRequest addValue:[self getSoapAction] forHTTPHeaderField:@"SOAPAction"];
	[theRequest addValue:msgLength forHTTPHeaderField:@"Content-Length"];
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection == Nil) {
		NSLog(@"theConnection is NULL");
	}	
}

- (NSString *)getSoapAction {
    return Nil;
}

- (NSString *)getURLSuffix {
    return @"Services/Integration";
}

- (void)generateBody:(NSMutableString *)soapMessage {
}

- (NSString *)generateMessage {
	NSMutableString *soapMessage = [[NSMutableString alloc] init];
    [soapMessage appendString:@"<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:wsse=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">"
        "<soap:Header>"
        "<wsse:Security>"
        "<wsse:UsernameToken>"];
    [soapMessage appendFormat:@"<wsse:Username>%@</wsse:Username>", [PropertyManager read:@"Login"]];
    [soapMessage appendFormat:@"<wsse:Password Type=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText\">%@</wsse:Password>",[PropertyManager read:@"Password"]];
    [soapMessage appendString:@"</wsse:UsernameToken>"
        "</wsse:Security>"
        "<ClientName xmlns=\"urn:crmondemand/ws\">CRM4Mobile</ClientName>"
        "</soap:Header>"
        "<soap:Body>"];
    [self generateBody:soapMessage];
    [soapMessage appendString:@"</soap:Body>"
                "</soap:Envelope>"];
    
	
    return soapMessage;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    status = ((NSHTTPURLResponse *)response).statusCode;
	[webData setLength: 0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[webData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)nsError
{
    self.retryCount = [NSNumber numberWithInt:[self.retryCount intValue] + 1];
    [listener soapFailure:self errorCode:[NSString stringWithFormat:@"%i", [nsError code]] errorMessage:[nsError localizedDescription]];
	
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{

    NSLog(@"Received %d bytes", [webData length]);
    if (status == 200 || status == 400 || status == 500) {
        ResponseParser *parser = [self getParser];
        [parser setListener:self];
        // CPU intensive parsing must be done in a separate thread, else the user interface is frozen.
        [NSThread detachNewThreadSelector:@selector(parse:) toTarget:parser withObject:self.webData];
        [parser release];
    } else {
        NSString *theXML = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
        NSLog(@"HTTP Status: %d", status);
        NSLog(@"%@", theXML);
        self.retryCount = [NSNumber numberWithInt:[self.retryCount intValue] + 1];
        [listener soapFailure:self errorCode:[NSString stringWithFormat:@"%d", status] errorMessage:[NSString stringWithFormat:@"HTTP Error %d occurred while accessing the server. Please check the server URL.", status]];
    }

}


- (void)parserSuccess:(BOOL)lastPage objectCount:(int)objectCount {
    self.retryCount = [NSNumber numberWithInt:0];
    [self.listener soapSuccess:self lastPage:lastPage objectCount:objectCount];
}

- (void)parserFailure:(NSString *)errorCode errorMessage:(NSString *)errorMessage {
    // let's rework some CRMOD senseless error codes
    
    if ([errorCode isEqualToString:@"wsse:FailedAuthentication"]) {
        errorMessage = @"There was an authentication error. Please check your CRM login and password.";
    }
    if ([errorMessage rangeOfString:@"NSXMLParserErrorDomain"].location!=NSNotFound) {
        errorCode = @"ORACLE_DOWN";
        errorMessage = NSLocalizedString(@"ORACLE_DOWN", @"Oracle server is down.");

    }
    self.retryCount = [NSNumber numberWithInt:[self.retryCount intValue] + 1];
    [self.listener soapFailure:self errorCode:errorCode errorMessage:errorMessage];
}

- (ResponseParser *)getParser {
    return Nil;
}

- (NSString *)getName {
    return NSStringFromClass([self class]);
}

- (void) dealloc
{
    [webData release];
    [super dealloc];
}

- (int) getStep {
    return 100;
}

- (BOOL)prepare {
    return YES;
}

- (NSString *)requestEntity {
    return nil;
}

// Fix CRMOD bugged entity names...
- (NSString *)fixEntity:(NSString *)entity {
    if ([entity isEqualToString:@"ServiceRequest"]) {
        return @"Service Request";
    }
    if ([entity isEqualToString:@"CustomObject1"] || [entity isEqualToString:@"CustomObject2"] || [entity isEqualToString:@"CustomObject3"]) {
        return [NSString stringWithFormat:@"Custom Object %@", [entity substringFromIndex:12]];
    }
    return entity;
}

- (NSTimeInterval)getDelay {
    return .01;
}

@end
