//
//  Entity.m
//  SalesforceSyncModule
//
//  Created by Gaeasys Admin on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Entity.h"
#import "EntityInfo.h"
#import "FieldInfoManager.h"
#import "EntityInfoManager.h"
#import "ValuesCriteria.h"

@implementation Entity
@synthesize fieldsInfo,entityInfo;

-(id)initWithEntityName:(NSString *)entityname{
    NSMutableDictionary *filters = [[NSMutableDictionary alloc] initWithCapacity:1];
    [filters setValue:[ValuesCriteria criteriaWithString:entityname] forKey:@"name"];
    entityInfo = [EntityInfoManager find:filters];
    [filters release];
    return [self initWithEntityInfo:entityInfo];
}

-(id)initWithEntityInfo:(Item *)pentityInfo{
    if(entityInfo == nil) entityInfo = pentityInfo;
    NSMutableDictionary *filters = [[NSMutableDictionary alloc] initWithCapacity:1];
    [filters setValue:[ValuesCriteria criteriaWithString:[[pentityInfo fields] valueForKey:@"name"]] forKey:@"entity"];
    fieldsInfo = [[FieldInfoManager list:filters] retain];
    [filters release];
    return self;

}

- (NSString *)getName{
    return [entityInfo.fields valueForKey:@"name"];
}
- (NSString *)getLabel{
    
    return [entityInfo.fields valueForKey:@"label"];
}

- (NSString *)getPluralName{
    return [entityInfo.fields valueForKey:@"labelPlural"];
}

- (NSArray *)getAllFields{
    NSMutableArray *flds = [[NSMutableArray alloc] init];
    for(Item *item in fieldsInfo){
        [flds addObject:[[item fields] valueForKey:@"name"]];
    }
    return flds;
}

- (NSArray *)getExtraFields{
    return nil;
}

-(Item *)getFieldInfoByName:(NSString *)fieldname{
    for(Item* item in fieldsInfo){
        if([[[item fields] valueForKey:@"name"] isEqualToString:fieldname])
            return item;
    }
    return nil;
}

- (NSString *) getFieldTypeByName:(NSString*)fieldname{
    NSString *type = @"TEXT";
    Item *item = [self getFieldInfoByName:fieldname];
    if(item != nil){
        type = [[item fields] valueForKey:@"type"];
    }
    return type;
}

+ (NSArray *) getFieldsCreateable:(NSString *)entity{
    NSMutableDictionary *createFilter = [[NSMutableDictionary alloc] initWithCapacity:1];
    [createFilter setValue:[[ValuesCriteria alloc] initWithString:@"true"] forKey:@"createable"];
    [createFilter setValue:[[ValuesCriteria alloc] initWithString:entity] forKey:@"entity"];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(Item *item in [FieldInfoManager list:createFilter]){
        [result addObject:item];
    }
    [createFilter release];
    return result;
}

+ (NSArray *) getFieldsUpdateable:(NSString *)entity{
    NSMutableDictionary *updateFilter = [[NSMutableDictionary alloc] initWithCapacity:1];
    [updateFilter setValue:[[ValuesCriteria alloc] initWithString:@"true"] forKey:@"updateable"];
    [updateFilter setValue:[[ValuesCriteria alloc] initWithString:entity] forKey:@"entity"];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(Item *item in [FieldInfoManager list:updateFilter]){
        [result addObject:item];
    }
    [updateFilter release];
    return result;
}

@end
