//
//  DescribeLayoutRequest.m
//  SyncForce
//
//  Created by Gaeasys Admin on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DescribeLayoutRequest.h"
#import "EntityInfoManager.h"
#import "FieldInfoManager.h"
#import "Item.h"
#import "SFRequest.h"
#import "FDCServerSwitchboard.h"
#import "SyncProcess.h"
#import "ZKSforce.h"
#import "TransactionInfoManager.h"
#import "DatetimeHelper.h"
#import "ZKDescribeLayout.h"
#import "ZKDescribeLayoutSection.h"
#import "ZKDescribeLayoutRow.h"
#import "ZKDescribeLayoutItem.h"
#import "ZKDescribeLayoutComponent.h"
#import "EditLayoutSectionsInfoManager.h"
#import "DetailLayoutSectionsInfoManager.h"
#import "ZKRelatedList.h"
#import "BypassInRequest.h"
#import "ZKRecordTypeMapping.h"
#import "RecordTypeMappingInfoManager.h"
#import "ZKPicklistEntry.h"
#import "PicklistForRecordTypeInfoManager.h"
#import "ZKRelatedListColumn.h"
#import "ZKRelatedListSort.h"
#import "RelatedListsInfoManager.h"
#import "RelatedListColumnInfoManager.h"
#import "RelatedListSortInfoManager.h"
#import "EntityLevel.h"

@implementation DescribeLayoutRequest

-(void)doRequest{
    
    [[FDCServerSwitchboard switchboard] describeLayout:self.entity target:self selector:@selector(describeLayoutResult:error:context:) context:nil];
}

