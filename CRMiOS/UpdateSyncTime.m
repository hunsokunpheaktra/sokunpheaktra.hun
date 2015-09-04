//
//  UpdateSyncTime.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/26/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "UpdateSyncTime.h"

@implementation UpdateSyncTime

- (id)init:(NSObject <SOAPListener> *)newListener {
    return [super init:newListener];
}

- (NSString *)getAction {
    return @"updatesync";
}

- (int)getStep {
    return 101;
}

- (BOOL)prepare {
    return YES;
}

- (NSString *)getName {
    return [NSString stringWithFormat:@"%@", NSLocalizedString(@"Update sync", nil)];
}

- (NSString *)requestEntity {
    return nil;
}

- (NSNumber *)retryCount {
    return [NSNumber numberWithInt:0];
}

@end
