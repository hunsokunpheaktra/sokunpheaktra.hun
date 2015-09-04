//
//  EntityManager.m
//  CRMiPad
//
//  Created by Sy Pauv Phou on 4/1/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "EntityManager.h"


@implementation EntityManager

+ (NSArray *)list:(NSString *)subtype entity:(NSString *)entity criterias:(NSArray *)criterias {
    return [EntityManager list:subtype entity:entity criterias:criterias additional:nil limit:0];
}


+ (NSArray *)list:(NSString *)subtype entity:(NSString *)entity criterias:(NSArray *)criterias additional:(NSArray *)additional limit:(int)limit {
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:1];
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:subtype entity:entity];
    NSMutableArray *fields = [[NSMutableArray alloc] initWithArray:[sinfo listFields]];
    [fields addObject:@"gadget_id"];
    [fields addObject:@"modified"];
    [fields addObject:@"error"];
    [fields addObject:@"favorite"];
    [fields addObject:@"Important"];
    if (additional != nil) {
        for (NSString *add in additional) {
            if (![fields containsObject:add]) {
                [fields addObject:add];
            }
        }
    }

    NSMutableArray *newCriterias = [[NSMutableArray alloc] initWithArray:criterias];
    BOOL foundDeleted = NO;
    BOOL isImportant = NO;
    
    //find important filter
    for (NSObject <Criteria> *criteria in newCriterias) {
        if ([[criteria column] isEqualToString:@"Important"]) {
            isImportant = YES;
            break;
        }
    }
    
    for (NSObject <Criteria> *criteria in newCriterias) {
        if ([[criteria column] isEqualToString:@"deleted"]) {
            foundDeleted = YES;
            break;
        }
    }
    
    if (!foundDeleted) {
        [newCriterias addObject:[[[IsNullCriteria alloc] initWithColumn:@"deleted"] autorelease]];
    }
       
    [newCriterias addObjectsFromArray:[sinfo getCriterias]];
    NSArray *records;
    
    if (isImportant) {
        records = [[Database getInstance] select:[sinfo entity] fields:fields criterias:newCriterias order:@"Important" ascending:NO limit:limit];
    } else {
        records = [[Database getInstance] select:[sinfo entity] fields:fields criterias:newCriterias order:[sinfo getOrderField] ascending:[sinfo orderAscending] limit:limit];
    }
    
    for (NSDictionary *record in records) {
        Item *tmpItem = [[Item alloc] init:[sinfo entity] fields:record];
        [list addObject:tmpItem];
        [tmpItem release];
    }
    [newCriterias release];
    [records release];
    [fields release];
    return list;
}

+ (NSString *)getLastGadgetId:(NSString *)entity {
    NSArray *items = [[Database getInstance] selectSql:[NSString stringWithFormat:@"SELECT MAX(gadget_id) FROM %@",entity] params:nil fields:[NSArray arrayWithObject:@"gadget_id"]];
    if([items count] > 0){
        NSDictionary *itemFields = [items objectAtIndex:0];
        return [itemFields objectForKey:@"gadget_id"];
    }
    return nil;
}

+ (Item *)find:(NSString *)entity column:(NSString *)column value:(NSString *)value {
    NSMutableArray *criterias = [[NSMutableArray alloc] initWithCapacity:1];
    [criterias addObject:[ValuesCriteria criteriaWithColumn:column value:value]];
    Item *result = [self find:entity criterias:criterias];
    [criterias release];
    return result;
}

+ (Item *)find:(NSString *)entity criterias:(NSArray *)criterias {
    Item *item = nil;
    NSMutableArray *fields = [[NSMutableArray alloc] initWithArray:[[Configuration getInfo:entity] fields]];
    [fields addObject:@"gadget_id"];
    [fields addObject:@"modified"];
    [fields addObject:@"error"];
    [fields addObject:@"favorite"];
    [fields addObject:@"Important"];
    NSArray *items = [[Database getInstance] select:entity fields:fields criterias:criterias order:Nil ascending:YES];
    if ([items count] > 0) {
        NSDictionary *itemFields = [items objectAtIndex:0];
        item = [[Item alloc] init:entity fields:itemFields];
    }
    [items release];
    [fields release];
    return item;
}

+ (void)insert:(Item *)item modifiedLocally:(BOOL)modifiedLocally {
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithDictionary:item.fields];
    NSString *searchField = [[Configuration getInfo:item.entity] searchField];
    NSString *searchField2= [[Configuration getInfo:item.entity] searchField2];
    NSString *uppercaseValue = [[item.fields objectForKey:searchField] uppercaseString];
    [tmp setValue:uppercaseValue forKey:@"search"];
    if (searchField2 != nil) {
        NSString *uppercaseValue2 = [[item.fields objectForKey:searchField2] uppercaseString];
        [tmp setValue:uppercaseValue2 forKey:@"search2"];
    }
    [tmp setValue:(modifiedLocally ? @"1" : @"0") forKey:@"modified"];
    [[Database getInstance] insert:item.entity item:tmp];
    // set
    [[Database getInstance] execSql:[NSString stringWithFormat:@"UPDATE %@ SET Id = '#'||gadget_id WHERE Id IS NULL", item.entity] params:nil];
}

