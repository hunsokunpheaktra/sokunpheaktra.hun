//
//  LastSyncManager.h
//  CRMiOS
//
//  Created by Arnaud Marguerat on 9/25/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Database.h"

@interface LastSyncManager : NSObject

+ (void)initTable;
+ (void)initData;
+ (void)save:(NSString *)entity date:(NSString *)date;
+ (NSString *)read:(NSString *)entity;
+ (void)clear;

@end
