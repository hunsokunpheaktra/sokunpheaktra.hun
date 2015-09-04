//
//  LoginRequest.m
//  CRMiOS
//
//  Created by Sy Pauv on 5/23/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "LoginRequest.h"


@implementation LoginRequest

@synthesize webData, listener;

- (void)doRequest:(NSObject <LoginListener> *)newListener {
    self.listener = newListener;
    self.webData = [[NSMutableData alloc] init];
    NSString *address = [NSString stringWithFormat:@"%@/%@", [PropertyManager read:@"URL"], [self getURLSuffix]];
	NSURL *url = [NSURL URLWithString:address];
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];   
	
    [theRequest addValue:[PropertyManager read:@"Login"] forHTTPHeaderField:@"UserName"];
    [theRequest addValue:[PropertyManager read:@"Password"] forHTTPHeaderField:@"Password"];
	[theRequest setHTTPMethod:@"POST"];
    
    [self.listener updateSyncButton:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection == Nil) {
		NSLog(@"theConnection is NULL");
	}
	
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    status = ((NSHTTPURLResponse *)response).statusCode;
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[webData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)nsError {
    if (nsError.code == -1202) {
        [self loginEnd:NSLocalizedString(@"BAD_SERVER", nil)];
    } else {
        [self loginEnd:[nsError localizedDescription]];
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (status == 200) {
        // Success
        [self loginEnd:nil];
    } else if (status == 500) {
        ResponseParser *errorParser = [[ResponseParser alloc] init];
        errorParser.listener = self;
        [errorParser parse:webData];
    } else {
        // TODO translate this
        [self loginEnd:[NSString stringWithFormat:@"HTTP Error %d occurred while accessing the server. Please check the server URL.", status]];
    }
}

- (void)parserSuccess:(BOOL)lastPage objectCount:(int)objectCount {
    // should never occur...
    [self loginEnd:@"Unexpected error"];
}

- (void)parserFailure:(NSString *)errorCode errorMessage:(NSString *)errorMessage {
    [self loginEnd:errorMessage];
}

- (NSString *)getURLSuffix {
    return @"Services/Integration?command=login";
}

- (void)loginEnd:(NSString *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [listener updateSyncButton: NO];
    if (error == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CONNECTION_TEST", "Connection test") message:NSLocalizedString(@"CONNECTION_TEST_SUCCESS", "Connection test successful") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CONNECTION_TEST", "Connection test") message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}


- (void) dealloc
{
    [webData release];
    [super dealloc];
}

@end
