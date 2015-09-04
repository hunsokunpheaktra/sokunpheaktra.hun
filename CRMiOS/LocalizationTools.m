//
//  LocalizationTools.m
//  CRMiOS
//
//  Created by Arnaud Marguerat on 10/2/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "LocalizationTools.h"

@implementation LocalizationTools


+ (NSString *)getLocalizedName:(NSString *)entity {
    NSString *pluralCode = [NSString stringWithFormat:@"%@_SINGULAR", 
                            entity];
    NSString *tmp = NSLocalizedString(pluralCode, @"singular name"); 
    if ([tmp rangeOfString:@"_SINGULAR"].location != NSNotFound) {
        return entity;
    }
    return tmp;
}

@end
