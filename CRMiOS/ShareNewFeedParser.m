//
//  ShareNewFeedParser.m
//  CRMiOS
//
//  Created by Sy Pauv on 11/28/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "ShareNewFeedParser.h"
#import "FeedItem.h"

@implementation ShareNewFeedParser

- (void)endTag:(NSString *)tag {
    if ([tag isEqualToString:@"id"]) {
        
        NSMutableArray *tmp=[[NSMutableArray alloc]initWithArray:[FeedManager getFeed]];
        for (FeedItem *item in tmp) {
            if ([item.istmpItem boolValue]) {
                [item.data setObject:currentText forKey:@"gid"];
                item.istmpItem=[NSNumber numberWithBool:NO];
            }
        }
        [FeedManager writeFeed:tmp];
        [tmp release];
    }
}

@end
