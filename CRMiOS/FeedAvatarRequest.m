//
//  RequestFeedAvata.m
//  CRMiOS
//
//  Created by Sy Pauv on 11/23/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "FeedAvatarRequest.h"


@implementation FeedAvatarRequest

@synthesize userId;


- (id)initWithUserId:(NSString *)newUserId {
    self = [super init];
    self.userId = newUserId;
    return self;
}

- (NSString *)generateMessage {

    NSMutableString *message = [[NSMutableString alloc]initWithCapacity:1];
    [message appendString:@"<request>"];
    [message appendFormat:@"<userid>%@</userid>",self.userId];
    [message appendString:@"</request>"];
    return message;
    
}

- (NSString *)getSuffix {
    return @"/getavatar";
}

- (NSObject <FeedParser> *)getParser {
    return [[AvatarParser alloc] initWithId:self.userId];
}

@end
