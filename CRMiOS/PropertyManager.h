//
//  PropertyManager.h
//  CRMiPad
//
//  Created by Sy Pauv Phou on 4/7/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Database.h"
#import "Configuration.h"

@interface PropertyManager : NSObject {
    
}

+ (void)initTable;
+ (void)initData;
+ (void)save:(NSString *)property value:(NSString *)value;
+ (NSString *)read:(NSString *)property;
+ (NSTimeInterval)getAutoSyncTime;

@end
