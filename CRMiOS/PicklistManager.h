//
//  PicklistManager.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/10/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Database.h"
#import "IndustryManager.h"
#import "SalesStageManager.h"
#import "CurrencyManager.h"
#import "CurrentUserManager.h"
#import "LikeCriteria.h"

@interface PicklistManager : NSObject {
    
}

+ (void)initTable;
+ (void)initData;
+ (void)insert:(NSDictionary *)picklist;
+ (void)purge:(NSString *)field entity:(NSString *)entity;
+ (NSArray *)read:(NSString *)entity field:(NSString *)field languageCode:(NSString *)languageCode filterText:(NSString *)filterText;
+ (NSArray *)getPicklist:(NSString *)entity field:(NSString *)field item:(Item *)item;
+ (NSString *)fixCode:(NSString *)codeToFix entity:(NSString *)entity;
+ (NSString *)getPicklistDisplay:(NSString *)entity field:(NSString *)field value:(NSString *)value;
+ (NSArray *)getPicklist:(NSString *)entity field:(NSString *)field item:(Item *)item filterText:(NSString*)filterText;

@end
