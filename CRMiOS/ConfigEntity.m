//
//  ConfigEntity.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 7/8/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "ConfigEntity.h"


@implementation ConfigEntity

@synthesize name;
@synthesize searchField, searchField2;
@synthesize fields;

- (id)initWithEntity:(NSString *)newEntity {
    self = [super init];
    self.name = newEntity;
    self.fields = [[NSMutableArray alloc] initWithCapacity:1];
    [self.fields addObject:@"Id"];
    [self.fields addObject:@"ModifiedDate"];
    self.enabled = YES;
    
    self.canCreate = YES;
    self.canDelete = YES;
    self.canUpdate = YES;
    self.hidden = NO;
    return self;
}


- (NSArray *)getSubtypes {
    NSMutableArray *subtypes = [[NSMutableArray alloc] initWithCapacity:1];
    for (ConfigSubtype *subtype in [Configuration getInstance].subtypes) {
        if ([subtype.entity isEqualToString:self.name]) {
            [subtypes addObject:subtype];
        }
    }
    return subtypes;
}

- (NSArray *)getSublists {
    NSMutableArray *sublists = [[NSMutableArray alloc] initWithCapacity:1];
    for (ConfigSubtype *subtype in [self getSubtypes]) {
        for (ConfigSublist *sublist in subtype.sublists) {
            if ([sublists indexOfObject:sublist.name] == NSNotFound) {
                [sublists addObject:sublist.name];
            }
        }
    }
    return sublists;
}

- (NSArray *)getSublistFields:(NSString *)sublistName {
    NSMutableArray *sublistFields = [[NSMutableArray alloc] initWithCapacity:1];
    [sublistFields addObject:@"Id"];
    NSArray *subtypes = [self getSubtypes];
    for (ConfigSubtype *subtype in subtypes) {
        for (ConfigSublist *sublist in subtype.sublists) {
            if ([sublist.name isEqualToString:sublistName]) {
                NSArray *titleFields = [EvaluateTools getFieldsFromFormula:sublist.displayText];
                for (NSString *field in titleFields) {
                    if ([sublistFields indexOfObject:field] == NSNotFound) {
                        [sublistFields addObject:field];
                    }
                }
                [titleFields release];
                for (NSString *field in sublist.fields) {
                    if ([sublistFields indexOfObject:field] == NSNotFound) {
                        [sublistFields addObject:field];
                    }
                }
            }
        }
    }
    [subtypes release];
    
    NSString *sublistCode = [NSString stringWithFormat:@"%@ %@", self.name, sublistName];
    NSArray *relations = [Relation getEntityRelations:sublistCode];
    NSString *fieldToAdd;
    do {
        fieldToAdd = nil;
        for (NSString *field in sublistFields) {
            for (Relation *relation in relations) {
                if ([relation.srcEntity isEqualToString:sublistCode]) {
                    if ([relation.srcFields containsObject:field]) {
                        if ([sublistFields indexOfObject:relation.srcKey] == NSNotFound) {
                            fieldToAdd = relation.srcKey;
                            break;
                        }
                        for (NSString *srcField in relation.srcFields) {
                            if ([sublistFields indexOfObject:srcField] == NSNotFound) {
                                fieldToAdd = srcField;
                                break;
                            }
                            if (fieldToAdd != nil) break;
                        }
                    }
                }
            }
        }
        if (fieldToAdd != nil) {
            [sublistFields addObject:fieldToAdd];
        }
    } while (fieldToAdd != nil);
    [relations release];
    return sublistFields;
}



@end
