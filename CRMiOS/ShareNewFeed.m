//
//  ShareNewFeed.m
//  CRMiOS
//
//  Created by Sy Pauv on 11/28/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "ShareNewFeed.h"

@implementation ShareNewFeed

@synthesize parentId, comment;

- (id)init:(NSString *)newParentId comment:(NSString *)newComment {
    self.parentId = newParentId;
    self.comment = newComment;
    return [super init];
}
 
- (NSString *)generateMessage {
    
    NSMutableString *message = [[NSMutableString alloc] initWithCapacity:1];
    [message appendString:@"<request>"];
    [message appendString:@"<action>1</action>"];
    [message appendFormat:@"<userid>%@</userid>",[[CurrentUserManager read] objectForKey:@"UserId"]];
    if (self.parentId!=nil) [message appendFormat:@"<parentid>%@</parentid>", self.parentId];
    [message appendFormat:@"<createddate>%.lf000</createddate>",[[NSDate date] timeIntervalSince1970] ];
    [message appendFormat:@"<fullname>%@</fullname>",[[CurrentUserManager read] objectForKey:@"Alias"]];
    [message appendFormat:@"<comment>%@</comment>", [self StringEncode:self.comment]];
    [message appendString:@"</request>"];
    return message;
    
}

- (NSString *)getSuffix {
    return @"/statusupdate";
}
  
    
- (NSObject <FeedParser> *)getParser {
    return [[ShareNewFeedParser alloc] init];
}

@end
