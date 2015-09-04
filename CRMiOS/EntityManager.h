//
//  EntityManager.h
//  CRMiPad
//
//  Created by Sy Pauv Phou on 4/1/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Database.h"
#import "CRMField.h"
#import "Configuration.h"
#import "SOAPRequest.h"
#import "EntityInfo.h"
#import "IsNullCriteria.h"
#import "Item.h"
#import "Relation.h"

@interface EntityManager : NSObject {
    
}

+ (void)insert:(Item *)item modifiedLocally:(BOOL)modifiedLocally;
+ (void)update:(Item *)item modifiedLocally:(BOOL)modifiedLocally;
+ (void)setModified:(Item *)item modified:(BOOL)modified;
+ (void)remove:(Item *)item;

+ (NSArray *)list:(NSString *)subtype entity:(NSString *)entity criterias:(NSArray *)criterias additional:(NSArray *)additional limit:(int)limit;
+ (NSArray *)list:(NSString *)subtype entity:(NSString *)entity criterias:(NSArray *)criterias;
+ (NSString *)getLastGadgetId:(NSString *)entity;
+ (Item *)find:(NSString *)entity column:(NSString *)column value:(NSString *)value;
+ (Item *)find:(NSString *)entity criterias:(NSArray *)criterias;
+ (void)initData;
+ (void)initTables;
+ (void)increaseImportance:(Item *)item;


@end
