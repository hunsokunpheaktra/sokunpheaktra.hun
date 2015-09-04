//
//  PicklistForRecordTypeInfo.m
//  SyncForce
//
//  Created by Gaeasys Admin on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PicklistForRecordTypeInfoManager.h"

@implementation PicklistForRecordTypeInfoManager

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
        [columns addObject:@"recordTypeId"];
        [types addObject:@"TEXT"];
        [columns addObject:@"picklistName"];
        [types addObject:@"TEXT"];
        [columns addObject:@"label"];
        [types addObject:@"TEXT"];
        [columns addObject:@"value"];
        [types addObject:@"TEXT"];
        [columns addObject:@"validFor"];
        [types addObject:@"TEXT"];
        [columns addObject:@"fieldorder"];
        [types addObject:@"INTEGER"];
        [columns addObject:@"active"];
        [types addObject:@"TEXT"];
        [columns addObject:@"defaultValue"];
        [types addObject:@"TEXT"];
    }
}

+ (void)initTable {
    DatabaseManager *database = [DatabaseManager getInstance];
    [self initColumns];
    [database check:PICKLISTFORRECORDTYPEINFO_ENTITY columns:columns types:types];
    [database createIndex:PICKLISTFORRECORDTYPEINFO_ENTITY column:@"local_id" unique:true];
    [database createIndex:PICKLISTFORRECORDTYPEINFO_ENTITY columns:[NSArray arrayWithObjects:@"entity",@"recordTypeId",@"picklistName", nil] unique:false];
}

+ (void)insert:(Item *)item{
    NSMutableDictionary *fieldsIn = [item fields];
    for(NSString *field in [fieldsIn allKeys]){
        if([columns containsObject:field]) continue;
        [fieldsIn removeObjectForKey:field];
    }
    [[DatabaseManager getInstance] insert:PICKLISTFORRECORDTYPEINFO_ENTITY item:fieldsIn];
    
    [fieldsIn release];
}

+ (Item *)find:(NSDictionary *)criterias {
    Item *item = nil;
    NSArray *items = [[DatabaseManager getInstance] select:PICKLISTFORRECORDTYPEINFO_ENTITY fields:columns criterias:criterias order:@"fieldorder" ascending:YES];
    if ([items count] > 0) {
        NSDictionary *itemFields = [items objectAtIndex:0];
        item = [[Item alloc] init:PICKLISTFORRECORDTYPEINFO_ENTITY fields:itemFields];
    }
    [items release];
    return item;
}

+ (NSArray *)list:(NSDictionary *)criterias {
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:1];
    NSArray *records = [[DatabaseManager getInstance] select:PICKLISTFORRECORDTYPEINFO_ENTITY fields:columns criterias:criterias order:@"fieldorder" ascending:true];
    for (NSDictionary *record in records) {
        Item *tmpItem = [[Item alloc] init:PICKLISTFORRECORDTYPEINFO_ENTITY fields:record];
        [list addObject:tmpItem];
        [tmpItem release];
    }
    [records release];
    return list;
}

+ (NSArray *) getPicklistItems:(NSString*)picklistName entity:(NSString *)entity recordTypeId:(NSString *)recordTypeId {
    NSMutableDictionary *filter = [[NSMutableDictionary alloc] initWithCapacity:1];
    [filter setValue:[ValuesCriteria criteriaWithString:entity] forKey:@"entity"];
    [filter setValue:[ValuesCriteria criteriaWithString:picklistName] forKey:@"picklistName"];
    if(recordTypeId != nil) [filter setValue:[ValuesCriteria criteriaWithString:recordTypeId] forKey:@"recordTypeId"];
    return [PicklistForRecordTypeInfoManager list:filter];
}

@end
