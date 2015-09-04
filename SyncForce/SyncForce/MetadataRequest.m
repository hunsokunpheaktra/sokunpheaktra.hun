//
//  MetadataRequest.m
//  SalesforceSyncModule
//
//  Created by Gaeasys Admin on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MetadataRequest.h"
#import "EntityInfoManager.h"
#import "FieldInfoManager.h"
#import "Item.h"
#import "SFRequest.h"
#import "FDCServerSwitchboard.h"
#import "SyncProcess.h"
#import "ZKSforce.h"
#import "ZKDescribeField.h"
#import "TransactionInfoManager.h"
#import "DatetimeHelper.h"
#import "ZKPicklistEntry.h"
#import "PicklistInfoManager.h"
#import "ZKChildRelationship.h"
#import "ChildRelationshipInfoManager.h"
#import "EntityManager.h"

@implementation MetadataRequest

-(void)doRequest{
    [[FDCServerSwitchboard switchboard] describeSObject:self.entity target:self selector:@selector(describeSObjectResult:error:context:) context:nil];
}

- (void)describeSObjectResult:(id)result error:(NSError *)error context:(id)context
{
    NSLog(@"describeSObjectResult: %@ error: %@ context: %@", result, error, context);
    if (result != nil && error == nil)
    {
        ZKDescribeSObject *describeSobject = (ZKDescribeSObject *)result;
        
        //EntityInfo
        NSMutableDictionary *entityrecord = [NSMutableDictionary dictionary];
        [entityrecord setValue:self.entity forKey:@"name"];
        [entityrecord setValue:[describeSobject string:@"label"] forKey:@"label"];
        [entityrecord setValue:[describeSobject string:@"labelPlural"] forKey:@"labelPlural"];
        [entityrecord setValue:[describeSobject string:@"deletable"] forKey:@"deletable"];
        [entityrecord setValue:[describeSobject string:@"createable"] forKey:@"createable"];
        [entityrecord setValue:[describeSobject string:@"custom"] forKey:@"custom"];
        [entityrecord setValue:[describeSobject string:@"updateable"] forKey:@"updateable"];
        [entityrecord setValue:[describeSobject string:@"keyPrefix"] forKey:@"keyPrefix"];
        [entityrecord setValue:[describeSobject string:@"searchable"] forKey:@"searchable"];
        [entityrecord setValue:[describeSobject string:@"queryable"] forKey:@"queryable"];
        [entityrecord setValue:[describeSobject string:@"retrieveable"] forKey:@"retrieveable"];
        [entityrecord setValue:[describeSobject string:@"undeletable"] forKey:@"undeletable"];
        [entityrecord setValue:[describeSobject string:@"triggerable"] forKey:@"triggerable"];
        [EntityInfoManager insert:[[Item alloc] init:self.entity fields:entityrecord]];
        
        //ChildRelationshipInfo
        for(ZKChildRelationship *childRelationship in describeSobject.childRelationships){
            //            -(BOOL)cascadeDelete;
            //            -(NSString *)childSObject;
            //            -(NSString *)field;
            //            -(NSString *)relationshipName;
            //            -(NSString *)description ;
            NSMutableDictionary *childRelationshiprecord = [NSMutableDictionary dictionary];
            [childRelationshiprecord setValue:self.entity forKey:@"entity"];
            [childRelationshiprecord setValue:childRelationship.childSObject forKey:@"childSObject"];
            [childRelationshiprecord setValue:[self toBoolValue:childRelationship.cascadeDelete] forKey:@"cascadeDelete"];
            [childRelationshiprecord setValue:childRelationship.field forKey:@"field"];
            [childRelationshiprecord setValue:childRelationship.relationshipName forKey:@"relationshipName"];
            [childRelationshiprecord setValue:childRelationship.description forKey:@"description"];
            [ChildRelationshipInfoManager insert:[[Item alloc] init:self.entity fields:childRelationshiprecord]];
        }
        
        NSMutableArray *allColumns = [[NSMutableArray alloc] initWithCapacity:1];
        NSMutableArray *allTypes = [[NSMutableArray alloc] initWithCapacity:1];
        //FieldInfo
        for(ZKDescribeField *describeField in describeSobject.fields){
            NSMutableDictionary *fieldrecord = [NSMutableDictionary dictionary];
            [fieldrecord setValue:self.entity forKey:@"entity"];
            [fieldrecord setValue:[describeField name] forKey:@"name"];
            [allColumns addObject:describeField.name];
            [fieldrecord setValue:[describeField label] forKey:@"label"];
            [fieldrecord setValue:[describeField type] forKey:@"type"];
            [allTypes addObject:describeField.type];
            [fieldrecord setValue:[describeField soapType] forKey:@"soapType"];
            [fieldrecord setValue:[self toString:[describeField referenceTo]] forKey:@"referenceTo"];
            [fieldrecord setValue:[self toBoolValue:[describeField idLookup]] forKey:@"idLookup"];
            [fieldrecord setValue:[self toBoolValue:[describeField calculated]] forKey:@"calculated"];
            [fieldrecord setValue:[self toBoolValue:[describeField dependentPicklist]] forKey:@"dependentPicklist"];
            [fieldrecord setValue:[describeField controllerName] forKey:@"controllerName"];
            [fieldrecord setValue:[self toBoolValue:[describeField sortable]] forKey:@"sortable"];
            [fieldrecord setValue:[NSString stringWithFormat:@"%d",[describeField length]] forKey:@"length"];
            [fieldrecord setValue:[self toBoolValue:[describeField createable]] forKey:@"createable"];
            [fieldrecord setValue:[self toBoolValue:[describeField updateable]] forKey:@"updateable"];
            [fieldrecord setValue:[self toBoolValue:[describeField nillable]] forKey:@"nillable"];
            [fieldrecord setValue:[self toBoolValue:[describeField filterable]] forKey:@"filterable"];
            [fieldrecord setValue:[describeField relationshipName] forKey:@"relationshipName"];
            [fieldrecord setValue:[describeField calculatedFormula] forKey:@"calculatedFormula"];
            [fieldrecord setValue:[describeField defaultValueFormula] forKey:@"defaultValueFormula"];
            [fieldrecord setValue:[self toBoolValue:[describeField defaultOnCreate]] forKey:@"defaultedOnCreate"];
            [fieldrecord setValue:[self toBoolValue:[describeField restrictedPicklist]] forKey:@"restrictedPicklist"];
            [fieldrecord setValue:[self toBoolValue:[describeField externalId]] forKey:@"externalId"];
            
            [FieldInfoManager insert:[[Item alloc] init:self.entity fields:fieldrecord]];
            
            //PicklistInfo
            int order = 0;
            for(ZKPicklistEntry *picklistentry  in describeField.picklistValues){
                NSMutableDictionary *picklistrecord = [NSMutableDictionary dictionary];
                [picklistrecord setValue:self.entity forKey:@"entity"];
                [picklistrecord setValue:[describeField name] forKey:@"fieldname"];
                [picklistrecord setValue:[describeField label] forKey:@"fieldlabel"];
                [picklistrecord setValue:[describeField controllerName] forKey:@"controllerName"];
                [picklistrecord setValue:[self toBoolValue:[describeField dependentPicklist]] forKey:@"dependentPicklist"];
                [picklistrecord setValue:[self toInt:order] forKey:@"fieldorder"];
                [picklistrecord setValue:[picklistentry label] forKey:@"label"];
                [picklistrecord setValue:[picklistentry value] forKey:@"value"];
                [picklistrecord setValue:[picklistentry validFor] forKey:@"validFor"];
                [picklistrecord setValue:[self toBoolValue:[picklistentry active]] forKey:@"active"];
                [picklistrecord setValue:[self toBoolValue:[picklistentry defaultValue]] forKey:@"defaultValue"];
                [PicklistInfoManager insert:[[Item alloc] init:self.entity fields:picklistrecord]];
                order++;
            }
        }
        [EntityManager initTable:self.entity column:allColumns type:allTypes];
        [TransactionInfoManager save:[NSDictionary dictionaryWithObjectsAndKeys:[self getName],@"TaskName", [DatetimeHelper serverDateTime:[NSDate date]],@"LastSyncDate", nil]];
        
        [self.listener onSuccess:-1 request:self again:false];
    }
    if (error != nil)
    {
        [self didFailLoadWithError:[NSString stringWithFormat:@"%@", error]];
    }
}

- (void)didFailLoadWithError:(NSString*)error{
    [self.listener onFailure:[NSString stringWithFormat:@"Salesforce Error %@", error] request:self again:false];
}

- (NSString *)getName {
    return [NSString stringWithFormat:@"%@ Metadata incoming", self.entity];
}

- (BOOL)prepare {
    NSString *lastsyncDate= [TransactionInfoManager readLastSyncDate:[self getName]];
    return lastsyncDate == nil;
}

@end
