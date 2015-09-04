//
//  SyncTools.h
//  CRMiOS
//
//  Created by Arnaud on 22/05/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SyncTools : NSObject

+ (NSArray *)autoSyncDelays;
+ (NSString *)getDelayDisplayValue:(NSString *)value;

@end
