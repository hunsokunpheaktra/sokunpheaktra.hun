//
//  FieldMgmtManager.h
//  CRMiOS
//
//  Created by Arnaud on 1/11/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Database.h"

@interface FieldMgmtManager : NSObject

+ (void)initTable;
+ (void)initData;
+ (void)insert:(NSDictionary *)values;
+ (void)purge;
+ (BOOL)isFormula:(NSString *)entity field:(NSString *)field;
+ (NSArray *)list:(NSString *)entity;

@end
