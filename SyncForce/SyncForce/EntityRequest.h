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
  
@interface EntityRequest : NSObject<SFRequest> {
    NSString *entity;
    NSObject <EntityInfo> *entityInfo;
    NSString *dateFilter;
    NSObject<SyncListener> *listener;
    NSNumber *tasknum;
    Item* currentitem;
}

@property (nonatomic, retain) NSString *entity;
@property (nonatomic, retain) NSObject <EntityInfo> *entityInfo;
@property (nonatomic, retain) NSString *dateFilter;
@property (nonatomic, retain) NSObject <SyncListener> *listener;
@property (nonatomic, retain) NSNumber *tasknum;
@property (nonatomic, retain) Item* currentitem;

- (id)initWithEntity:(NSString *)newEntity listener:(NSObject<SyncListener>*)newListener;
- (NSMutableDictionary*) filterDictionnary:(NSDictionary *)result;
- (void)didFailLoadWithError:(NSString*)error;
- (NSString *)toBoolValue:(BOOL)val;
- (NSString *)toString:(id) val;
- (NSString *)toInt:(int) val;
- (NSString *)getCriteria:(Item*)item;

@end
