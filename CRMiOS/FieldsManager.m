//
//  FieldsManager.m
//  CRMiOS
//
//  Created by Sy Pauv on 5/11/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "FieldsManager.h"

// cache for crm fields
static NSMutableDictionary *cache;


@implementation FieldsManager

+ (void)initTable {
    Database *database = [Database getInstance];
    NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    [columns addObject:@"ObjectName"];
    [types addObject:@"TEXT"];
    [columns addObject:@"DisplayName"];
    [types addObject:@"TEXT"];
    [columns addObject:@"ElementName"];
    [types addObject:@"TEXT"];
    [columns addObject:@"DataType"];
    [types addObject:@"TEXT"];
    
    [database check:@"Field" columns:columns types:types];
    [columns release];
    [types release];
    
    // name index
    NSArray *indexColumns = [NSMutableArray arrayWithObjects:@"ObjectName", @"ElementName", Nil];
    [database createIndex:@"Field" columns:indexColumns unique:true];
    
}

+ (void)initData {
    cache = [[NSMutableDictionary alloc] initWithCapacity:1];
}



+ (void)purge:(NSString *)entity {
    Database *database = [Database getInstance];
    NSArray *criterias = [NSArray arrayWithObject:[ValuesCriteria criteriaWithColumn:@"ObjectName" value:entity]];
    [database remove:@"Picklist" criterias:criterias];
}

+ (void)insert:(NSDictionary *)fields {    
    [cache removeAllObjects];
    Database *database = [Database getInstance];
    [database insert:@"Field" item:fields];
}

// CRMOD getFields service is bugged and some fields are missing; we need to hardcode the missing fields here.
+ (NSArray *)missingFields:(NSString *)entity {
    NSMutableArray *fields = [[NSMutableArray alloc] initWithCapacity:1];
    if ([entity isEqualToString:@"CustomObject4"]) {
        [fields addObject:[[CRMField alloc] initWithCode:@"AccountId" displayName:NSLocalizedString(@"Account_SINGULAR", nil) type:@"ID" entity:entity]];
        [fields addObject:[[CRMField alloc] initWithCode:@"OpportunityId" displayName:NSLocalizedString(@"Opportunity_SINGULAR", nil) type:@"ID" entity:entity]];
    }
    if ([entity isEqualToString:@"Account Partner"] || [entity isEqualToString:@"Opportunity Partner"]) {
        [fields addObject:[[CRMField alloc] initWithCode:@"PrimaryContactId" displayName:NSLocalizedString(@"Contact_SINGULAR", nil) type:@"ID" entity:entity]];
        [fields addObject:[[CRMField alloc] initWithCode:@"RelationshipRole" displayName:@"Role" type:@"Picklist" entity:entity]];
        [fields addObject:[[CRMField alloc] initWithCode:@"ReverseRelationshipRole" displayName:@"Reverse Role" type:@"Picklist" entity:entity]];
        [fields addObject:[[CRMField alloc] initWithCode:@"PartnerId" displayName:NSLocalizedString(@"Partner_SINGULAR", nil) type:@"ID" entity:entity]];
    }
    if ([entity isEqualToString:@"Asset"]) {
        [fields addObject:[[CRMField alloc] initWithCode:@"AssetType" displayName:@"Type" type:@"Picklist" entity:entity]];
    }
    if ([entity isEqualToString:@"Activity"]) {
        [fields addObject:[[CRMField alloc] initWithCode:@"Completed" displayName:@"Completed" type:@"Checkbox" entity:entity]];
    }
    if ([entity isEqualToString:@"Opportunity"]) {
        [fields addObject:[[CRMField alloc] initWithCode:@"ParentoptyId" displayName:@"Parent Opportunity" type:@"ID" entity:entity]];
    }
    if ([entity isEqualToString:@"Opportunity ProductRevenue"]) {
        [fields addObject:[[CRMField alloc] initWithCode:@"ProductName" displayName:@"Product Name" type:@"Picklist" entity:entity]];
        [fields addObject:[[CRMField alloc] initWithCode:@"ProductId" displayName:NSLocalizedString(@"Product_SINGULAR", nil) type:@"ID" entity:entity]];
        [fields addObject:[[CRMField alloc] initWithCode:@"AccountName" displayName:@"Account Name" type:@"Picklist" entity:entity]];
        [fields addObject:[[CRMField alloc] initWithCode:@"AccountId" displayName:NSLocalizedString(@"Account_SINGULAR", nil) type:@"ID" entity:entity]];
        [fields addObject:[[CRMField alloc] initWithCode:@"Owner" displayName:@"Owner" type:@"Picklist" entity:entity]];
        [fields addObject:[[CRMField alloc] initWithCode:@"OwnerId" displayName:NSLocalizedString(@"User_SINGULAR", nil) type:@"ID" entity:entity]];
        [fields addObject:[[CRMField alloc] initWithCode:@"ProductCategory" displayName:@"Product Category" type:@"Picklist" entity:entity]];
        [fields addObject:[[CRMField alloc] initWithCode:@"ProductCategoryId" displayName:NSLocalizedString(@"Product Category", nil) type:@"ID" entity:entity]];
        // these values are 3m specific... hardcoded for now, should later be configured from the XML
        [fields addObject:[[CRMField alloc] initWithCode:@"CustomPickList0" displayName:NSLocalizedString(@"Product Category Auto", nil) type:@"Picklist" entity:entity]];
        [fields addObject:[[CRMField alloc] initWithCode:@"CustomText32" displayName:NSLocalizedString(@"Product Name Auto", nil) type:@"Text (Short)" entity:entity]];
    }
    if ([entity isEqualToString:@"Account Competitor"] || [entity isEqualToString:@"Opportunity Competitor"]) {
        [fields addObject:[[CRMField alloc] initWithCode:@"CompetitorId" displayName:NSLocalizedString(@"Competitor_SINGULAR", nil) type:@"ID" entity:entity]];
        [fields addObject:[[CRMField alloc] initWithCode:@"RelationshipRole" displayName:@"Role" type:@"Picklist" entity:entity]];
        [fields addObject:[[CRMField alloc] initWithCode:@"ReverseRelationshipRole" displayName:@"Reverse Role" type:@"Picklist" entity:entity]];
    }
    if ([entity hasSuffix:@"Attachment"]) {
        [fields addObject:[[CRMField alloc] initWithCode:@"FileNameOrURL" displayName:@"File Name or URL" type:@"Text (Short)" entity:entity]];
    }
    if ([entity isEqualToString:@"Activity Contact"]) {
        [fields addObject:[[CRMField alloc] initWithCode:@"Id" displayName:NSLocalizedString(@"Contact_SINGULAR", nil) type:@"ID" entity:entity]];
    }
    if ([entity isEqualToString:@"Opportunity ContactRole"]) {
        [fields addObject:[[CRMField alloc] initWithCode:@"Primary" displayName:@"Primary" type:@"Checkbox" entity:entity]];
    }
    return fields;
}

