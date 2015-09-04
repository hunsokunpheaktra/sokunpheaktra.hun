//
//  RelationSub.m
//  CRMiOS
//
//  Created by Arnaud Marguerat on 8/14/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "RelationSub.h"

@implementation RelationSub

@synthesize key;
@synthesize fields;
@synthesize subtype;
@synthesize entity;
@synthesize otherKey;
@synthesize otherEntity;
@synthesize otherSubtype;
@synthesize relation;


- (id)initWith:(Relation *)newRelation subtype:(NSString *)newSubtype entity:(NSString *)newEntity key:(NSString *)newKey fields:(NSArray *)newFields otherEntity:(NSString *)newOtherEntity otherSubtype:(NSString *)newOtherSubtype otherKey:(NSString *)newOtherKey {
    self = [super init];
    self.relation = newRelation;
    self.entity = newEntity;
    self.subtype = newSubtype;
    self.key = newKey;
    self.fields = newFields;
    self.otherEntity = newOtherEntity;
    self.otherSubtype = newOtherSubtype;
    self.otherKey = newOtherKey;

    return self;
    
}

@end
