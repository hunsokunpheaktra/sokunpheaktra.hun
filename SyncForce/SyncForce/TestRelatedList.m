//
//  TestRelatedList.m
//  SyncForce
//
//  Created by Gaeasys on 11/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TestRelatedList.h"
#import "GridItem.h"
#import "Datagrid.h"
#import "AppDelegate.h"
#import "EntityManager.h"
#import "Criteria.h"
#import "LikeCriteria.h"
#import "Entity.h"
#import "EditView.h"
#import "Item.h"
#import "OpportunityGrid.h"
#import "DataType.h"
#import "EditViewController.h"
#import "FieldInfoManager.h"
#import "PicklistForRecordTypeInfoManager.h"

@implementation TestRelatedList

@synthesize rows,columnNames,apiColumnNames,fieldInfos,entityName,parentId,parentField;

-(id)init{
    [super init];
    self.fieldInfos = [(Entity *)[InfoFactory getInfo:[self getEntityName]] fieldsInfo];
    return self;
}

-(id)initWithDatas:(NSString*)entity colNames:(NSArray*)colNames apiColName:(NSArray*)apiColNames rows:(NSArray*)tRows parentId:(NSString *)pId parentField:(NSString *)pField cType:(NSString*)cType{

    mapRefName = [[NSMutableDictionary alloc] init];
    tableNameExist = [[NSMutableDictionary alloc] init];
    mapListRefEntity = [[NSMutableDictionary alloc] init];
    mapFieldNamePicklist = [[NSMutableDictionary alloc] init];

    listEditRecord = [[NSMutableArray alloc] init];   
    columnNames = [colNames copy];
    apiColumnNames = [apiColNames copy]; 
    entityName = entity;
    rows = [tRows copy];
    parentId = pId;
    parentField = pField;
    childType = cType;
    self.fieldInfos = [(Entity *)[InfoFactory getInfo:entityName] fieldsInfo];
    return self;
}

-(void) callback:(GridItem *)griditem{
}

-(void) addForm :(UINavigationController*)navigation{

    EditViewController *modelView = [[EditViewController alloc] init:[[Item alloc] init:[self getEntityName] fields:nil] mode:@"add" objectId:parentId relationField:nil];
    

    [navigation pushViewController:modelView animated:YES];
    
   [modelView release];
}

- (NSString *) getEntityName{
    return entityName;
}

- (int) getColumType:(int) columnIndex{
    NSString *colname = [self.apiColumnNames objectAtIndex:columnIndex];
    
    for(Item *item in fieldInfos){
        if(![colname isEqualToString:[[item fields]valueForKey:@"name"]]) continue;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"datetime"]) return TYPE_DATETIME;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"date"]) return TYPE_DATE;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"currency"]) return TYPE_CURRENCY;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"double"]) return TYPE_DOUBLE;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"int"]) return TYPE_INT;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"blob"]) return TYPE_BLOB;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"boolean"]) return TYPE_BOOLEAN;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"percent"]) return TYPE_PERCENT;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"reference"]) return TYPE_REFERENCE;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"picklist"]) return TYPE_PICKLIST;//picklist
    }
    
    return TYPE_STRING;
}

- (NSString *) getParentColumnName{
    return nil;
}

- (int) getRowCount{
    return [rows count];
}
- (int) getColumnCount{
    return [apiColumnNames count];
}
- (NSString *) getColumnName:(int) columnIndex{
    return [columnNames objectAtIndex:columnIndex];
}

- (NSString *) getApiColumnName:(int) columnIndex{
    return [apiColumnNames objectAtIndex:columnIndex];
}

- (NSString *) getValueAt:(int) rowIndex columnIndex:(int) columnIndex{
    NSString* colname = [self getApiColumnName:columnIndex];
    
    Item *item = [rows objectAtIndex:rowIndex];
    return [item.fields objectForKey:colname];
}
- (void) setValueAt:(int)rowIndex columnIndex:(int)columnIndex  oldValue:(NSString*)oldValue newValue:(NSString*)newValue{
    [listEditRecord addObject:[NSString stringWithFormat:@"%d", rowIndex]];
    [[[rows objectAtIndex:rowIndex] fields] setValue:newValue forKey:[self getApiColumnName:columnIndex]];
}

-(void) clearListEdit {
    [listEditRecord removeAllObjects];
}

-(void) deleteRecordById:(NSString*)recordId {
  
    Item* deleteItem;
    for (Item* item in rows) {
        if ([[item.fields objectForKey:@"Id"] isEqualToString:recordId]) {
            deleteItem = item;
            break;
        }
    }
    
    [EntityManager remove:deleteItem];
    NSMutableDictionary *criterias = [[NSMutableDictionary alloc] init];
    [criterias setValue:[[[ValuesCriteria alloc] initWithString:parentId] autorelease] forKey:parentField];
        
    rows = [EntityManager list:childType criterias:criterias];
    
}

