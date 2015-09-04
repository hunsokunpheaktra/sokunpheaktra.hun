//
//  EntityManager.h
//
//  Created by Sy Pauv on 10/1/11.
//  Copyright 2011 GAEASYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseManager.h"
#import "IsNullCriteria.h"
#import "Item.h"
#import "LikeCriteria.h"

@interface ParcelEntityManager : NSObject 


+ (void)remove:(Item *)item;
+ (int)getCount:(NSString *)entity;

+ (Item *)find:(NSString *)entity column:(NSString *)column value:(NSString *)value;
+ (Item *)find:(NSString *)entity criterias:(NSDictionary *)criterias;
+ (void)insert:(Item *)item modifiedLocally:(BOOL)modifiedLocally;
+ (void)update:(Item *)item modifiedLocally:(BOOL)modifiedLocally;
+ (NSArray *)list:(NSString *)entity criterias:(NSDictionary *)criterias;
+ (void)initTable;

@end
