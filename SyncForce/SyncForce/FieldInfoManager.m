//
//  MetadataManager.m
//  SalesforceSyncModule
//
//  Created by Gaeasys Admin on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FieldInfoManager.h"


@implementation FieldInfoManager

static NSMutableArray *columns;
static NSMutableArray *types;

+ (void)initColumns{
    if(columns == nil){
        columns = [[NSMutableArray alloc] initWithCapacity:1];
        types = [[NSMutableArray alloc] initWithCapacity:1];
        [columns addObject:@"local_id"];
        [types addObject:@"INTEGER PRIMARY KEY"];
        [columns addObject:@"entity"];
        [types addObject:@"TEXT"];
        [columns addObject:@"name"];
        [types addObject:@"TEXT"];
        [columns addObject:@"label"];
        [types addObject:@"TEXT"];
        [columns addObject:@"type"];
        [types addObject:@"TEXT"];
        [columns addObject:@"soapType"];
        [types addObject:@"TEXT"];
        [columns addObject:@"referenceTo"];
        [types addObject:@"TEXT"];
        [columns addObject:@"idLookup"];
        [types addObject:@"TEXT"];
        [columns addObject:@"calculated"];
        [types addObject:@"TEXT"];
        [columns addObject:@"dependentPicklist"];
        [types addObject:@"TEXT"];
        [columns addObject:@"controllerName"];
        [types addObject:@"TEXT"];
        [columns addObject:@"sortable"];
        [types addObject:@"TEXT"];
        [columns addObject:@"length"];
        [types addObject:@"TEXT"];
        [columns addObject:@"createable"];
        [types addObject:@"TEXT"];
        [columns addObject:@"updateable"];
        [types addObject:@"TEXT"];
        [columns addObject:@"nillable"];
        [types addObject:@"TEXT"];
        [columns addObject:@"filterable"];
        [types addObject:@"TEXT"];
        [columns addObject:@"relationshipName"];
        [types addObject:@"TEXT"];
        [columns addObject:@"calculatedFormula"];
        [types addObject:@"TEXT"];
        [columns addObject:@"defaultValueFormula"];
        [types addObject:@"TEXT"];
        [columns addObject:@"defaultedOnCreate"];
        [types addObject:@"TEXT"];
        [columns addObject:@"restrictedPicklist"];
        [types addObject:@"TEXT"];
        [columns addObject:@"externalId"];
        [types addObject:@"TEXT"];
    }
}

+ (void)initTable {
    DatabaseManager *database = [DatabaseManager getInstance];
    [self initColumns];
    [database check:FIELDSINFO_ENTITY columns:columns types:types];
    [database createIndex:FIELDSINFO_ENTITY column:@"local_id" unique:true];
}

+ (void)insert:(Item *)item{
    NSMutableDictionary *fieldsIn = [item fields];
    for(NSString *field in [fieldsIn allKeys]){
        if([columns containsObject:field]) continue;
        [fieldsIn removeObjectForKey:field];
    }
    [[DatabaseManager getInstance] insert:FIELDSINFO_ENTITY item:fieldsIn];
    [fieldsIn release];
}

+ (Item *)find:(NSDictionary *)criterias {
    Item *item = nil;
    NSArray *items = [[DatabaseManager getInstance] select:FIELDSINFO_ENTITY fields:columns criterias:criterias order:Nil ascending:YES];
    if ([items count] > 0) {
        NSDictionary *itemFields = [items objectAtIndex:0];
        item = [[Item alloc] init:FIELDSINFO_ENTITY fields:itemFields];
    }
    [items release];
    return item;
}

+ (NSArray *)list:(NSDictionary *)criterias {
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:1]; //[[NSMutableArray alloc] initWithCapacity:1];
    NSArray *records = [[DatabaseManager getInstance] select:FIELDSINFO_ENTITY fields:columns criterias:criterias order:nil ascending:true];
    for (NSDictionary *record in records) {
        Item *tmpItem = [[Item alloc] init:FIELDSINFO_ENTITY fields:record];
        [list addObject:tmpItem];
        [tmpItem release];
    }
    [records release];
    return list;
}

+ (NSArray *) referenceToEntitiesByField :(NSString *)entity field:(NSString *)field{
    NSArray *referenceEntities = [[NSArray alloc] init];
    NSMutableDictionary *filter = [[NSMutableDictionary alloc] initWithCapacity:1];
    [filter setValue:[ValuesCriteria criteriaWithString:entity] forKey:@"entity"];
    [filter setValue:[ValuesCriteria criteriaWithString:field] forKey:@"name"];
    [filter setValue:[ValuesCriteria criteriaWithString:@"reference"] forKey:@"type"];
    Item *item = [FieldInfoManager find:filter];
    if(item != nil){
        NSString *references = [item.fields valueForKey:@"referenceTo"];
        referenceEntities =  [references componentsSeparatedByString:@","];
    }
    [item release];
    [filter release];
    
    return referenceEntities;
}

@end
