//
//  LicenseCheck.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/25/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "LicenseCheck.h"

@implementation LicenseCheck

- (id)init:(NSObject <SOAPListener> *)newListener {
    return [super init:newListener];
}

- (NSString *)getAction{
    return @"getlicense";
}

- (int)getStep {
    return 2;
}

- (BOOL)prepare {
    return YES;
}

- (NSString *)getName {
    return NSLocalizedString(@"CHECKING_LICENSE", nil);
}

- (NSString *)requestEntity {
    return nil;
}

- (NSNumber *)retryCount {
    return [NSNumber numberWithInt:0];
}

- (ResponseParser *)getParser {
    return [[LicenseResponse alloc]init];
}

@end
