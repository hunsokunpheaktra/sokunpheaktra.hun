//
//  Item.m
//  kba
//
//  Created by Sy Pauv on 10/1/11.
//  Copyright 2011 GAEASYS. All rights reserved.
//

#import "Item.h"
#import "ValuesCriteria.h"

@implementation Item

@synthesize entity;
@synthesize fields;
@synthesize attachments;

- (id)init:(NSString *)newEntity fields:(NSDictionary *)newFields {
    
    self = [super init];
    self.entity = newEntity;
    self.fields = [NSMutableDictionary dictionaryWithDictionary:newFields];
    self.attachments = [[NSMutableDictionary alloc]initWithCapacity:1];
    return self;
}

- (id)initCustom:(NSString *)newEntity fields:(NSMutableDictionary *)newFields {
    
    self = [super init];
    self.entity = newEntity;
    self.fields = newFields;
    return self;
}

-(void)dealloc{
    [super dealloc];
    [fields release];
    [attachments release];
}

@end
