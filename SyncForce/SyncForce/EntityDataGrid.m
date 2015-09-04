//
//  EntityDataGrid.m
//  SyncForce
//
//  Created by Hun Sokunpheaktra on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EntityDataGrid.h"
#import "EntityManager.h"
#import "EntityInfo.h"
#import "InfoFactory.h"
#import "EntityInfo.h"
#import "EditViewController.h"
#import "DataType.h"
#import "Entity.h"
#import "EditLayoutSectionsInfoManager.h"
#import "RecordTypeMappingInfoManager.h"
#import "FilterFieldManager.h"
#import "KeyFieldInfoManager.h"
#import "FieldInfoManager.h"
#import "PicklistForRecordTypeInfoManager.h"

@implementation EntityDataGrid

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (id)initWithEntity:(NSString*)newEntity{
    mapRefName = [[NSMutableDictionary alloc] init];
    tableNameExist = [[NSMutableDictionary alloc] init];
    mapListRefEntity = [[NSMutableDictionary alloc] init];
    mapFieldNamePicklist = [[NSMutableDictionary alloc] init];
    
    entity = newEntity;
    return self;
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

#pragma datamodel methods

- (NSString *) getEntityName{
    return entity;
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

- (int) getColumType:(int) columnIndex{
    NSString *colname = [apiColumnNames objectAtIndex:columnIndex];
    
    for(Item *item in fieldInfos){
        
        if(![colname isEqualToString:[item.fields valueForKey:@"name"]]) continue;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"datetime"]) return TYPE_DATETIME;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"date"]) return TYPE_DATE;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"currency"]) return TYPE_CURRENCY;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"double"]) return TYPE_DOUBLE;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"int"]) return TYPE_INT;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"blob"]) return TYPE_BLOB;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"boolean"]) return TYPE_BOOLEAN;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"percent"]) return TYPE_PERCENT;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"reference"]) return TYPE_REFERENCE;
        if([[item.fields valueForKey:@"type"] isEqualToString:@"picklist"]) return TYPE_PICKLIST;
  
    }
    return TYPE_STRING;
}


- (NSString *) getValueAt:(int) rowIndex columnIndex:(int) columnIndex{
    NSString* colname = [self getApiColumnName:columnIndex];

    Item *item = [rows objectAtIndex:rowIndex];    
    return [item.fields objectForKey:colname];
}

-(void) clearListEdit {
     [listEditRecord removeAllObjects];
}

- (void) setValueAt:(int)rowIndex columnIndex:(int)columnIndex  oldValue:(NSString*)oldValue newValue:(NSString*)newValue{
    [listEditRecord addObject:[NSString stringWithFormat:@"%d", rowIndex]];
    [[[rows objectAtIndex:rowIndex] fields] setValue:newValue forKey:[self getApiColumnName:columnIndex]];
}

- (BOOL) isEditable:(int)columnIndex{
    
    NSMutableDictionary *criteria = [[NSMutableDictionary alloc] init];
    [criteria setValue:[[[ValuesCriteria alloc] initWithString:[self getEntityName]] autorelease] forKey:@"entity"];
    [criteria setValue:[[[ValuesCriteria alloc] initWithString:[self getApiColumnName:columnIndex]] autorelease] forKey:@"name"];
    Item* item = [FieldInfoManager find:criteria];
    
    [criteria release];
    
    return [[item.fields objectForKey:@"updateable"] isEqualToString:@"true"] ? YES:NO ;
    
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
    [self populate];
}

