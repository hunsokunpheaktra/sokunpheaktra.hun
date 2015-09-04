//
//  EntityManager.h
//
//  Created by Sy Pauv on 10/1/11.
//  Copyright 2011 GAEASYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseManager.h"
#import "InfoFactory.h"
#import "EntityInfo.h"
#import "IsNullCriteria.h"
#import "Item.h"
#import "LikeCriteria.h"


@interface EntityManager : NSObject {
    
}


+ (void)insert:(Item *)item modifiedLocally:(BOOL)modifiedLocally;
+ (void)update:(Item *)item modifiedLocally:(BOOL)modifiedLocally;
+ (void)remove:(Item *)item;

+ (NSArray *)list:(NSString *)entity criterias:(NSDictionary *)criterias;
+ (NSArray *)listBySQL:(NSString *)entity statement:(NSString *)statement criterias:(NSDictionary *)criterias fields:(NSArray *)fields;
+ (Item *)find:(NSString *)entity column:(NSString *)column value:(NSString *)value;
+ (Item *)find:(NSString *)entity criterias:(NSDictionary *)criterias;
+ (void)initData;
+ (void)initTables;
+ (void)initTable:(NSString*)entity column:(NSArray*)newColumns type:(NSArray*)newTypes;
+ (void)setModified:(Item *)item modified:(BOOL)modified;
+ (int) getCount:(NSString *)entity; 

@end
