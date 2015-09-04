//
//  ExportCSV.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 3/21/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "ExportCSV.h"

@implementation ExportCSV

+ (void)writeFile:(NSString *)fullPath Data:(NSArray *)data type:(NSObject<Subtype> *)type {
    
    NSArray *sections = [LayoutSectionManager read:type.name page:0];
    NSArray *listData=[ExportCSV reloadData:data];
    NSMutableString *contentFile=[[[NSMutableString alloc]initWithCapacity:1] autorelease];
    NSMutableArray *allFieldinsects=[[[NSMutableArray alloc]initWithCapacity:1] autorelease];
    
    //get all field in sections
    for (Section *sect in sections) {
        [allFieldinsects addObjectsFromArray:sect.fields];
    }
    
    //loop add table header
    int i=0;
    for(NSString *field in allFieldinsects){
        i++;
        if (i<[allFieldinsects count]) {
            [contentFile appendFormat:@"%@,",field]; 
        }else{
            [contentFile appendFormat:@"%@\n",field];
        }
        
    }

    //loop add data rows
    for (Item *item in listData) {
        int j=0;
        for(NSString *field in allFieldinsects){
            NSString *value=[item.fields objectForKey:field];

            CRMField *crmfield = [FieldsManager read:item.entity field:field];
            value = [UITools formatPDFDisplayValue:crmfield value:item];
            
            value = [value stringByReplacingOccurrencesOfString:@"," withString:@""];
            j++;
            if (j<[allFieldinsects count]) {
                [contentFile appendFormat:@"%@,",value]; 
            }else{
                [contentFile appendFormat:@"%@\n",value];
            }
            
        }
    }
    
    [contentFile writeToFile:fullPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
}

+ (NSArray *)reloadData:(NSArray *)datas{
    NSMutableArray *listData = [[NSMutableArray alloc]initWithCapacity:1];
    for (Item *item in datas) {
        Item *it= [EntityManager find:item.entity column:@"gadget_id" value:[item.fields objectForKey:@"gadget_id"]];
        if (item!=nil) {
            [listData addObject:it];
        }
    }
    return listData;
}

@end