- (void) populate{
    
    listEditRecord = [[NSMutableArray alloc] init];
    rows = [[EntityManager list:entity criterias:nil] retain]; 
    NSObject<EntityInfo> *entityInfo = [InfoFactory getInfo:entity] ; //Latest release
    fieldInfos = [[(Entity *)[InfoFactory getInfo:[self getEntityName]] fieldsInfo] retain] ;
        
    NSMutableArray *columns = [[NSMutableArray alloc] init] ;
    NSMutableArray *apiColumns = [[NSMutableArray alloc] init]; 
    
    NSMutableDictionary *localCriteria = [[NSMutableDictionary alloc] init];
    [localCriteria setValue:[[[ValuesCriteria alloc] initWithString:entity] autorelease] forKey:@"objectName"];
    
    NSMutableArray* arrayFieldDisplay = [[NSMutableArray alloc] initWithArray:[[FilterFieldManager list:localCriteria] autorelease]]; // Latest release
    
    [localCriteria release]; // Latest release
    
    if ([arrayFieldDisplay count]>0) {

        for (Item* item in arrayFieldDisplay) {
            if (![item.entity isEqualToString:@""]) {
                [columns addObject:[item.fields objectForKey:@"fieldLabel"]]; // Latest release
                [apiColumns addObject:[item.fields objectForKey:@"fieldName"]]; // Latest release
            }
        }

    }else {
        
            NSMutableDictionary *cri = [[NSMutableDictionary alloc] init];
            [cri setValue:[[ValuesCriteria alloc] initWithString:@"012000000000000AAA"] forKey:@"RecordTypeId"];
            [cri setValue:[[ValuesCriteria alloc] initWithString:@"Master"] forKey:@"name"];
            [cri setValue:[[ValuesCriteria alloc] initWithString:[self getEntityName]] forKey:@"entity"];
            Item*layout = [RecordTypeMappingInfoManager find:cri];
            
            [cri removeAllObjects];
            [cri setValue:[ValuesCriteria criteriaWithString:[self getEntityName]] forKey:@"entity"];
            if([[[layout fields] objectForKey:@"layoutId"] length]>0)
              [cri setValue:[ValuesCriteria criteriaWithString:[[layout fields] objectForKey:@"layoutId"]] forKey:@"Id"];
                  
            NSArray*tmp = [EditLayoutSectionsInfoManager list:cri];
            NSMutableDictionary*dic = [[NSMutableDictionary alloc] init];
    
            for (Item*item in tmp) {
                [dic setValue:[item.fields objectForKey:@"label"] forKey:[item.fields objectForKey:@"value"]];
            }
        
           
            NSString* subOrName = @"";
        
            if ([[self getEntityName] isEqualToString:@"Case"] ||
                [[self getEntityName] isEqualToString:@"Task"] ||
                [[self getEntityName] isEqualToString:@"Event"]
            ) {
                subOrName = @"Subject";
            }
            else if ([[self getEntityName] isEqualToString:@"Contract"]) subOrName = @"ContractNumber";
            else subOrName = @"Name";
        
            Item *item = [entityInfo getFieldInfoByName:subOrName];
        
            if(item){
                
                if([[self getEntityName] isEqualToString:@"Contact"] || [[self getEntityName] isEqualToString:@"Lead"]) 
                    [columns addObject:[item.fields valueForKey:@"label"]];
                else [columns addObject:[dic objectForKey:[item.fields valueForKey:@"name"]]];
                [apiColumns addObject:[item.fields valueForKey:@"name"]];
            }
        
            for(NSString *fieldName in [entityInfo getAllFields]){
                if ([[dic allKeys] containsObject:fieldName]) {
                    if(![fieldName isEqualToString:@"Id"] && ![fieldName isEqualToString:subOrName]){
                        item = [entityInfo getFieldInfoByName:fieldName];
                        [columns addObject:[dic objectForKey:[item.fields valueForKey:@"name"]]];
                        [apiColumns addObject:[item.fields valueForKey:@"name"]];
                    }
                }   
                if([columns count] == 5) break;
          
            }
        
            for (int x =0; x < [columns count]; x++) {
                Item* item = [[Item alloc] init:@"FilterField" fields:nil];
                [item.fields setValue:[self getEntityName] forKey:@"objectName"];
                [item.fields setValue:[columns objectAtIndex:x] forKey:@"fieldLabel"];
                [item.fields setValue:[apiColumns objectAtIndex:x] forKey:@"fieldName"];
               
                [FilterFieldManager insert:item];
                if (x != 0) [KeyFieldInfoManager insert:[[Item alloc] init:@"KeyFields" fields:item.fields]];
                
                
            }
        
        [dic release];
    }
    
    
 
    [columns addObject:@"Id"];
    [apiColumns addObject:@"Id"];

    if([[[entityInfo getAllFields] autorelease] count] == 0){ // Latest release
        [apiColumns removeAllObjects];
        [columns removeAllObjects];
    }
    
    
    apiColumnNames = [apiColumns copy];
    columnNames = [columns copy];
    
    [columns release];
    [apiColumns release];
    [arrayFieldDisplay release]; // Latest release
    [entityInfo release]; // Latest release
   }