- (void)describeLayoutResult:(ZKDescribeLayoutResult *)result error:(NSError *)error context:(id)context
{
    listFiledLayout = [[NSMutableArray alloc] init];
    listMany2OneRelation = [[NSMutableArray alloc] init]; 
    
    NSLog(@"%@ describeLayoutResult: %@ error: %@ context: %@", self.entity,result, error, context);
    if (result != nil && error == nil)
    {
        //RecordTypeMappingInfo
        for(ZKRecordTypeMapping *recordTypeMapping in result.recordTypeMappings){
            
            NSMutableDictionary *recordTypeMappingrecord = [NSMutableDictionary dictionary];
            [recordTypeMappingrecord setValue:self.entity forKey:@"entity"];
            [recordTypeMappingrecord setValue:[self toBoolValue:[recordTypeMapping available]] forKey:@"available"];
            [recordTypeMappingrecord setValue:[self toBoolValue:[recordTypeMapping defaultRecordTypeMapping]] forKey:@"defaultRecordTypeMapping"];
            [recordTypeMappingrecord setValue:[recordTypeMapping name] forKey:@"name"];
            [recordTypeMappingrecord setValue:[recordTypeMapping layoutId] forKey:@"layoutId"];
            [recordTypeMappingrecord setValue:[recordTypeMapping recordTypeId] forKey:@"recordTypeId"];
            [RecordTypeMappingInfoManager insert:[[Item alloc] init:self.entity fields:recordTypeMappingrecord]];
            
            //PicklistForRecordTypeInfo
            for(ZKPicklistForRecordType *picklistforRecordType in recordTypeMapping.picklistsForRecordType){
                
                NSMutableDictionary *picklistForRecordTyperecord = [NSMutableDictionary dictionary];
                [picklistForRecordTyperecord setValue:self.entity forKey:@"entity"];
                [picklistForRecordTyperecord setValue:[recordTypeMapping recordTypeId] forKey:@"recordTypeId"];
                [picklistForRecordTyperecord setValue:[picklistforRecordType picklistName] forKey:@"picklistName"];
                int order = 0;
                
                for(ZKPicklistEntry *picklistentry in picklistforRecordType.picklistValues){
                    [picklistForRecordTyperecord setValue:[self toInt:order] forKey:@"fieldorder"];
                    [picklistForRecordTyperecord setValue:[picklistentry label] forKey:@"label"];
                    [picklistForRecordTyperecord setValue:[picklistentry value] forKey:@"value"];
                    [picklistForRecordTyperecord setValue:[picklistentry validFor] forKey:@"validFor"];
                    [picklistForRecordTyperecord setValue:[self toBoolValue:[picklistentry active]] forKey:@"active"];
                    [picklistForRecordTyperecord setValue:[self toBoolValue:[picklistentry defaultValue]] forKey:@"defaultValue"];
                    [PicklistForRecordTypeInfoManager insert:[[Item alloc] init:self.entity fields:picklistForRecordTyperecord]];
                    order++;
                }
            }
        }
        
        
        for (ZKDescribeLayout * describeRelatedList in  result.layouts) {
            
            //RelatedListsInfo
            for(ZKRelatedList *ralatedlist in describeRelatedList.relatedLists){
                
                NSMutableDictionary *relatedlistrecord = [NSMutableDictionary dictionary];
                [relatedlistrecord setValue:self.entity forKey:@"entity"];
                [relatedlistrecord setValue:[self toBoolValue:ralatedlist.custom] forKey:@"custom"];
                [relatedlistrecord setValue:ralatedlist.field forKey:@"field"];
                [relatedlistrecord setValue:ralatedlist.label forKey:@"label"];
                [relatedlistrecord setValue:[self toInt:ralatedlist.limitRows] forKey:@"limitRows"];
                [relatedlistrecord setValue:ralatedlist.name forKey:@"name"];
                [relatedlistrecord setValue:ralatedlist.sobject forKey:@"sobject"];
                [relatedlistrecord setValue:ralatedlist.columnsFieldNames forKey:@"columnsFieldNames"];
                [relatedlistrecord setValue:ralatedlist.describe forKey:@"describe"];
                
                [RelatedListsInfoManager insert:[[Item alloc] init:self.entity fields:relatedlistrecord]];
                
                if ([self isAbleToQuery:ralatedlist.sobject])
                    [listMany2OneRelation addObject:ralatedlist.sobject];
                    
                //RelatedListColumnInfo
                for(ZKRelatedListColumn *relatedlistcolumn in ralatedlist.columns){
                    
                    NSMutableDictionary *relatedlistcolumnrecord = [NSMutableDictionary dictionary];
                    [relatedlistcolumnrecord setValue:self.entity forKey:@"entity"];
                    [relatedlistcolumnrecord setValue:ralatedlist.sobject forKey:@"sobject"];
                    [relatedlistcolumnrecord setValue:relatedlistcolumn.field forKey:@"field"];
                    [relatedlistcolumnrecord setValue:relatedlistcolumn.format forKey:@"format"];
                    [relatedlistcolumnrecord setValue:relatedlistcolumn.label forKey:@"label"];
                    [relatedlistcolumnrecord setValue:relatedlistcolumn.name forKey:@"name"];
                    [RelatedListColumnInfoManager insert:[[Item alloc] init:self.entity fields:relatedlistcolumnrecord]];
                }
                
                //RelatedListSortInfo
                for(ZKRelatedListSort *relatedlistsort in ralatedlist.sort){
                    
                    NSMutableDictionary *relatedlistsortrecord = [NSMutableDictionary dictionary];
                    [relatedlistsortrecord setValue:self.entity forKey:@"entity"];
                    [relatedlistsortrecord setValue:ralatedlist.sobject forKey:@"sobject"];
                    [relatedlistsortrecord setValue:relatedlistsort.column forKey:@"column"];
                    [relatedlistsortrecord setValue:[self toBoolValue:relatedlistsort.ascending] forKey:@"ascending"];
                    [RelatedListSortInfoManager insert:[[Item alloc] init:self.entity fields:relatedlistsortrecord]];
                }
                
            }
            
            break;
            
        }
        
        for(ZKDescribeLayout *describelayout in result.layouts){
            
            //DetailLayoutSectionsInfo
            for(ZKDescribeLayoutSection *describelayoutsection in describelayout.detailLayoutSections){
            
                NSMutableDictionary *detaillayoutrecord = [NSMutableDictionary dictionary];
                [detaillayoutrecord setValue:self.entity forKey:@"entity"];
                [detaillayoutrecord setValue:describelayout.Id forKey:@"Id"];
                [detaillayoutrecord setValue:[self toBoolValue:describelayoutsection.useCollapsibleSection] forKey:@"useCollapsibleSection"];
                [detaillayoutrecord setValue:[self toBoolValue:describelayoutsection.useHeading] forKey:@"useHeading"];
                [detaillayoutrecord setValue:describelayoutsection.heading forKey:@"heading"];
                [detaillayoutrecord setValue:[self toInt:describelayoutsection.columns] forKey:@"columns"];
                [detaillayoutrecord setValue:[self toInt:describelayoutsection.rows] forKey:@"rows"];
                
                for(ZKDescribeLayoutRow *describelayoutrow in describelayoutsection.layoutRows){
                    
                    [detaillayoutrecord setValue:[self toInt:describelayoutrow.numItems] forKey:@"numItems"];
                    for(ZKDescribeLayoutItem *layoutitem in describelayoutrow.layoutItems){
                        
                        [detaillayoutrecord setValue:[self toBoolValue:layoutitem.editable] forKey:@"editable"];
                        [detaillayoutrecord setValue:[self toBoolValue:layoutitem.placeholder] forKey:@"placeholder"];
                        [detaillayoutrecord setValue:[self toBoolValue:layoutitem.required] forKey:@"required"];
                        [detaillayoutrecord setValue:layoutitem.label forKey:@"label"];
                        
                        for(ZKDescribeLayoutComponent *layoutcomponent in layoutitem.layoutComponents){
                            
                            [detaillayoutrecord setValue:layoutcomponent.type forKey:@"type"];
                            [detaillayoutrecord setValue:layoutcomponent.value forKey:@"value"];
                            [detaillayoutrecord setValue:[self toInt:layoutcomponent.tabOrder] forKey:@"tabOrder"];
                            [detaillayoutrecord setValue:[self toInt:layoutcomponent.displayLines] forKey:@"displayLines"];
                            
                            [DetailLayoutSectionsInfoManager insert:[[Item alloc] init:self.entity fields:detaillayoutrecord]];
                            
                            if (![layoutcomponent.value isEqualToString:@","])
                                [listFiledLayout addObject:layoutcomponent.value];
                            
                        }
                    }
                }
            }
            
            //EditLayoutSectionsInfo
            for(ZKDescribeLayoutSection *describelayoutsection in describelayout.editLayoutSections){
                
                NSMutableDictionary *editlayoutrecord = [NSMutableDictionary dictionary];
                [editlayoutrecord setValue:self.entity forKey:@"entity"];
                [editlayoutrecord setValue:describelayout.Id forKey:@"Id"];
                [editlayoutrecord setValue:[self toBoolValue:describelayoutsection.useCollapsibleSection] forKey:@"useCollapsibleSection"];
                [editlayoutrecord setValue:[self toBoolValue:describelayoutsection.useHeading] forKey:@"useHeading"];
                [editlayoutrecord setValue:describelayoutsection.heading forKey:@"heading"];
                [editlayoutrecord setValue:[self toInt:describelayoutsection.columns] forKey:@"columns"];
                [editlayoutrecord setValue:[self toInt:describelayoutsection.rows] forKey:@"rows"];
                
                for(ZKDescribeLayoutRow *describelayoutrow  in describelayoutsection.layoutRows){
                    
                    [editlayoutrecord setValue:[self toInt:describelayoutrow.numItems] forKey:@"numItems"];
                    for(ZKDescribeLayoutItem *layoutitem in describelayoutrow.layoutItems){
                        
                        [editlayoutrecord setValue:[self toBoolValue:layoutitem.editable] forKey:@"editable"];
                        [editlayoutrecord setValue:[self toBoolValue:layoutitem.placeholder] forKey:@"placeholder"];
                        [editlayoutrecord setValue:[self toBoolValue:layoutitem.required] forKey:@"required"];
                        [editlayoutrecord setValue:layoutitem.label forKey:@"label"];
                        
                        for(ZKDescribeLayoutComponent *layoutcomponent in layoutitem.layoutComponents){
                            
                            [editlayoutrecord setValue:layoutcomponent.type forKey:@"type"];
                            [editlayoutrecord setValue:layoutcomponent.value forKey:@"value"];
                            [editlayoutrecord setValue:[self toInt:layoutcomponent.tabOrder] forKey:@"tabOrder"];
                            [editlayoutrecord setValue:[self toInt:layoutcomponent.displayLines] forKey:@"displayLines"];
                            
                            [EditLayoutSectionsInfoManager insert:[[Item alloc] init:self.entity fields:editlayoutrecord]];
                        }
                    }
                }
            }
        }
        
        [EntityLevel save:[NSDictionary dictionaryWithObjectsAndKeys:self.entity,@"EntityName", [NSString stringWithFormat:@"%d",level],@"Level", nil]];
        [TransactionInfoManager save:[NSDictionary dictionaryWithObjectsAndKeys:[self getName],@"TaskName", [DatetimeHelper serverDateTime:[NSDate date]],@"LastSyncDate", nil]];
        
        [self.listener addRequests:[self getOne2OneRelation] level:self.level];
        [self.listener addRequests:listMany2OneRelation level:self.level];
        [self.listener onSuccess:-1 request:self again:false];
    }
    if (error != nil)
    {
        [self didFailLoadWithError:[NSString stringWithFormat:@"%@", error]];
    }
}

