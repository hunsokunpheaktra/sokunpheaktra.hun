//
//  EntityRelationRequest.m
//  RetailForce
//
//  Created by Gaeasys on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EntityRelationRequest.h"
#import "InfoFactory.h"
#import "EntityManager.h"
#import "PropertyManager.h"
#import "DirectoryHelper.h"
#import "ZKSObject.h"
#import "TransactionInfoManager.h"
#import "GreaterThanCriteria.h"
#import "GreaterThanOrEqualCriteria.h"
#import "LikeCriteria.h"
#import "LessThanCriteria.h"
#import "LessThanOrEqualCriteria.h"
#import "NotInCriteria.h"
#import "SyncProcess.h"
#import "EntityRelationRequest.h"
#import "RelatedListsInfoManager.h"
#import "EntityLevel.h"

@implementation EntityRelationRequest

@synthesize entity,entityInfo;
@synthesize dateFilter;
@synthesize listener;
@synthesize tasknum,currentitem;
@synthesize level;

- (id)initWithEntity:(NSString *)newEntity parentEntity:(NSString*)pEntity parentId:(NSString*)ids listener:(NSObject<SyncListener>*) newListener level:(int)newLevel{
    self.entity = newEntity;
    self.listener = newListener;
    self.level = newLevel;
    parentEntity = pEntity;
    parentId = ids;
    
    return self;
}

- (NSString*)getCriteria:(Item*)item{
    
    NSString *oper = [item.fields valueForKey:@"operator"];
    NSMutableString *criter = [[[NSMutableString alloc] initWithCapacity:1] autorelease];
    [criter appendFormat:@"%@ ",[item.fields valueForKey:@"fieldName"]];
    
    NSObject<Criteria> *criteria;
    
    if([oper isEqualToString:@"equals"]){
        criteria = [[ValuesCriteria alloc] initWithString:[item.fields valueForKey:@"value"]];
    }else if([oper isEqualToString:@"not equal to"]){
        criteria = [[NotInCriteria alloc] initWithValue:[item.fields valueForKey:@"value"]];
    }else if([oper isEqualToString:@"not start with"]){
        criteria = [[ValuesCriteria alloc] initWithString:[item.fields valueForKey:@"value"]];
    }else if([oper isEqualToString:@"starts with"]){
        criteria = [[LikeCriteria alloc] initWithValue:[item.fields valueForKey:@"value"]];
    }else if([oper isEqualToString:@"contains"]){
        criteria = [[ValuesCriteria alloc] initWithString:[item.fields valueForKey:@"value"]];
    }else if([oper isEqualToString:@"does not contain"]){
        criteria = [[ValuesCriteria alloc] initWithString:[item.fields valueForKey:@"value"]];
    }else if([oper isEqualToString:@"less than"]){
        criteria = [[LessThanCriteria alloc] initWithValue:[item.fields valueForKey:@"value"]];
    }else if([oper isEqualToString:@"greater than"]){
        criteria = [[GreaterThanCriteria alloc] initWithValue:[item.fields valueForKey:@"value"]];
    }else if([oper isEqualToString:@"less or equal"]){
        criteria = [[LessThanOrEqualCriteria alloc] initWithValue:[item.fields valueForKey:@"value"]];
    }else if([oper isEqualToString:@"greater or equal"]){
        criteria = [[GreaterThanOrEqualCriteria alloc] initWithValue:[item.fields valueForKey:@"value"]];
    }else if([oper isEqualToString:@"includes"]){
        criteria = [[ValuesCriteria alloc] initWithString:[item.fields valueForKey:@"value"]];
    }else if([oper isEqualToString:@"excludes"]){
        criteria = [[ValuesCriteria alloc] initWithString:[item.fields valueForKey:@"value"]];
    }
    
    NSString* subOrName = @"";
    
    if ([entity isEqualToString:@"Case"] ||
        [entity isEqualToString:@"Task"] ||
        [entity isEqualToString:@"Event"]
        ) {
        subOrName = @"Subject";
    }
    else if ([entity isEqualToString:@"Contract"]) subOrName = @"ContractNumber";
    else subOrName = @"Name";
    
    [criter appendString:[[criteria getCriteria] stringByReplacingOccurrencesOfString:@"?" withString:@""]];
    if ([[item.fields objectForKey:@"fieldName"] isEqualToString:subOrName]) {
        NSString *value = [item.fields valueForKey:@"value"];
        value = [value stringByReplacingOccurrencesOfString:@"'" withString:@""];
        value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        [criter appendFormat:@"'%@'",value];
    }else [criter appendFormat:@"%@",[item.fields valueForKey:@"value"]];
    
    
    return criter;
}