- (NSString *) getIdColumn{
    return nil;
}


-(NSMutableDictionary*) getValueBy:(NSString*)fieldName recordId:(NSString*)recordId {
    
    NSArray *arr;
    Item *tmpItem ;

    NSMutableDictionary*result = [NSMutableDictionary dictionaryWithCapacity:1]; 
    
    if (![[mapRefName allKeys] containsObject:fieldName]) {
        arr = [[FieldInfoManager referenceToEntitiesByField:[self getEntityName] field:fieldName] autorelease];
        [mapRefName setValue:arr forKey:fieldName];
    }else arr = [[mapRefName objectForKey:fieldName] retain];

    
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
                 
                [tmpItem release];
                 return result;
                 
             }
                 
       } else {
            if ([[DatabaseManager getInstance] checkTable:name]) {
                NSMutableDictionary* mapIdName = [[NSMutableDictionary alloc] init];
                tmpItem = [EntityManager find:name column:@"Id" value:recordId];
                if (tmpItem != nil) {
                    
                    [mapIdName setValue:[tmpItem.fields objectForKey:@"Name"] forKey:recordId];
                    [tableNameExist setValue:mapIdName forKey:name];
                    [mapIdName release];
                    
                    [result setValue:[tmpItem.fields objectForKey:@"Name"] forKey:@"Result"];
                    [result setValue:name forKey:@"RefName"];
                    [result setValue:@"YES" forKey:@"Found"];
                    
                      [tmpItem release];
                    return result;
                }else { 
                
                    if (recordId != nil) {
                        [mapIdName setObject:recordId forKey:recordId];
                        [tableNameExist setValue:mapIdName forKey:name];
                        [mapIdName release];
                    }else {
                        [result setValue:@"" forKey:@"Result"];
                        [result setValue:name forKey:@"RefName"];
                        [result setValue:@"YES" forKey:@"Found"];
                    }    
                    
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

-(NSArray*) getListReferenceBy:(NSString*)entityName {
    
    NSArray*tmpList;
    if ([[mapListRefEntity allKeys] containsObject:entityName]) {
        tmpList = [mapListRefEntity valueForKey:entityName];
    }else {
        tmpList = [[EntityManager list:entityName criterias:nil] retain];
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

#pragma datagrid listener methods

-(void) callback:(GridItem *)item{
    
}
-(void) addForm:(UINavigationController*)navigation{
    
}
-(void) save{
 
    for (NSString* index in listEditRecord) {
        Item* item = [rows objectAtIndex:[index intValue]];
        [item.fields setValue:@"0" forKey:@"error"];
        [EntityManager update:item modifiedLocally:YES];

    }
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

-(void)dealloc {
    rows = nil;
    [rows release]; // Latest release
    fieldInfos = nil;
    [fieldInfos release]; // Latest release
    [listEditRecord release]; // Latest release
    [apiColumnNames release]; // Latest release
    [columnNames release]; // Latest release
   
    
}

@end