-(void)dealloc{
    [listFiledLayout release];
    [listMany2OneRelation release];
    [super dealloc];
}

- (void)didFailLoadWithError:(NSString*)error{
    [self.listener onFailure:[NSString stringWithFormat:@"Salesforce Error %@", error] request:self again:NO];
}

- (NSString *)getName {
    return [NSString stringWithFormat:@"%@ Layout incoming", self.entity];
}

- (BOOL)prepare {
    if([[BypassInRequest getBypass] containsObject:self.entity]){
        return NO;
    }
    self.entityInfo = [InfoFactory getInfo:self.entity];
    if([[self.entityInfo getAllFields] count] < 1) return NO;
    NSString *lastsyncDate= [TransactionInfoManager readLastSyncDate:[self getName]];
    return lastsyncDate == nil;
    
}

-(NSArray*) getOne2OneRelation {
    
    NSMutableArray* listOne2OneRelation = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *criteria = [NSMutableDictionary dictionary];
    [criteria setValue:[[[ValuesCriteria alloc] initWithString:self.entity] autorelease] forKey:@"entity"];
    [criteria setValue:[[[ValuesCriteria alloc] initWithString:@"reference"] autorelease] forKey:@"type"];
    
    NSArray* listFiled = [FieldInfoManager list:criteria];
    
    for (Item* item in listFiled) {
        
        NSString *fieldName = [item.fields valueForKey:@"name"];
        if ([listFiledLayout containsObject:fieldName]) {
            
            if (!([self.entity isEqualToString:@"Event"] && [fieldName isEqualToString:@"WhatId"])){
                
                NSArray *listReference = [[item.fields objectForKey:@"referenceTo"] componentsSeparatedByString:@","];
                for (NSString *lookUpField in listReference){
                
                    if([self isAbleToQuery:lookUpField]) {
                        [listOne2OneRelation addObject:lookUpField];
                    }
                
                }
            }
        } 
    }
    
    return listOne2OneRelation;
}


-(BOOL) isAbleToQuery :(NSString*) entityName{
    
    if ([[SyncProcess getInstance].list_ignore_sobject containsObject:entityName]) return FALSE; 
    if ([[SyncProcess getInstance].list_ignore_child_query containsObject:entityName]) return FALSE;
    
    return TRUE;
}


@end
