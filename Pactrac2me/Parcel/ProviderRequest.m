//
//  ProviderRequest.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 1/9/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "ProviderRequest.h"
#import "JSON.h"

@implementation ProviderRequest

-(id)initWithTrackingNo:(NSString*)tn{
    self.trackingNo = tn;
    return [super init];
}

-(NSString*)getRegularExpression{
    return nil;
}

-(NSString*)getMehtod{
    return nil;
}
-(NSString*)getBaseURL{
    return nil;
}
-(NSString*)getBody{
    return nil;
}
-(NSString*)getProviderName{
    return nil;
}

- (NSDictionary *)htmlParser:(NSString*)htmlText {
    return nil;
}

-(ResponseParser*)getParser{
    return nil;
}
- (NSDictionary *)doRequest {
    
    self.webData = [NSMutableData data];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self getBaseURL]]];
    
    //set headers
    if ([[self getProviderName] isEqualToString:@"Fedex"] || [[self getProviderName] isEqualToString:@"Hermes"] || [[self getProviderName] isEqualToString:@"GLS"]) {
        request.HTTPMethod = [self getMehtod];
        request.HTTPBody = [[self getBody] dataUsingEncoding:NSUTF8StringEncoding];
        NSString *bodyLength = [NSString stringWithFormat:@"%d", [self getBody].length];
        [request addValue:bodyLength forHTTPHeaderField:@"Content-Length"];
        [request addValue:@"Content-Type" forHTTPHeaderField:@"application/x-www-form-urlencoded"];

    }
    else {
        [request addValue:@"text/HTML" forHTTPHeaderField: @"Content-Type"];
    }
    
    self.theConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    NSData *urlData;
    NSURLResponse *response;
    NSError *error;
    
    urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSData *data = [[[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSNumber *statusCode = [NSNumber numberWithInt:((NSHTTPURLResponse *)response).statusCode];
    NSLog(@"===> statusCode %@",  [NSNumber numberWithInt:((NSHTTPURLResponse *)response).statusCode]);
    
    if ([[self getProviderName] isEqualToString:@"Fedex"] || [[self getProviderName] isEqualToString:@"Hermes"] || [[self getProviderName] isEqualToString:@"GLS"]) {

        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\x" withString:@""];
        
        if ([[self getProviderName] isEqualToString:@"Hermes"]) {
            jsonString = [jsonString stringByReplacingOccurrencesOfString:@"jQuery172006724570238509642_1359397763922(" withString:@""];
            jsonString = [jsonString stringByReplacingOccurrencesOfString:@")" withString:@""];
        }
        
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\n" withString:@""];
        if ([jsonString hasSuffix:@";"]) jsonString = [jsonString substringToIndex:jsonString.length-1];
        
        SBJSON *parser = [[SBJSON alloc] init];
        // parse the JSON string into an object - assuming json_string is a NSString of JSON data
        NSMutableDictionary *responseData = [parser objectWithString:jsonString error:&error];
        [responseData setObject:statusCode forKey:@"statusCode"];
        [parser release];
        
        return responseData;
        
    }

    NSString* htmlText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSMutableDictionary *responseData = [NSMutableDictionary dictionaryWithDictionary:[self htmlParser:htmlText]];
    [responseData setObject:statusCode forKey:@"statusCode"];
    
    return responseData;

}


@end
