//
//  PropertyManager.h
//  Datagrid
//
//  Created by Sy Pauv on 10/5/11.
//  Copyright 2011 GAEASYS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DatabaseManager.h"
#define K_USERTIMEZONE @"TimeZoneSidKey"
#define K_CURRENCYISOCODE @"CurrencyIsoCode"

#define K_CURRENTUSERID @"CurrentUserId"

#define DEFAULT_HOST            @"yes"
#define DEFAULT_MERGE_MODULE    @"yes"

@interface PropertyManager : NSObject {
    
}

+ (void)initTable;
+ (void)initDatas;
+ (void)save:(NSString *)property value:(NSString *)value;
+ (NSString *)read:(NSString *)property;

 
@end
