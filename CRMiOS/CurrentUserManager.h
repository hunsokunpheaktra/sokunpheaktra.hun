//
//  CurrentUserManager.h
//  CRMiOS
//
//  Created by Sy Pauv on 7/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Database.h"
#import "EntityManager.h"
#import "Item.h"

@interface CurrentUserManager : NSObject {

}

+ (void)initTable;
+ (void)initData;
+ (void)upsert:(NSDictionary *)newItem;
+ (NSDictionary *)read;
+ (NSString *)getLanguageCode;
+ (NSTimeZone *)getUserTimeZone;  
+ (Item *)getCurrentUserInfo;
+ (NSString *)getSalesProcessId;

@end
