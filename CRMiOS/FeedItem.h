//
//  FeedItem.h
//  CRMiOS
//
//  Created by Sy Pauv on 11/23/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedInfo.h"
#import "Base64.h"
#import "FeedManager.h"

@interface FeedItem : NSObject<FeedInfo> {    
    NSMutableDictionary *data;
    NSNumber *istmpItem;
}

@property (nonatomic, retain) NSNumber *istmpItem;
@property (nonatomic, retain) NSMutableDictionary *data; 

- (id)init;
- (NSDate *)getCreatedDate;
- (NSString *)getCreatedDateFormatted;

@end
