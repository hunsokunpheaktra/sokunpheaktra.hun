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

@implementation DescribeLayoutRequest
-(void)doRequest{
    [[FDCServerSwitchboard switchboard] describeLayout:self.entity target:self selector:@selector(describeLayoutResult:error:context:) context:nil];
}

- (void)describeLayoutResult:(ZKDescribeLayoutResult *)result error:(NSError *)error context:(id)context
{
    NSLog(@"%@ describeLayoutResult: %@ error: %@ context: %@", self.entity,result, error, context);
    if (result != nil && error == nil)
    {
        //RecordTypeMappingInfo
        for(ZKRecordTypeMapping *recordTypeMapping in result.recordTypeMappings){
            //            - (BOOL) available;
            //            - (BOOL) defaultRecordTypeMapping; 
            //            - (NSString *) layoutId;
            //            - (NSString *) name;
            //            - (NSArray *) picklistsForRecordType;
            //            - (NSString *) recordTypeId;
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
                //                - (NSString *) picklistName; 
                //                - (NSArray *) picklistValues;
                NSMutableDictionary *picklistForRecordTyperecord = [NSMutableDictionary dictionary];
                [picklistForRecordTyperecord setValue:self.entity forKey:@"entity"];
                [picklistForRecordTyperecord setValue:[recordTypeMapping recordTypeId] forKey:@"recordTypeId"];
                [picklistForRecordTyperecord setValue:[picklistforRecordType picklistName] forKey:@"picklistName"];
                int order = 0;
                for(ZKPicklistEntry *picklistentry  in [picklistforRecordType picklistValues]){
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
                //                - (NSArray *) columns;
                //                - (BOOL) custom;
                //                - (NSString *) field;
                //                - (NSString *) label;
                //                - (NSInteger ) limitRows;
                //                - (NSString *) name;
                //                - (NSString *) sobject;
                //                - (NSArray *) sort;
                //                
                //                - (NSString *) columnsFieldNames ;
                //                - (NSString *) describe ;
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
                
                
                //RelatedListColumnInfo
                for(ZKRelatedListColumn *relatedlistcolumn in ralatedlist.columns){
                    //                    - (NSString *) field;
                    //                    - (NSString *) format;
                    //                    - (NSString *) label;
                    //                    - (NSString *) name;
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
                    //                    - (BOOL) ascending;
                    //                    - (NSString * ) column;
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
            //            - (NSArray *) detailLayoutSections;
            //            - (NSArray *) editLayoutSections;
            //            - (NSString *) Id;
            //            - (NSArray *) relatedLists;
            
                      //DetailLayoutSectionsInfo
            for(ZKDescribeLayoutSection *describelayoutsection in describelayout.detailLayoutSections){
                //                - (BOOL) useCollapsibleSection;
                //                - (BOOL) useHeading;
                //                - (NSString *) heading;
                //                - (NSInteger ) columns;
                //                - (NSInteger ) rows;
                NSMutableDictionary *detaillayoutrecord = [NSMutableDictionary dictionary];
                [detaillayoutrecord setValue:self.entity forKey:@"entity"];
                [detaillayoutrecord setValue:describelayout.Id forKey:@"Id"];
                [detaillayoutrecord setValue:[self toBoolValue:describelayoutsection.useCollapsibleSection] forKey:@"useCollapsibleSection"];
                [detaillayoutrecord setValue:[self toBoolValue:describelayoutsection.useHeading] forKey:@"useHeading"];
                [detaillayoutrecord setValue:describelayoutsection.heading forKey:@"heading"];
                [detaillayoutrecord setValue:[self toInt:describelayoutsection.columns] forKey:@"columns"];
                [detaillayoutrecord setValue:[self toInt:describelayoutsection.rows] forKey:@"rows"];
                
                for(ZKDescribeLayoutRow *describelayoutrow  in describelayoutsection.layoutRows){
                    //                    numItems
                    [detaillayoutrecord setValue:[self toInt:describelayoutrow.numItems] forKey:@"numItems"];
                    for(ZKDescribeLayoutItem *layoutitem in describelayoutrow.layoutItems){
                        //                        - (BOOL) editable;
                        //                        - (BOOL) placeholder;
                        //                        - (BOOL) required;
                        //                        - (NSString *)label;
                        
                        [detaillayoutrecord setValue:[self toBoolValue:layoutitem.editable] forKey:@"editable"];
                        [detaillayoutrecord setValue:[self toBoolValue:layoutitem.placeholder] forKey:@"placeholder"];
                        [detaillayoutrecord setValue:[self toBoolValue:layoutitem.required] forKey:@"required"];
                        [detaillayoutrecord setValue:layoutitem.label forKey:@"label"];
                       
                        for(ZKDescribeLayoutComponent *layoutcomponent in layoutitem.layoutComponents){
                            //                            - (NSString *)type; /*<enumeration value="Field"/>
                            //                                                 <enumeration value="Separator"/>
                            //                                                 <enumeration value="SControl"/>
                            //                                                 <enumeration value="EmptySpace"/>*/
                            //                            - (NSString *)value;
                            //                            - (NSInteger )tabOrder;
                            //                            - (NSInteger )displayLines;
                            [detaillayoutrecord setValue:layoutcomponent.type forKey:@"type"];
                            [detaillayoutrecord setValue:layoutcomponent.value forKey:@"value"];
                            [detaillayoutrecord setValue:[self toInt:layoutcomponent.tabOrder] forKey:@"tabOrder"];
                            [detaillayoutrecord setValue:[self toInt:layoutcomponent.displayLines] forKey:@"displayLines"];
                            
                            [DetailLayoutSectionsInfoManager insert:[[Item alloc] init:self.entity fields:detaillayoutrecord]];
                             
        
                        }
                    }
                }
            }
            
            //EditLayoutSectionsInfo
            for(ZKDescribeLayoutSection *describelayoutsection in describelayout.editLayoutSections){
                //                - (BOOL) useCollapsibleSection;
                //                - (BOOL) useHeading;
                //                - (NSString *) heading;
                //                - (NSInteger ) columns;
                //                - (NSInteger ) rows;
                NSMutableDictionary *editlayoutrecord = [NSMutableDictionary dictionary];
                [editlayoutrecord setValue:self.entity forKey:@"entity"];
                [editlayoutrecord setValue:describelayout.Id forKey:@"Id"];
                [editlayoutrecord setValue:[self toBoolValue:describelayoutsection.useCollapsibleSection] forKey:@"useCollapsibleSection"];
                [editlayoutrecord setValue:[self toBoolValue:describelayoutsection.useHeading] forKey:@"useHeading"];
                [editlayoutrecord setValue:describelayoutsection.heading forKey:@"heading"];
                [editlayoutrecord setValue:[self toInt:describelayoutsection.columns] forKey:@"columns"];
                [editlayoutrecord setValue:[self toInt:describelayoutsection.rows] forKey:@"rows"];
                
                for(ZKDescribeLayoutRow *describelayoutrow  in describelayoutsection.layoutRows){
                    //                    numItems
                    [editlayoutrecord setValue:[self toInt:describelayoutrow.numItems] forKey:@"numItems"];
                    for(ZKDescribeLayoutItem *layoutitem in describelayoutrow.layoutItems){
                        //                        - (BOOL) editable;
                        //                        - (BOOL) placeholder;
                        //                        - (BOOL) required;
                        //                        - (NSString *)label;
                        [editlayoutrecord setValue:[self toBoolValue:layoutitem.editable] forKey:@"editable"];
                        [editlayoutrecord setValue:[self toBoolValue:layoutitem.placeholder] forKey:@"placeholder"];
                        [editlayoutrecord setValue:[self toBoolValue:layoutitem.required] forKey:@"required"];
                        [editlayoutrecord setValue:layoutitem.label forKey:@"label"];
                        for(ZKDescribeLayoutComponent *layoutcomponent in layoutitem.layoutComponents){
                            //                            - (NSString *)type; /*<enumeration value="Field"/>
                            //                                                 <enumeration value="Separator"/>
                            //                                                 <enumeration value="SControl"/>
                            //                                                 <enumeration value="EmptySpace"/>*/
                            //                            - (NSString *)value;
                            //                            - (NSInteger )tabOrder;
                            //                            - (NSInteger )displayLines;
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
        
        [TransactionInfoManager save:[NSDictionary dictionaryWithObjectsAndKeys:[self getName],@"TaskName", [DatetimeHelper serverDateTime:[NSDate date]],@"LastSyncDate", nil]];
        
        [self.listener onSuccess:-1 request:self again:false];
    }
    if (error != nil)
    {
        [self didFailLoadWithError:[NSString stringWithFormat:@"%@", error]];
    }
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
@end