- (NSString*) getQueryContents{
    
    if (parentId.length == 0) parentId = @"''";
    
    // read the selected Entity Info
    NSArray * allfields =  [self.entityInfo getAllFields];
    NSMutableString* querystring = [[NSMutableString alloc] initWithCapacity:1];
    
	// construct the query dynamically
    [querystring appendString: @"Select "];
    for(int i = 0 ; i < allfields.count; i++){
        if(i > 0) [querystring appendString:@", "];
        [querystring appendString: [allfields objectAtIndex:i]];
    }
    [querystring appendString:@" From "];
    [querystring appendString:self.entity];
    
    if (parentEntity != nil && parentEntity.length>0) {
        NSString* fieldRelation = [self getFieldRelation];
        if (fieldRelation && fieldRelation.length >0) {
            [querystring appendString:@" WHERE "];
            [querystring appendString:fieldRelation];
            [querystring appendString:@" IN ( "];
            [querystring appendString:parentId];
            [querystring appendString:@")"];
        }
    }else {
        [querystring appendString:@" WHERE "];
        [querystring appendString:@"Id IN ( "];
        [querystring appendString:parentId];
        [querystring appendString:@" ) "];
    }
    
    
    return querystring;
}

- (void)doRequest {    
    // loop on all fields and build the query
    self.dateFilter = [TransactionInfoManager readLastSyncDate:[self getName]];
    NSString *queryString =  [NSString stringWithFormat:@"%@",[self getQueryContents]];
    [[FDCServerSwitchboard switchboard] query:queryString target:self selector:@selector(queryResult:error:context:) context:nil];
    
}

- (void)queryResult:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    NSLog(@"INcoming %@", result);
    NSMutableArray *listItem = [[NSMutableArray alloc] init];
    if (result != nil && error == nil)
    {
        NSLog(@"queryResult:%@ eror:%@ context:%@", result, error, context);
        NSMutableArray *allDetails = [NSMutableArray arrayWithArray:result.records];
        NSString *userId = nil;
        NSString *currencyCode = nil;
        NSString *usertimezone = nil;
        if ([self.entity isEqualToString:@"User"]) {
            userId = [PropertyManager read:@"CurrentUserId"];
        }      
        
        for(ZKSObject *sobject in result.records){
            [sobject.fields setValue:@"0" forKey:@"error"];
            [sobject.fields setValue:@"0" forKey:@"deleted"];
            
            Item *item = [[Item alloc] initCustom:self.entity fields:[NSDictionary dictionaryWithDictionary:sobject.fields]];
            BOOL isLocal = [EntityManager find:self.entity column:@"Id" value:[[item fields] valueForKey:@"Id"]] != nil;
            if(isLocal) [EntityManager update:item modifiedLocally:false];
            else [EntityManager insert:item modifiedLocally:false];
            
            // if entity test = user, we need to save in the property Manager Timezone, Currency code
            if ([self.entity isEqualToString:@"User"]) {
                if ([userId isEqualToString: [[[item fields] valueForKey:@"Id"] substringWithRange:NSMakeRange(0, 15)]]) {
                    currencyCode = [item.fields valueForKey:@"CurrencyIsoCode"]; 
                    usertimezone = [item.fields valueForKey:@"TimeZoneSidKey"]; 
                    [PropertyManager save:@"CurrencyIsoCode" value:currencyCode];
                    [PropertyManager save:@"TimeZoneSidKey" value:usertimezone];
                }
                
            }
            
            [listItem addObject:item];
            [item release];
            
        }
        
        [self getIdsString:listItem];
        [self.listener onSuccess:allDetails.count request:self again:false];
        
    }
    if (error != nil){
        NSLog(@"Eorr: %@",error);
        [self didFailLoadWithError:[NSString stringWithFormat:@"%@", error]];
    }
}

- (void)didFailLoadWithError:(NSString*)error{
    [self.currentitem.fields setObject:@"1" forKey:@"error"];
    if(currentitem.entity != nil) [EntityManager update:self.currentitem modifiedLocally:false];
    
    [self.listener onFailure:[NSString stringWithFormat:@"Salesforce Error %@", error] request:self again:false];
}

- (NSString *)getName {
    return [NSString stringWithFormat:@"%@ Incoming", self.entity];
}

- (NSNumber *)getTasknum {
    return self.tasknum;
}

- (void)setTask:(NSNumber *)taskNum {
    self.tasknum = tasknum;
}

- (NSString *)getEntity {
    return self.entity;
}

- (Item*) getCurrentitem {
    return self.currentitem;
}

- (NSMutableDictionary*) filterDictionnary:(NSDictionary *)result {
    
    NSArray * allfields =  [self.entityInfo getAllFields];
    NSMutableDictionary *newfields = [NSMutableDictionary dictionaryWithDictionary:result];
    
    for (NSString* key in [result allKeys]) {
        if([allfields containsObject:key]) continue;
        [ newfields removeObjectForKey:key];
    }
    
    return newfields;
}


