//
//  FeedSyncProcess.m
//  CRMiOS
//
//  Created by Sy Pauv on 11/24/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "FeedSyncProcess.h"


@implementation FeedSyncProcess

@synthesize listener;
@synthesize userIds;


- (void)feedSuccess:(BaseRequest *)request {
    [self.listener syncProgress:[[request class] description]];
    if ([request isKindOfClass:[NewFeedRequest class]]) {
        self.userIds = [NSMutableArray arrayWithArray:[FeedManager getAllUserId]];
    }
    while ([userIds count] > 0) {
        NSString *userId = [userIds objectAtIndex:0];
        [self.userIds removeObjectAtIndex:0];
        if ([FeedManager getAvatar:userId] == nil) {
            FeedAvatarRequest *requestAvatar = [[FeedAvatarRequest alloc] initWithUserId:userId];
            [requestAvatar doRequest:self];
            return;
        }
    } 
    [self.listener syncEnd:nil sendReport:NO];
}

- (void)feedFailure:(BaseRequest *)request errorCode:(NSString *)errorCode errorMessage:(NSString *)errorMessage {
    NSLog(@"%@ - %@", errorCode, errorMessage);
    [self.listener syncEnd:[NSString stringWithFormat:@"%@ - %@", errorCode, errorMessage] sendReport:NO];
}

- (void)start:(NSObject <SyncListener> *)newListener {
    
    self.listener = newListener;
    NewFeedRequest *request = [[NewFeedRequest alloc] initWithOffset:[NSNumber numberWithInt:[[FeedManager allParentsItem]count]]];
    [request doRequest:self];
    [self.listener syncStart];
}



@end
