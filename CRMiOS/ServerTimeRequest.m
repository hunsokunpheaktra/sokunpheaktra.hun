//
//  ServerTimeRequest.m
//  CRMiOS
//
//  Created by Sy Pauv on 7/13/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "ServerTimeRequest.h"

@implementation ServerTimeRequest

- (id)initWithListener:(NSObject <SOAPListener> *)newListener {
    return [super init:newListener];
}

- (NSString *)getSoapAction {
    return @"\"document/urn:crmondemand/ws/time/:GetServerTime\"";
}

- (void)generateBody:(NSMutableString *)soapMessage {
    
    [soapMessage appendString:@"<TimeWS_GetServerTime_Input xmlns='urn:crmondemand/ws/time/'/>"];
}

- (ResponseParser *)getParser {
    
    return [[ServerTimeResponseParser alloc] init];

}
- (int)getStep {
    return 1;
}

- (NSString *)getURLSuffix {
    return @"Services/Integration";
}

- (NSString *)getName {
    return NSLocalizedString(@"READING_SERVER_TIME", @"READING_SERVER_TIME");
}

@end
