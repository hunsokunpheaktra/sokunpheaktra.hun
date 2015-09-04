//
//  SyncTask.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 7/21/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol SyncTask <NSObject>

- (int)getStep;
- (BOOL)prepare;
- (NSString *)getName;
- (void)doRequest;
- (void)setTask:(NSNumber *)taskNum;
- (NSNumber *)task;
- (NSString *)requestEntity;
- (NSNumber *)retryCount;
- (NSTimeInterval)getDelay;

@end
