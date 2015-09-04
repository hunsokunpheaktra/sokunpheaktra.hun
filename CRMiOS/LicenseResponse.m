//
//  LicenseResponse.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/25/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "LicenseResponse.h"

@implementation LicenseResponse

- (void)handleTag:(NSString *)tag value:(NSString *)value level:(int)level {
    
    if ([tag isEqualToString:@"valid"] && level==2) {
        [Configuration writeLicense:value];
    }
    
}

@end
