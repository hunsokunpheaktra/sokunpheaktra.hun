//
//  FeedSoupRequest.m
//  CRMiOS
//
//  Created by Sy Pauv on 11/23/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "NewFeedRequest.h"

@implementation NewFeedRequest
@synthesize offset;

- (id)initWithOffset:(NSNumber *)newOffset{
    
    self.offset=newOffset;
    return [super init];
    
}

- (NSString *)generateMessage {
    
    NSMutableString *message = [[NSMutableString alloc] initWithCapacity:1];
    [message appendString:@"<request>"];
    [message appendString:@"<action>3</action>"];
    if (self.offset!=nil)[message appendFormat:@"<offset>%@</offset>",self.offset];
    [message appendString:@"<userid>"];
    [message appendFormat:@"%@",[[CurrentUserManager read] objectForKey:@"UserId"]];
    [message appendString:@"</userid>"];
    [message appendString:@"</request>"];
    return message;
    
}

- (NSString *)getSuffix {
    return @"/statusupdate";
}

- (NSObject<FeedParser> *)getParser {
    return [[NewFeedResponseParser alloc] init];
}

@end
