//
//  LayoutFieldManager.m
//  CRMiOS
//
//  Created by Sy Pauv on 6/20/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "LayoutFieldManager.h"


@implementation LayoutFieldManager

+ (void)initTable {    
    Database *database = [Database getInstance];
    
    NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    [columns addObject:@"subtype"];
    [types addObject:@"INTEGER"];
    [columns addObject:@"page"];
    [types addObject:@"INTEGER"];
    [columns addObject:@"section"];
    [types addObject:@"INTEGER"];
    [columns addObject:@"row"];
    [types addObject:@"INTEGER"];
    [columns addObject:@"field"];
    [types addObject:@"TEXT"];
    [columns addObject:@"custom1"];
    [types addObject:@"TEXT"];
    if ([database check:@"LayoutField" columns:columns types:types dontwant:[NSArray arrayWithObjects:@"subtypecolumn", @"entity", nil]] == NO) {
        [PropertyManager save:@"configLevel" value:@"O"];
    }
    [columns release];
    [types release];
    
    [database createIndex:@"LayoutField" columns:[NSArray arrayWithObjects:@"subtype", @"page", @"section", @"row", nil] unique:true];
    
}

+ (void)initData {
    // check if the configuration version is higher than current 
    
    Configuration *configuration = [Configuration getInstance];
    int currentLevel = [[PropertyManager read:@"configLevel"] intValue];
    int confLevel = [configuration.level intValue];
    
    if (confLevel != currentLevel) {
        [LayoutFieldManager apply:configuration];
    }
    
}

+ (void)apply:(Configuration *)configuration {
    
    [PropertyManager save:@"configLevel" value:[NSString stringWithFormat:@"%i", [configuration.level intValue]]];
    [[Database getInstance] remove:@"LayoutField" criterias:nil];
    [[Database getInstance] remove:@"LayoutSection" criterias:nil];
    [[Database getInstance] remove:@"LayoutPage" criterias:nil];
    
    for (ConfigSubtype *configSubtype in configuration.subtypes) {
        int j = 0;
        for (Page *page in configSubtype.detailLayout.pages) {
            [LayoutPageManager save:configSubtype.name page:j name:page.name];
            int k = 0;
            for (Section *section in page.sections) {
                [LayoutSectionManager save:configSubtype.name page:j section:k name:section.name isGrouping:section.isGrouping];
                int l = 0;
                for (NSString *field in section.fields) {
                    [LayoutFieldManager insert:configSubtype.name page:j section:k row:l field:field];
                    l++;
                }
                k++;
            }
            j++;
        }
    }
    
}

+ (void)save:(NSString *)subtype page:(int)page section:(int)section fields:(NSArray *)fields {
    int row = 0;
    NSMutableArray *criterias = [[NSMutableArray alloc] init];
    [criterias addObject:[ValuesCriteria criteriaWithColumn:@"subtype" value:subtype]];
    [criterias addObject:[ValuesCriteria criteriaWithColumn:@"page" integer:page]];
    [criterias addObject:[ValuesCriteria criteriaWithColumn:@"section" integer:section]];
    [[Database getInstance] remove:@"LayoutField" criterias:criterias];
    for (NSString *field in fields) {
        NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
        [item setObject:[NSString stringWithFormat:@"%@", subtype] forKey:@"subtype"];
        [item setObject:[NSString stringWithFormat:@"%i", page] forKey:@"page"];
        [item setObject:[NSString stringWithFormat:@"%i", section] forKey:@"section"];
        [item setObject:[NSString stringWithFormat:@"%i", row] forKey:@"row"];
        [item setObject:field forKey:@"field"];
        [item setObject:@"" forKey:@"custom1"];
        [[Database getInstance] insert:@"LayoutField" item:item];
        row++;
    }
    
}


+ (void)insert:(NSString *)subtype page:(int)page section:(int)section row:(int)row field:(NSString *)field {
    
    NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
    [item setObject:[NSString stringWithFormat:@"%i", page] forKey:@"page"];
    [item setObject:[NSString stringWithFormat:@"%@", subtype] forKey:@"subtype"];
    [item setObject:[NSString stringWithFormat:@"%i", section] forKey:@"section"];
    [item setObject:[NSString stringWithFormat:@"%i", row] forKey:@"row"];
    [item setObject:field forKey:@"field"];
    [item setObject:@"" forKey:@"custom1"];
    [[Database getInstance] insert:@"LayoutField" item:item];
    
}


+ (NSArray *)read:(NSString *)subtype page:(int)page section:(int)section {
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *criterias = [[NSMutableArray alloc]initWithCapacity:1];
    
    [criterias addObject:[ValuesCriteria criteriaWithColumn:@"subtype" value:subtype]];
    
    [criterias addObject:[ValuesCriteria criteriaWithColumn:@"page" integer:page]];
    [criterias addObject:[ValuesCriteria criteriaWithColumn:@"section" integer:section]];
    
    NSMutableArray *fields = [[NSMutableArray alloc] initWithCapacity:1];
    
    [fields addObject:@"field"];
    
    NSArray *tmp = [[Database getInstance]select:@"LayoutField" fields:fields criterias:criterias order:@"row" ascending:YES];
    for (NSMutableDictionary *item in tmp) {
        [result addObject:[item objectForKey:@"field"]];
    }
    [tmp release];
    [criterias release];
    return result;
}

@end
