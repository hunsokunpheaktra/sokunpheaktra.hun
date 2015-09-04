//
//  FaceBookSearch
//  CRMiOS
//
//  Created by Sy Pauv Phou on 11/29/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "FaceBookSearch.h"
#import "JSON.h"

@implementation FaceBookSearch

@synthesize webData;
@synthesize listener;
@synthesize status;

- (void)doRequest:(NSObject <FacebookListener> *)newListener :(NSString *)urlstr {
    self.listener = newListener;
    self.webData = [[NSMutableData alloc] init];
	NSURL *url = [NSURL URLWithString:urlstr];
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
	[theRequest setHTTPMethod:@"GET"];
	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection == Nil) {
		NSLog(@"theConnection is NULL");
	}	
    NSLog(@"Request sent :\n%@", url);
    
}

- (NSString *)generateMessage {
    return nil;
}

- (NSString *)getSuffix {
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
    //[self.listener feedFailure:self errorCode:[NSString stringWithFormat:@"%i", [nsError code]] errorMessage:[nsError localizedDescription]];
    
    [self.listener field:[NSString stringWithFormat:@"%@", [nsError localizedDescription]]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    NSString *jsonString =[[NSString alloc] initWithData:self.webData encoding:NSUTF8StringEncoding];
   
    NSLog(@"Finished, status = %d", [self.status intValue]);
    if ([self.status intValue] == 200) {
        // Create SBJSON object to parse JSON
        SBJSON *parser = [[SBJSON alloc] init];
        // parse the JSON string into an object - assuming json_string is a NSString of JSON data
        NSMutableDictionary *result = [parser objectWithString:jsonString error:nil];
        [self.listener complete:[result objectForKey:@"data"]];
        
    } else {
      
        
    }
    
}

@end
