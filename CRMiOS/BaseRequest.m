//
//  BaseRequest.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 11/29/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "BaseRequest.h"


@implementation BaseRequest

@synthesize webData;
@synthesize listener;
@synthesize status;

- (void)doRequest:(NSObject <FeedListener> *)newListener {
    self.listener = newListener;
    self.webData = [[NSMutableData alloc] init];
	NSString *soapMessage = [self generateMessage];
    NSString *feedURL = [[Configuration getInstance].properties objectForKey:@"feedURL"];
    NSString *address = [NSString stringWithFormat:@"%@%@", feedURL, [self getSuffix]];
	NSURL *url = [NSURL URLWithString:address];
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection == Nil) {
		NSLog(@"theConnection is NULL");
	}	
    NSLog(@"Request sent :\n%@", soapMessage);
    
}

-(NSString *)StringEncode:(NSString *)str{
    str = [[[[[str stringByReplacingOccurrencesOfString: @"&" withString: @"&amp;"]
              stringByReplacingOccurrencesOfString: @"\"" withString: @"&quot;"]
             stringByReplacingOccurrencesOfString: @"'" withString: @"&apos;"]
            stringByReplacingOccurrencesOfString: @">" withString: @"&gt;"]
           stringByReplacingOccurrencesOfString: @"<" withString: @"&lt;"];
    return str;
}

- (NSString *)generateMessage {
    return nil;
}

- (NSString *)getSuffix {
    return nil;
}

- (NSObject <FeedParser> *)getParser {
    return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.status = [NSNumber numberWithInt:((NSHTTPURLResponse *)response).statusCode];
	[self.webData setLength: 0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.webData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)nsError {
    [self.listener feedFailure:self errorCode:[NSString stringWithFormat:@"%i", [nsError code]] errorMessage:[nsError localizedDescription]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    NSLog(@"Finished, status = %d", [self.status intValue]);
    NSString *jsonString =[[NSString alloc] initWithData:webData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",jsonString);
    if ([self.status intValue] == 200) {
        
        NSObject <FeedParser> *parser = [self getParser];
        [parser setRequest:self];
        // CPU intensive parsing must be done in a separate thread, else the user interface is frozen.
        [parser parse:self.webData];
        //[NSThread detachNewThreadSelector:@selector(parse:) toTarget:parser withObject:self.webData];
        [parser release];        
 
        
    } else {
        [listener feedFailure:self errorCode:[NSString stringWithFormat:@"%d", [self.status intValue]] errorMessage:[NSString stringWithFormat:@"HTTP Error %d", [self.status intValue]]];
    }
}

@end
