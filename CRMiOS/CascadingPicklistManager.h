//
//  CascadingPicklistManager.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 7/30/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Database.h"

@interface CascadingPicklistManager : NSObject

+ (void)initTable;
+ (void)initData;
+ (void)insert:(NSDictionary *)picklist;
+ (void)purge;
+ (NSArray *)readAllowedValues:(NSString *)field item:(Item *)item;
+ (NSDictionary *)getChildren:(NSString *)entity field:(NSString *)field value:(NSString *)value;

@end
