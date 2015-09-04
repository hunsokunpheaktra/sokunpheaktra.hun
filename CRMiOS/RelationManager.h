//
//  RelationManager.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/28/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Relation.h"
#import "RelationSub.h"
#import "EntityManager.h"

#define RELATED_MAX_OBJ 100

@interface RelationManager : NSObject {
    
}

+ (NSArray *)getRelations:(NSString *)subtype entity:(NSString *)entity;
+ (NSDictionary *)getRelatedItems:(Item *)detail;
+ (Item *)getRelatedItem:(NSString *)subtype field:(NSString *)field value:(NSString *)value;
+ (NSString *)getRelatedEntity:(NSString *)subtype field:(NSString *)field;
+ (NSString *)singleField:(NSString *)subtype from:(NSString *)fromSubtype entity:(NSString *)entity;
+ (BOOL)isCalculated:(NSString *)subtype field:(NSString *)field;
+ (BOOL)isKey:(NSString *)subtype field:(NSString *)field;
+ (BOOL)isCreatable:(NSString *)subtype from:(NSString *)subtype entity:(NSString *)entity;

@end
