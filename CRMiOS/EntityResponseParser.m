//
//  XMLParser.m
//  CRMiPad
//
//  Created by Sy Pauv Phou on 4/8/11.
//  Copyright 2011 Fellow Consulting . All rights reserved.
//

#import "EntityResponseParser.h"

@implementation EntityResponseParser

@synthesize entity;
@synthesize sublist;
@synthesize fields;
@synthesize sublistFields;


- (id)initWithEntity:(NSString *)newEntity {
    self = [super init];
    self.entity = newEntity;
    self.fields = [[NSMutableDictionary alloc] initWithCapacity:1];
    self.sublistFields = [[NSMutableDictionary alloc] initWithCapacity:1];
    return self;
}



- (void)handleAttributes:(NSString *)tag attributes:(NSDictionary *)attributes level:(int)level {
    if ([[attributes objectForKey:@"lastpage"] isEqualToString:@"false"]) {
        self.lastPage = [NSNumber numberWithBool:NO];
    }
    if (level == 6 && [tag hasPrefix:@"ListOf"]) {
        self.sublist = [tag substringFromIndex:6];
    }
}


- (void)handleTag:(NSString *)tag value:(NSString *)value level:(int)level {
    if (level==5 && [tag isEqualToString:self.entity]) {
        Item *item = [[Item alloc] init:self.entity fields:self.fields];
        [self oneMoreItem];
        Item *existing = [EntityManager find:self.entity column:@"Id" value:[self.fields objectForKey:@"Id"]];
        if (existing == Nil) { 
            [EntityManager insert:item modifiedLocally:NO];
        } else {
            [EntityManager update:item modifiedLocally:NO];
        }
        [existing release];
        [item release];
        [self.fields removeAllObjects];
    }
    if (level==6) {
        if (![tag hasPrefix:@"ListOf"]) {
            [self.fields setObject:value forKey:tag];
        } else {
            self.sublist = nil;
        }
    }
    if (level == 7) {
        if (self.sublist != nil) {
            [self.sublistFields setObject:[self.fields objectForKey:@"Id"] forKey:@"parent_oid"];
            SublistItem *item = [[SublistItem alloc] init:self.entity sublist:tag fields:self.sublistFields];
            NSMutableArray *criterias = [[NSMutableArray alloc] initWithCapacity:1];
            [criterias addObject:[ValuesCriteria criteriaWithColumn:@"Id" value:[self.sublistFields objectForKey:@"Id"]]];
            [criterias addObject:[ValuesCriteria criteriaWithColumn:@"parent_oid" value:[self.sublistFields objectForKey:@"parent_oid"]]];
            SublistItem *existing = [SublistManager find:self.entity sublist:tag criterias:criterias];
            if (existing == nil) {
                [SublistManager insert:item locally:NO];
            } else {
                [SublistManager update:item locally:NO];
            }
            [existing release];
            [item release];
            [self.sublistFields removeAllObjects];
        }
    }
    if (level == 8) {
        if (self.sublist != nil) {
            [self.sublistFields setObject:value forKey:tag];
        }
    }
}



- (void) dealloc
{
    [self.fields release];
    [super dealloc];
}

@end
