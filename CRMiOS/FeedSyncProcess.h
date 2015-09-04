//
//  FeedRequestProcess.h
//  CRMiOS
//
//  Created by Sy Pauv on 11/24/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseRequest.h"
#import "NewFeedRequest.h"
#import "SyncListener.h"
#import "NewFeedRequest.h"
#import "FeedAvatarRequest.h"


@interface FeedSyncProcess : NSObject<FeedListener> {
    
    NSObject <SyncListener> *listener;
    NSMutableArray *userIds;

}

@property (nonatomic, retain) NSObject <SyncListener> *listener;
@property (nonatomic, retain) NSMutableArray *userIds;

- (void)start:(NSObject <SyncListener> *)listener;


@end
