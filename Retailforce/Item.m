//
//  Item.m
//  kba
//
//  Created by Sy Pauv on 10/1/11.
//  Copyright 2011 GAEASYS. All rights reserved.
//

#import "Item.h"
#import "EntityInfo.h"
#import "InfoFactory.h"
#import "ValuesCriteria.h"
#import "FieldInfoManager.h"

@implementation Item

@synthesize entity;
@synthesize fields;

- (id)init:(NSString *)newEntity fields:(NSDictionary *)newFields {
    
    self = [super init];
    self.entity = newEntity;
    self.fields = [NSMutableDictionary dictionaryWithDictionary:newFields];
    return self;
}

- (id)initCustom:(NSString *)newEntity fields:(NSMutableDictionary *)newFields {
    
    self = [super init];
    self.entity = newEntity;
    self.fields = newFields;
    return self;
}

- (void) dealloc
{
    [self.fields release];
    [self.entity release];
    
    [super dealloc];
}

@end