- (NSString *)toString:(id) val{
    NSString *stringVal = [NSString stringWithFormat:@"%@",val];
    if([val isKindOfClass:[NSArray class]]){
        NSMutableString *content = [NSMutableString stringWithString:@""];
        for(NSString *innerval in val){
            [content appendString:[NSString stringWithFormat:@"%@,",innerval]];
        }
        stringVal = content;
        if(content.length > 1){
            stringVal = [content substringToIndex:content.length - 1];
        }
    }
    return stringVal;
}

- (NSString *)toInt:(int) val{
    return [NSString stringWithFormat:@"%d",val];
}

- (NSString *)toBoolValue:(BOOL)val{
    if(val) return @"true";
    return @"false";
}

- (BOOL)prepare {
    self.entityInfo = [InfoFactory getInfo:self.entity];
    NSLog(@"count field %d on entity %@",[[self.entityInfo getAllFields] count],self.entity );
    NSArray *arr = [self.entityInfo getAllFields];
    //not contain in meta data bypass
    if([arr count] < 1) return NO;
    return YES;
}


-(NSString*) getFieldRelation{
    
    NSMutableDictionary *criteria = [NSMutableDictionary dictionary];
    [criteria setValue:[[[ValuesCriteria alloc] initWithString:parentEntity] autorelease] forKey:@"entity"];
    [criteria setValue:[[[ValuesCriteria alloc] initWithString:self.entity] autorelease] forKey:@"sobject"];
    
    Item* item = [RelatedListsInfoManager find:criteria];
    
    return [item.fields objectForKey:@"field"];
}


-(NSString*) getIdsString:(NSArray*)listItem {
    
    NSMutableString* ids = [[NSMutableString alloc] init];
    for (Item *item in listItem) {
        [ids appendString:[NSString stringWithFormat:@"'%@'",[item.fields objectForKey:@"Id"]]];
        [ids appendString:@","];
    }
    
    if ([[ids stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] hasSuffix:@","]){
        [ids replaceCharactersInRange:NSMakeRange([ids length]-1, 1) withString:@""];
    }
    
    for (Item* ref in [self getOneToOneRelation]){
        NSArray* referenceEntities =  [[ref.fields objectForKey:@"referenceTo"] componentsSeparatedByString:@","];
        
        for (NSString *name in referenceEntities) {
            NSMutableString* idss = [[NSMutableString alloc] init];
            
            for (Item*item in listItem) {
                
                NSString *value = [item.fields objectForKey:[ref.fields objectForKey:@"name"]];
                
                if (value != (id)kCFNull) {
                    
                    [idss appendString:[NSString stringWithFormat:@"'%@'",value]];
                    [idss appendString:@","];
                }
                
            }
            
            if ([[idss stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] hasSuffix:@","]){ 
                [idss replaceCharactersInRange: NSMakeRange([idss length]-1, 1) withString: @""];
            }
            
            if (![self.entity isEqualToString:@"Event"] && ![name isEqualToString:@"WhatId"]) {
                if ([self isAbleToQuery:name] && idss.length >0) {
                    [self.listener addEntityRelation:name parentEntity:nil parentId:idss level:self.level];                              
                }   
            }
        }
    }
    
    for (NSString*child in [self getMany2OneRelation]) {
        if ([self isAbleToQuery:child] && ids.length > 0)
            [self.listener addEntityRelation:child parentEntity:self.entity parentId:ids level:self.level];               
    } 
    
    return @"";
}

-(NSArray*) getOneToOneRelation {
    NSArray* arr = [FieldInfoManager getReferencesTo:self.entity];
    return arr;
}

-(NSArray*) getMany2OneRelation {
    
    NSMutableDictionary *criteria = [NSMutableDictionary dictionary];
    [criteria setValue:[[[ValuesCriteria alloc] initWithString:self.entity] autorelease] forKey:@"entity"];
    NSArray* manyToOne = [RelatedListsInfoManager list:criteria];
    NSMutableArray* listManyToOne = [[NSMutableArray alloc] init];
    
    for (Item* item in manyToOne) {
        [listManyToOne addObject:[item.fields objectForKey:@"sobject"]];
    }
    
    return listManyToOne;
}


-(BOOL) isAbleToQuery :(NSString*) entityName{
    
    if ([[SyncProcess getInstance].list_ignore_sobject containsObject:entityName]) return FALSE; 
    if ([[SyncProcess getInstance].list_ignore_child_query containsObject:self.entity]) return FALSE;
    
    int cLevel = -1; 
    if ([EntityLevel readLevel:entityName] != nil) cLevel = [[EntityLevel readLevel:entityName] intValue];
    if (cLevel == -1 && [EntityLevel readLevel:self.entity]) return FALSE;
    if ([self.entity isEqualToString:@"Account"] && [entityName isEqualToString:@"Contact"]) return TRUE;
    if (cLevel > -1 && cLevel < [[EntityLevel readLevel:self.entity] intValue]) return FALSE;
    if (cLevel > -1 && cLevel < self.level) return FALSE;
        
    
    return TRUE;
}

@end
