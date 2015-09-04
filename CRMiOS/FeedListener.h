//
//  FeedListener.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 11/29/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol FeedListener <NSObject>

- (void)feedSuccess:(NSObject *)request;
- (void)feedFailure:(NSObject *)request errorCode:(NSString *)errorCode errorMessage:(NSString *)errorMessage;

@end
