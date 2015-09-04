//
//  SalesProcessManager.h
//  CRMiOS
//
//  Created by Arnaud on 12/20/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Database.h"

@interface SalesProcessManager : NSObject

+ (void)initTable;
+ (void)initData;
+ (void)insert:(NSDictionary *)newSalesProcess;
+ (void)purge;
+ (NSString *)read:(NSString *)type;

@end
