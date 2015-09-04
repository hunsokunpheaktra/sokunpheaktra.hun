//
//  FeedResponseParser.m
//  CRMiOS
//
//  Created by Sy Pauv on 11/24/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "NewFeedResponseParser.h"


@implementation NewFeedResponseParser

@synthesize allFeed;


- (id)init {
    self = [super init];
    self.allFeed = [[NSMutableArray alloc]initWithArray:[FeedManager getFeed]];
    return self;
}

- (void)endDocument {
    [FeedManager writeFeed:self.allFeed];
}

- (void)beginTag:(NSString *)tag {    
    if ([tag isEqualToString:@"result"]) {
        [self.allFeed addObject:[[FeedItem alloc]init]];
    }
}

- (void)endTag:(NSString *)tag {
    FeedItem *feedItem = [self.allFeed lastObject];
    if ([[FeedManager getAllFields] containsObject:tag]) {
        [feedItem.data setObject:currentText forKey:tag];
    }
}


- (void) dealloc {
    [self.allFeed release];
    [super dealloc];
}


@end