- (void) populate{
    
}

- (NSString *) getIdColumn{
    return @"Id";
}

-(void) save{
    for (NSString* index in listEditRecord) {
        Item* item = [rows objectAtIndex:[index intValue]];
        [item.fields setValue:@"0" forKey:@"error"];
        [EntityManager update:item modifiedLocally:YES];
        
    }
}

- (BOOL) isEditable:(int)columnIndex{
    NSMutableDictionary *criteria = [[NSMutableDictionary alloc] init];
    [criteria setValue:[[[ValuesCriteria alloc] initWithString:[self getEntityName]] autorelease] forKey:@"entity"];
    [criteria setValue:[[[ValuesCriteria alloc] initWithString:[self getApiColumnName:columnIndex]] autorelease] forKey:@"name"];
    Item* item = [FieldInfoManager find:criteria];
    
    [criteria release];
    
    return [[item.fields objectForKey:@"updateable"] isEqualToString:@"true"] ? YES:NO ;

}

-(NSMutableDictionary*) getValueBy:(NSString*)fieldName recordId:(NSString*)recordId {
    NSArray *arr;
    Item *tmpItem ;
    
    NSMutableDictionary*result = [[NSMutableDictionary alloc] init]; 
    
    if (![[mapRefName allKeys] containsObject:fieldName]) {
        arr = [FieldInfoManager referenceToEntitiesByField:[self getEntityName] field:fieldName];
        [mapRefName setValue:arr forKey:fieldName];
    }else arr = [mapRefName objectForKey:fieldName];
    
    
    for (NSString*name in arr) {
        if ([[tableNameExist allKeys] containsObject:name]) {
            if ([[tableNameExist objectForKey:name] valueForKey:recordId] != nil) {
                [result setValue:[[tableNameExist objectForKey:name] valueForKey:recordId] forKey:@"Result"];
                [result setValue:name forKey:@"RefName"];
                [result setValue:@"YES" forKey:@"Found"];
                return  result;
            }   
            else {
                tmpItem = [EntityManager find:name column:@"Id" value:recordId];
                [result setValue:name forKey:@"RefName"];
                [result setValue:@"YES" forKey:@"Found"];
                
                if (tmpItem != nil) {
                    
                    NSMutableDictionary* mapIdName = [[NSMutableDictionary alloc] init];
                    [mapIdName setValue:[tmpItem.fields objectForKey:@"Name"] forKey:recordId];
                    
                    [tableNameExist setValue:mapIdName forKey:name];
                    [mapIdName release];
                    
                    [result setValue:[tmpItem.fields objectForKey:@"Name"] forKey:@"Result"];
                    
                }else [result setValue:recordId forKey:@"Result"];
                
                return result;
                
            }
            
        } else {
            if ([[DatabaseManager getInstance] checkTable:name]) {
                tmpItem = [EntityManager find:name column:@"Id" value:recordId];
                if (tmpItem != nil) {
                    
                    NSMutableDictionary* mapIdName = [[NSMutableDictionary alloc] init];
                    [mapIdName setValue:[tmpItem.fields objectForKey:@"Name"] forKey:recordId];
                    
                    [tableNameExist setValue:mapIdName forKey:name];
                    [mapIdName release];
                    
                    [result setValue:[tmpItem.fields objectForKey:@"Name"] forKey:@"Result"];
                    [result setValue:name forKey:@"RefName"];
                    [result setValue:@"YES" forKey:@"Found"];
                    
                    return result;
                }
            }else{
                [result setValue:recordId forKey:@"Result"];
                [result setValue:name forKey:@"RefName"];
                [result setValue:@"NO" forKey:@"Found"];
                
            }
        }
    }
    
    return result;

}

-(NSArray*) getListReferenceBy:(NSString*)entity {
    NSArray*tmpList;
    if ([[mapListRefEntity allKeys] containsObject:entityName]) {
        tmpList = [mapListRefEntity valueForKey:entityName];
    }else {
        tmpList = [EntityManager list:entityName criterias:nil];
        [mapListRefEntity setValue:tmpList forKey:entityName];
    }
    
    return tmpList;
}

-(NSArray*) getPickListBy:(NSString*)fieldName recordTypeId:(NSString*)recordTypeId {
    NSArray* tmp;
    
    if (![[mapFieldNamePicklist allKeys] containsObject:fieldName]) {
        tmp = [PicklistForRecordTypeInfoManager getPicklistItems:fieldName entity:[self getEntityName] recordTypeId:recordTypeId];
        [mapFieldNamePicklist setValue:tmp forKey:fieldName];
    }else 
        tmp = [mapFieldNamePicklist valueForKey:fieldName];
    
    return tmp;

}

-(void)dealloc{		
    [fieldInfos release];
	[rows release];
    [columnNames release];
	[apiColumnNames release];
    [super dealloc];
}


@end
