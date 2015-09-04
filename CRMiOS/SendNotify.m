//
//  SendNotify.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 2/1/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "SendNotify.h"

@implementation SendNotify

@synthesize parentId, comment;

- (id)init:(NSString *)newParentId comment:(NSString *)newComment {
    self.parentId = newParentId;
    self.comment = newComment;
    return [super init];
}

- (NSString *)getSuffix {
    return [NSString stringWithFormat:@"/sendnotify?comment='%@'&userid='%@'",parentId,comment];
}

- (NSObject <FeedParser> *)getParser {
    return nil;
}

@end
