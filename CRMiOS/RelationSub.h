//
//  RelationSub.h
//  CRMiOS
//
//  Created by Arnaud Marguerat on 8/14/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Relation.h"

@interface RelationSub : NSObject {
    Relation *relation;
    NSString *subtype;
    NSString *entity;
    NSString *key;
    NSArray *fields;
    NSString *otherEntity;
    NSString *otherSubtype;
    NSString *otherKey;
}

@property (nonatomic, retain) Relation *relation;
@property (nonatomic, retain) NSString *subtype;
@property (nonatomic, retain) NSString *entity;
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSArray *fields;
@property (nonatomic, retain) NSString *otherEntity;
@property (nonatomic, retain) NSString *otherSubtype;
@property (nonatomic, retain) NSString *otherKey;

- (id)initWith:(Relation *)newRelation subtype:(NSString *)newSubtype entity:(NSString *)newEntity key:(NSString *)newKey fields:(NSArray *)newFields otherEntity:(NSString *)newOtherEntity otherSubtype:(NSString *)newOtherSubtype otherKey:(NSString *)newOtherKey;

@end