+ (NSString *)getSublistCode:(NSString *)entity sublist:(NSString *)sublist {
    NSString *sublistCode = [NSString stringWithFormat:@"%@ %@", entity, sublist];
    if ([sublist isEqualToString:@"Partner"] || [sublist isEqualToString:@"Competitor"] || [sublist isEqualToString:@"User"]) {
        sublistCode = [NSString stringWithFormat:@"%@%@", entity, sublist];
    }
    if ([sublist isEqualToString:@"ProductRevenue"]) {
        sublistCode = @"Revenue";
    }
    if ([sublist isEqualToString:@"Contact"] || [sublist isEqualToString:@"ContactRole"]) {
        sublistCode = @"Contact";
    }
    return sublistCode;
}

+ (NSString *)fixName:(NSString *)entity {
    if ([entity rangeOfString:@" "].location != NSNotFound) {
        NSArray *parts = [entity componentsSeparatedByString:@" "];
        return [FieldsManager getSublistCode:[parts objectAtIndex:0] sublist:[parts objectAtIndex:1]];
    }
    return entity;
}




+ (NSDictionary *)list:(NSString *)entity {
    Database *database = [Database getInstance];
    NSArray *fields = [NSArray arrayWithObjects:@"ElementName", @"DisplayName", @"DataType", nil];
    NSMutableArray *criterias = [[NSMutableArray alloc] initWithCapacity:1];
    [criterias addObject:[ValuesCriteria criteriaWithColumn:@"ObjectName" value:[FieldsManager fixName:entity]]];
    NSArray *tmp = [database select:@"Field" fields:fields criterias:criterias order:nil ascending:YES];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:1]; 
    for (NSDictionary *record in tmp) {
        CRMField *crmField = [[CRMField alloc] initWithCode:[record objectForKey:@"ElementName"] displayName:[record objectForKey:@"DisplayName"] type:[record objectForKey:@"DataType"] entity:entity];
        [result setObject:crmField forKey:crmField.code];
        [crmField release];
    }
    for (CRMField *crmField in [self missingFields:entity]) {
        [result setObject:crmField forKey:crmField.code];
    }
    [criterias release];
    [tmp release];
    return result;
}



