//
//  EntityRequest.h
//  kba
//
//  Created by Sy Pauv on 10/3/11.
//  Copyright 2011 GAEASYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncListener.h"
#import "SFRequest.h"
#import "InfoFactory.h"
#import "Item.h"
#import "ZKSforce.h"
#import "ZKDescribeField.h"
#import "FieldInfoManager.h"  


@interface EntityRequest : NSObject<SFRequest> {
    NSString *entity;
    NSObject <EntityInfo> *entityInfo;
    NSString *dateFilter;
    NSObject<SyncListener> *listener;
    NSNumber *tasknum;
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

- (id)initWithEntity:(NSString *)newEntity listener:(NSObject<SyncListener>*)newListener level:(int)level;
- (NSMutableDictionary*) filterDictionnary:(NSDictionary *)result;
- (void)didFailLoadWithError:(NSString*)error;
- (NSString *)toBoolValue:(BOOL)val;
- (NSString *)toString:(id) val;
- (NSString *)toInt:(int) val;
- (NSString *)getCriteria:(Item*)item;
-(BOOL) isAbleToQuery :(NSString*) entityName;
-(NSArray*) getMany2OneRelation;
-(NSArray*) getOneToOneRelation ;
-(NSString*) getIdsString :(NSArray*)listItem;

@end
