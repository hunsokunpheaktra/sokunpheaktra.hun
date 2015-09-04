//
//  SOAPListener.h
//  CRMiPad
//
//  Created by Sy Pauv Phou on 4/8/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncTask.h"


@protocol SOAPListener <NSObject>

- (void)soapSuccess:(NSObject <SyncTask> *)request lastPage:(BOOL)lastPage objectCount:(int)objectCount;
- (void)soapFailure:(NSObject <SyncTask> *)request errorCode:(NSString *)errorCode errorMessage:(NSString *)errorMessage;

@end