+ (void)update:(Item *)item modifiedLocally:(BOOL)modifiedLocally {
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithDictionary:item.fields];
    NSString *searchField = [[Configuration getInfo:item.entity] searchField];
    NSString *uppercaseValue = [[tmp objectForKey:searchField] uppercaseString];
    [tmp setValue:uppercaseValue forKey:@"search"];
    [tmp setValue:(modifiedLocally ? @"1" : @"0") forKey:@"modified"];
    if (modifiedLocally) {
        [tmp setValue:[NSNull null] forKey:@"error"];
    }
    if ([tmp objectForKey:@"gadget_id"] != Nil) {
        [[Database getInstance] update:item.entity item:tmp column:@"gadget_id" value:[tmp objectForKey:@"gadget_id"]];
    } else {
        [[Database getInstance] update:item.entity item:tmp column:@"Id" value:[tmp objectForKey:@"Id"]];
    }
    [tmp release];
}


+ (void)remove:(Item *)item {
     
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithDictionary:item.fields];
    [tmp setObject:@"1" forKey:@"deleted"];
    [tmp setObject:[NSNull null] forKey:@"error"];
    
    if ([tmp objectForKey:@"Id"] == Nil || [[tmp objectForKey:@"Id"] hasPrefix:@"#"]) {
        [[Database getInstance] remove:item.entity column:@"gadget_id" value:[tmp objectForKey:@"gadget_id"]];
    } else {
        [[Database getInstance] update:item.entity item:tmp column:@"Id" value:[tmp objectForKey:@"Id"]];
    }
}

+ (void)setModified:(Item *)item modified:(BOOL)modified {
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithCapacity:1];
    [tmp setValue:(modified ? @"1" : @"0") forKey:@"modified"];
    [[Database getInstance] update:item.entity item:tmp column:@"gadget_id" value:[tmp objectForKey:@"gadget_id"]];
}

+ (void)initData {

}


+ (void)initTables {
    Database *database = [Database getInstance];
    NSArray *entities = [Configuration getEntities];
    for (NSString *entity in entities) {
        NSObject <EntityInfo> *info = [Configuration getInfo:entity];
        NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
        NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
        [columns addObject:@"gadget_id"];
        [types addObject:@"INTEGER PRIMARY KEY"];
        [columns addObject:@"search"];
        [types addObject:@"TEXT"];
        [columns addObject:@"search2"];
        [types addObject:@"TEXT"];
        [columns addObject:@"modified"];
        [types addObject:@"INTEGER"];
        [columns addObject:@"deleted"];
        [types addObject:@"INTEGER"];
        [columns addObject:@"error"];
        [types addObject:@"TEXT"];
        [columns addObject:@"favorite"];
        [types addObject:@"TEXT"];
        [columns addObject:@"important"];
        [types addObject:@"INTEGER"];
        for (NSString *field in [info fields]) {
            [columns addObject:field];
            [types addObject:@"TEXT"];
        }
        [database check:entity columns:columns types:types];
        [columns release];
        [types release];
        
        [database createIndex:entity column:@"Important" unique:false];
        [database createIndex:entity column:@"Id" unique:false];
        [database createIndex:entity column:@"search" unique:false];
        [database createIndex:entity column:@"search2" unique:false];
        for (NSObject <Subtype> *sinfo in [info getSubtypes]) {
            if (![[sinfo getOrderField] isEqualToString:@"search"]) {
                [database createIndex:entity column:[sinfo getOrderField] unique:false];
            }
            for (NSObject <Criteria> *criteria in [sinfo getCriterias]) {
                [database createIndex:entity column:[criteria column] unique:false];
            }
            if ([sinfo filterField] != nil) {
                [database createIndex:entity column:[sinfo filterField] unique:false];
            }
        }
        for (Relation *relation in [Relation getEntityRelations:entity]) {
            if ([relation.srcEntity isEqualToString:entity]) {
                [database createIndex:entity column:relation.srcKey unique:false];
            }
        }
    }
}

+ (void)increaseImportance:(Item *)item {
    
    int importance = [[item.fields objectForKey:@"Important"] intValue]+1;
    NSMutableDictionary *tmp = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
    [tmp setValue:[NSString stringWithFormat:@"%d", importance] forKey:@"Important"];
    [[Database getInstance] update:item.entity item:tmp column:@"gadget_id" value:[item.fields objectForKey:@"gadget_id"]];

}
    

@end
