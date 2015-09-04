//
//  FeedInfo.h
//  CRMiOS
//
//  Created by Sy Pauv on 11/24/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol FeedInfo <NSObject>
- (NSString *)getComment;
- (NSString *)getUserId;
- (NSString *)getParentId;
- (NSString *)getFullName;
- (NSString *)getEntity;
- (NSString *)getCreatedDate;
- (NSString *)getRecordId;
- (NSString *)getRecordName;
- (NSString *)getId;
- (NSArray *)getChild;

@end
