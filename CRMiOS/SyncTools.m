//
//  SyncTools.m
//  CRMiOS
//
//  Created by Arnaud on 22/05/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import "SyncTools.h"

@implementation SyncTools

+ (NSArray *)autoSyncDelays {
    return [[NSArray alloc] initWithObjects:@"0", @"15", @"30", @"60", @"120", @"240", @"480", @"720", nil];
}


+ (NSString *)getDelayDisplayValue:(NSString *)value {
    int minutes = [value intValue];
    if (minutes == 0) {
        return NSLocalizedString(@"DISABLED", nil);
    } else if (minutes < 120) {
        return [NSString stringWithFormat:NSLocalizedString(@"EVERY_MINUTES", nil), minutes];
    } else {
        return [NSString stringWithFormat:NSLocalizedString(@"EVERY_HOURS", nil), minutes / 60];
    }
}

@end
