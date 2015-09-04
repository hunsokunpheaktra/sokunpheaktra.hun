//
//  SublistManager.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 11/8/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "SublistManager.h"


@implementation SublistManager

+ (void)insert:(SublistItem *)item locally:(BOOL)locally {
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithDictionary:item.fields];
    [tmp setValue:(locally ? @"1" : @"0") forKey:@"modified"];
    [[Database getInstance] insert:[self getTableName:item.entity sublist:item.sublist] item:tmp];
    
}

+ (void)remove:(SublistItem *)item {
    
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithDictionary:item.fields];
    [tmp setObject:@"1" forKey:@"deleted"];
    
    if ([tmp objectForKey:@"Id"] == nil || [[tmp objectForKey:@"Id"] hasPrefix:@"#"] || (![item updatable] && [[item.fields objectForKey:@"modified"] isEqualToString:@"1"])) {
        [[Database getInstance] remove:[self getTableName:item.entity sublist:item.sublist] column:@"gadget_id" value:[tmp objectForKey:@"gadget_id"]];
    } else {
        if ([tmp objectForKey:@"gadget_id"] != nil) {
            [[Database getInstance] update:[self getTableName:item.entity sublist:item.sublist] item:tmp column:@"gadget_id" value:[tmp objectForKey:@"gadget_id"]];
        } else {
            [[Database getInstance] update:[self getTableName:item.entity sublist:item.sublist] item:tmp column:@"Id" value:[tmp objectForKey:@"Id"]];
        }
    }
}

+ (void)update:(SublistItem *)item locally:(BOOL)locally {
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithDictionary:item.fields];
    [tmp setValue:(locally ? @"1" : @"0") forKey:@"modified"];
    if ([tmp objectForKey:@"gadget_id"] != nil) {
        [[Database getInstance] update:[self getTableName:item.entity sublist:item.sublist] item:tmp column:@"gadget_id" value:[tmp objectForKey:@"gadget_id"]];
    } else {
        NSMutableArray *criterias = [[NSMutableArray alloc] initWithCapacity:1];
        [criterias addObject:[ValuesCriteria criteriaWithColumn:@"Id" value:[tmp objectForKey:@"Id"]]];
        [criterias addObject:[ValuesCriteria criteriaWithColumn:@"parent_oid" value:[tmp objectForKey:@"parent_oid"]]];
        [[Database getInstance] update:[self getTableName:item.entity sublist:item.sublist] item:tmp criterias:criterias];
    }
    [tmp release];
}

+ (SublistItem *)find:(NSString *)entity sublist:(NSString *)sublist criterias:(NSArray *)criterias {
    SublistItem *item = nil;
    NSObject<EntityInfo> *info = [Configuration getInfo:entity];
    NSMutableArray *fields = [[NSMutableArray alloc] initWithArray:[info getSublistFields:sublist]];
    [fields addObject:@"gadget_id"];
    [fields addObject:@"parent_oid"];
    [fields addObject:@"modified"];
    [fields addObject:@"deleted"];
    NSArray *items = [[Database getInstance] select:[self getTableName:entity sublist:sublist] fields:fields criterias:criterias order:Nil ascending:YES];
    if ([items count] > 0) {
        NSDictionary *itemFields = [items objectAtIndex:0];
        item = [[SublistItem alloc] init:entity sublist:sublist fields:itemFields];
    }
    [items release];
    [fields release];
    return item;
}

+ (NSArray *)list:(NSString *)entity sublist:(NSString *)sublist criterias:(NSArray *)criterias {
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:1];
    NSObject<EntityInfo> *info = [Configuration getInfo:entity];
    NSMutableArray *fields = [[NSMutableArray alloc] initWithArray:[info getSublistFields:sublist]];
    [fields addObject:@"gadget_id"];
    [fields addObject:@"parent_oid"];
    [fields addObject:@"modified"];
    [fields addObject:@"deleted"];
    NSMutableArray *newCriterias = [[NSMutableArray alloc] initWithArray:criterias];
    BOOL foundDeleted = NO;
    for (NSObject <Criteria> *criteria in newCriterias) {
        if ([[criteria column] isEqualToString:@"deleted"]) {
            foundDeleted = YES;
            break;
        }
    }
    if (!foundDeleted) {
        [newCriterias addObject:[[[IsNullCriteria alloc] initWithColumn:@"deleted"] autorelease]];
    }
    
    NSArray *records = [[Database getInstance] select:[self getTableName:entity sublist:sublist] fields:fields criterias:newCriterias order:@"Id" ascending:YES];
    for (NSDictionary *record in records) {
        SublistItem *tmpItem = [[SublistItem alloc] init:entity sublist:sublist fields:record];
        [list addObject:tmpItem];
        [tmpItem release];
    }
    [newCriterias release];
    [records release];
    [fields release];
    return list;
}

+ (void)initData {
    
}

+ (void)initTables {
    Database *database = [Database getInstance];
    NSArray *entities = [Configuration getEntities];
    for (NSString *entity in entities) {
        NSObject <EntityInfo> *info = [Configuration getInfo:entity];
        for (NSString *sublist in [info getSublists]) {
            NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
            NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
            [columns addObject:@"gadget_id"];
            [types addObject:@"INTEGER PRIMARY KEY"];
            [columns addObject:@"parent_oid"]; // parent's oracleid
            [types addObject:@"TEXT"];
            [columns addObject:@"modified"];
            [types addObject:@"INTEGER"];
            [columns addObject:@"deleted"];
            [types addObject:@"INTEGER"];
            for (NSString *field in [info getSublistFields:sublist]) {
                [columns addObject:field];
                [types addObject:@"TEXT"];
            }
            [database check:[self getTableName:entity sublist:sublist] columns:columns types:types];
            [columns release];
            [types release];
        }
                
        [database createIndex:entity column:@"Id" unique:false];
    }
}

+ (NSString *)getTableName:(NSString *)entity sublist:(NSString *)sublist {
    return [NSString stringWithFormat:@"%@_%@", entity, sublist];
}

+ (NSDictionary *)getSublists:(Item *)item {
    NSMutableDictionary *sublists = [[NSMutableDictionary alloc] initWithCapacity:1];
    //NSObject <EntityInfo> *info = [Configuration getInfo:item.entity];
    NSString *subtype = [Configuration getSubtype:item];
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:subtype entity:item.entity];
    for (NSObject<Sublist> *confSublist in [sinfo sublists]) {
        NSArray *criterias = [NSArray arrayWithObject:[ValuesCriteria criteriaWithColumn:@"parent_oid" value:[item.fields valueForKey:@"Id"]]];
        NSArray *list = [self list:item.entity sublist:confSublist.name criterias:criterias];
        NSMutableArray *relatedList = [[NSMutableArray alloc] initWithCapacity:1];
        for (SublistItem *sublistItem in list) {
            NSString *displayText = [EvaluateTools evaluate:confSublist.displayText item:sublistItem];
            if (displayText == nil) displayText = @"";
            NSDictionary *relatedItem = [[NSDictionary alloc] initWithObjectsAndKeys:displayText, @"Name", [sublistItem.fields objectForKey:@"gadget_id"], @"gadget_id", nil];   
            [relatedList addObject:relatedItem];
            [relatedItem release];
        }
        [sublists setObject:relatedList forKey:confSublist.name];
        [list release];
        [relatedList release];
    }
    return sublists;
}




@end
