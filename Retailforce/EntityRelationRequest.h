//
//  EntityRelationRequest.h
//  RetailForce
//
//  Created by Gaeasys on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityRequest.h"

@interface EntityRelationRequest :NSObject<SFRequest> {
    NSString *entity;
    NSObject <EntityInfo> *entityInfo;
    NSString *dateFilter;
    NSObject<SyncListener> *listener;
    NSNumber *tasknum;
    NSString *parentEntity;
    NSString *parentId;
    Item* currentitem;
    int level;
}

@property (nonatomic, retain) NSString *entity;
@property (nonatomic, retain) NSObject <EntityInfo> *entityInfo;
@property (nonatomic, retain) NSString *dateFilter;
@property (nonatomic, retain) NSObject <SyncListener> *listener;
@property (nonatomic, retain) NSNumber *tasknum;
@property (nonatomic, retain) Item* currentitem;
@property int level;

- (id)initWithEntity:(NSString *)newEntity parentEntity:(NSString*)pEntity parentId:(NSString*)ids listener:(NSObject<SyncListener>*)newListener level:(int)level;
- (NSMutableDictionary*) filterDictionnary:(NSDictionary *)result;
- (void)didFailLoadWithError:(NSString*)error;
- (NSString *)toBoolValue:(BOOL)val;
- (NSString *)toString:(id) val;
- (NSString *)toInt:(int) val;
- (NSString *)getCriteria:(Item*)item;
-(BOOL) isAbleToQuery :(NSString*) entityName;
-(NSArray*) getMany2OneRelation;
-(NSArray*) getOneToOneRelation;
-(NSString*) getFieldRelation;
-(NSString*) getIdsString :(NSArray*)listItem;

@end
