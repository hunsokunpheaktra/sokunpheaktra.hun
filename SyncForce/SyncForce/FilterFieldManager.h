//
//  FilterFieldManager.h
//  SyncForce
//
//  Created by Gaeasys on 1/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"


@interface FilterFieldManager : NSObject

+ (void)insert:(Item *)item;
+(void)remove:(NSString*)entity;

+ (void)initData;
+ (void)initTable;

+ (NSArray *)list:(NSDictionary *)criterias;
+ (Item *)find:(NSDictionary *)criterias;

@end
