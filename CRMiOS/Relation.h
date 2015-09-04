//
//  Relation.h
//  CRMiPad
//
//  Created by Sy Pauv Phou on 3/30/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Configuration.h"

@interface Relation : NSObject {
    NSString *srcEntity;
    NSString *srcKey;
    NSString *destEntity;
    NSString *destKey;
    NSArray *srcFields;
    NSArray *destFields;
}

@property (nonatomic, retain) NSString *srcEntity;
@property (nonatomic, retain) NSString *srcKey;
@property (nonatomic, retain) NSString *destEntity;
@property (nonatomic, retain) NSString *destKey;
@property (nonatomic, retain) NSArray *srcFields;
@property (nonatomic, retain) NSArray *destFields;

- (id)initWith:(NSString *)newSrcEntity srcKey:(NSString *)newSrcKey destEntity:(NSString *)newDestEntity destKey:(NSString *)newDestKey srcFields:(NSArray *)newSrcFields destFields:(NSArray *)newDestFields;

+ (NSArray *)getEntityRelations:(NSString *)entity;
+ (void)resetRelations;

@end
