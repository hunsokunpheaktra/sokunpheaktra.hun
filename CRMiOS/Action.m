//
//  Action.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 7/21/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "Action.h"


@implementation Action

@synthesize name, entity, fields, clone ,update;

- (id)initWithName:(NSString *)newName {
    self = [super init];
    self.name = newName;
    self.fields = [[NSMutableDictionary alloc] initWithCapacity:1];
    self.clone = NO;
    self.update = NO;
    return self;
}


- (Item *)buildItem:(Item *)source {
    Item *newItem = [[Item alloc] 
                     init:(self.entity != nil ? self.entity : source.entity)
                     fields:(self.clone ? source.fields : nil)];
    if (self.clone) {
        [newItem.fields removeObjectForKey:@"gadget_id"];
        [newItem.fields removeObjectForKey:@"Id"];
    }
    for (NSString *field in [self.fields keyEnumerator]) {
        NSString *formula = [self.fields objectForKey:field];
        NSString *value = [EvaluateTools evaluate:formula item:source];
        if ([value isEqualToString:@"No Match Row Id"]) {
            value = @"";
        }
        [newItem.fields setObject:value forKey:field];
        for (Relation *relation in [Relation getEntityRelations:source.entity]) {
            if ([relation.srcEntity isEqualToString:self.entity] && [relation.srcKey isEqualToString:field]) {
                Item *other = [EntityManager find:relation.destEntity column:relation.destKey value:value];
                if (other != nil) {
                    for (int i = 0; i < [relation.srcFields count]; i++) {
                        NSString *otherValue = [other.fields objectForKey:[relation.destFields objectAtIndex:i]];
                        if (otherValue != nil) {
                            [newItem.fields setObject:otherValue forKey:[relation.srcFields objectAtIndex:i]];
                        }
                    }
                }
            }
        }
    }
    return newItem;
}

@end
