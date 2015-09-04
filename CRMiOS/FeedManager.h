//
//  AllFeedItem.h
//  CRMiOS
//
//  Created by Sy Pauv on 11/24/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedItem.h"

@interface FeedManager : NSObject {
    
}

+ (NSArray *)getAllFields;
+ (NSArray *)getFeed;
+ (NSData *)getAvatar:(NSString *)userId;
+ (NSArray *)getAllUserId;
+ (NSArray *)allParentsItem;
+ (void)writeFeed:(NSArray *)feedData;
+ (void)writeAvatar:(NSString *)data forUser:(NSString *)userId;

@end