+ (CRMField *)read:(NSString *)entity field:(NSString *)field {
    NSString *code = [NSString stringWithFormat:@"%@/%@", entity, field];
    if (cache == nil) {
        cache = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    // is the value in the cache ?
    CRMField *crmField = [cache objectForKey:code];
    if (crmField != nil) {
        return crmField;
    }
    Database *database = [Database getInstance];
    NSArray *fields = [NSArray arrayWithObjects:@"DisplayName", @"DataType", nil];
    NSMutableArray *criterias = [[NSMutableArray alloc] initWithCapacity:1];
    [criterias addObject:[ValuesCriteria criteriaWithColumn:@"ElementName" value:field]];
    [criterias addObject:[ValuesCriteria criteriaWithColumn:@"ObjectName" value:[FieldsManager fixName:entity]]];
    NSArray *results = [database select:@"Field" fields:fields criterias:criterias order:nil ascending:YES];
    [criterias release];
    if ([results count] == 0) {
        // see if it's one of the missing CRM fields
        for (CRMField *missing in [self missingFields:entity]) {
            if ([missing.code isEqualToString:field]) {
                crmField = missing;
                break;
            }
        }
        if (crmField == nil) {
            // could not find the field, let's build a mock field
            NSString *displayName = [EvaluateTools formatDisplayField:field];
            crmField = [[CRMField alloc] initWithCode:field displayName:displayName type:[field hasSuffix:@"Id"] ? @"ID" : @"Text (Short)" entity:entity];
            if ([field hasSuffix:@"Id"] && [field length] > 2) {
                NSString *entity = [field substringToIndex:field.length - 2];
                NSObject<Subtype> *sinfo = [Configuration getSubtypeInfo:entity];
                if (sinfo != nil) {
                    crmField = [[CRMField alloc] initWithCode:field displayName:[sinfo localizedName] type:@"ID" entity:entity];
                }
            }
        }
    } else {
        NSDictionary *record = [results objectAtIndex:0];
        crmField = [[CRMField alloc] initWithCode:field displayName:[record objectForKey:@"DisplayName"] type:[record objectForKey:@"DataType"] entity:entity];
        if ([crmField.type isEqualToString:@"ID"] && [field hasPrefix:[FieldsManager fixName:entity]]) {
            // replace oracle's name "ROW ID" by the entity name.
            NSObject<Subtype> *sinfo = [Configuration getSubtypeInfo:[FieldsManager fixName:entity]];
            crmField = [[CRMField alloc] initWithCode:field displayName:[sinfo localizedName] type:@"ID" entity:entity];
        }
    }
    [results release];
    // save the value in the cache
    [cache setObject:crmField forKey:code];
    return crmField;
}

+ (CRMField *)read:(NSString *)entity display:(NSString *)display {
    Database *database = [Database getInstance];
    NSArray *fields = [NSArray arrayWithObjects:@"ElementName", @"DataType", nil];
    NSMutableArray *criterias = [[NSMutableArray alloc] initWithCapacity:1];
    [criterias addObject:[ValuesCriteria criteriaWithColumn:@"DisplayName" value:display]];
    [criterias addObject:[ValuesCriteria criteriaWithColumn:@"ObjectName" value:[FieldsManager fixName:entity]]];
    NSArray *results = [database select:@"Field" fields:fields criterias:criterias order:nil ascending:YES];
    [criterias release];
    if ([results count] == 0) {
        return nil;
    }
    NSDictionary *record = [results objectAtIndex:0];
    CRMField *crmField = [[CRMField alloc] initWithCode:[record objectForKey:@"ElementName"] displayName:display type:[record objectForKey:@"DataType"] entity:entity];
    [results release];
    return crmField;
}

@end
