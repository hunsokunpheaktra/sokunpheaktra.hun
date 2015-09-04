//
//  PicklistManager.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/10/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "PicklistManager.h"


@implementation PicklistManager

+ (void)initTable {
    Database *database = [Database getInstance];
    
    NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    [columns addObject:@"ObjectName"];
    [types addObject:@"TEXT"];
    [columns addObject:@"Name"];
    [types addObject:@"TEXT"];
    [columns addObject:@"ValueId"];
    [types addObject:@"TEXT"];
    [columns addObject:@"Disabled"];
    [types addObject:@"TEXT"];
    [columns addObject:@"LanguageCode"];
    [types addObject:@"TEXT"];
    [columns addObject:@"Value"];
    [types addObject:@"TEXT"];
    [columns addObject:@"Order1"];
    [types addObject:@"INTEGER"];
    
    [database check:@"Picklist" columns:columns types:types];
    
    NSMutableArray *indexColumns;
    // unicity 
    indexColumns = [NSMutableArray arrayWithObjects:@"ObjectName", @"Name", @"ValueId", @"LanguageCode", Nil];
    [database createIndex:@"Picklist" columns:indexColumns unique:true];
    
    // name index
    indexColumns = [NSMutableArray arrayWithObjects:@"ObjectName", @"Name", Nil];
    [database createIndex:@"Picklist" columns:indexColumns unique:false];
}

+ (void)initData {
    
}


+ (void)insert:(NSDictionary *)picklist {
    Database *database = [Database getInstance];
    [database insert:@"Picklist" item:picklist];
}

+ (void)purge:(NSString *)field entity:(NSString *)entity {
    Database *database = [Database getInstance];
    NSArray *criterias = [NSArray arrayWithObjects:[ValuesCriteria criteriaWithColumn:@"ObjectName" value:entity], [ValuesCriteria criteriaWithColumn:@"Name" value:field], nil];
    [database remove:@"Picklist" criterias:criterias];
}

+ (NSString *)fixName:(NSString *)entity {
    if ([entity rangeOfString:@"ContactRole"].location != NSNotFound) {
        return @"Contact";
    }
    if ([entity rangeOfString:@"ProductRevenue"].location != NSNotFound) {
        return @"Revenue";
    }
    if ([entity isEqualToString:@"Account Partner"] || [entity isEqualToString:@"Opportunity Partner"]
        || [entity isEqualToString:@"Account Competitor"]|| [entity isEqualToString:@"Opportunity Competitor"]) {
        return @"AccountRelationship";
    }
    return entity;
}

+ (NSArray *)read:(NSString *)entity field:(NSString *)field languageCode:(NSString *)languageCode filterText:(NSString *)filterText {
    NSArray *fields = [NSArray arrayWithObjects:@"ValueId", @"Value", Nil];
    NSMutableArray *criterias = [[NSMutableArray alloc] initWithCapacity:1];
    [criterias addObject:[ValuesCriteria criteriaWithColumn:@"LanguageCode" value:languageCode]];
    [criterias addObject:[ValuesCriteria criteriaWithColumn:@"Disabled" value:@"false"]];
    [criterias addObject:[ValuesCriteria criteriaWithColumn:@"Name" value:field]];
    [criterias addObject:[ValuesCriteria criteriaWithColumn:@"ObjectName" value:[PicklistManager fixName:entity]]];
    if (filterText != nil) {
        [criterias addObject:[[LikeCriteria alloc] initWithColumn:@"Value" value:filterText]];
    }
    NSArray *result = [[Database getInstance] select:@"Picklist" fields:fields criterias:criterias order:@"Order1" ascending:YES];
    [criterias release];
    
    return result;
}

+ (NSString *)getPicklistDisplay:(NSString *)entity field:(NSString *)field value:(NSString *)value {
    NSArray *picklist = [PicklistManager getPicklist:entity field:field item:nil];
    NSString *displayValue = nil;
    for (NSDictionary *item in picklist) {
        if ([[item objectForKey:@"ValueId"] isEqualToString:value]) {
            displayValue = [item objectForKey:@"Value"];
            break;
        }
    }
    [picklist release];
    return displayValue;
}


+ (NSArray *)getPicklist:(NSString *)entity field:(NSString *)field item:(Item *)item filterText:(NSString*)filterText {
    entity = [PicklistManager fixName:entity];
    NSString *languageCode = [CurrentUserManager getLanguageCode];
    NSMutableArray *picklist = [[NSMutableArray alloc] initWithCapacity:1];

    
    if (filterText == nil) {
        NSMutableDictionary *picklistItem = [[NSMutableDictionary alloc] initWithCapacity:1];
        [picklistItem setObject:@"" forKey:@"Value"];
        [picklistItem setObject:@"" forKey:@"ValueId"];
        [picklist addObject:picklistItem];
        [picklistItem release];
    }
    
    if (([entity isEqualToString:@"Account"] || [entity isEqualToString:@"Lead"]) && [field isEqualToString:@"Industry"]) {
        for (NSDictionary *tmp in [IndustryManager read:languageCode filter:filterText]) {
            NSMutableDictionary *picklistItem = [[NSMutableDictionary alloc] initWithCapacity:1];
            [picklistItem setObject:[tmp objectForKey:@"Title"] forKey:@"Value"];
            [picklistItem setObject:[tmp objectForKey:@"Title"] forKey:@"ValueId"];
            [picklist addObject:picklistItem];
        }
        return picklist;
    } else if ([entity isEqualToString:@"Opportunity"] && [field isEqualToString:@"SalesStage"]) {
        for (NSDictionary *tmp in [SalesStageManager read:[item.fields objectForKey:@"OpportunityType"]]) {
            NSMutableDictionary *picklistItem = [[NSMutableDictionary alloc] initWithCapacity:1];
            [picklistItem setObject:[tmp objectForKey:@"Name"] forKey:@"Value"];
            [picklistItem setObject:[tmp objectForKey:@"Name"] forKey:@"ValueId"];
            [picklistItem setObject:[tmp objectForKey:@"Probability"] forKey:@"Probability"];
            [picklist addObject:picklistItem];
        }
        return picklist;
    } else if ([field isEqualToString:@"CurrencyCode"]) {
        for (NSDictionary *tmp in [CurrencyManager read:filterText]) {
            NSMutableDictionary *picklistItem = [[NSMutableDictionary alloc] initWithCapacity:1];
            [picklistItem setObject:[NSString stringWithFormat:@"%@ - %@",[tmp objectForKey:@"Name"], [tmp objectForKey:@"issuingCountry"]] forKey:@"Value"];
            [picklistItem setObject:[tmp objectForKey:@"Code"] forKey:@"ValueId"];
            [picklist addObject:picklistItem];
            
        }
        return picklist;
    } else {
        NSString *fixedField = [self fixCode:field entity:entity];
        NSArray *allowedValues = [CascadingPicklistManager readAllowedValues:field item:item];
       
        NSArray *dbPicklist = [PicklistManager read:entity field:fixedField languageCode:languageCode filterText:filterText];
        if ([dbPicklist count] == 0) {
            dbPicklist = [PicklistManager read:entity field:[fixedField stringByReplacingOccurrencesOfString:entity withString:@""] languageCode:languageCode filterText:filterText];
        }
        for (NSMutableDictionary *tmp in dbPicklist) {
            if (allowedValues == nil) {
                [picklist addObject:tmp];
            } else {
                // filter values when cascading picklist
                for (NSString *casc in allowedValues) {
                    // in crazy bugged oracle, the cascading picklists refer to display value, not code
                    if ([casc isEqualToString:[tmp objectForKey:@"Value"]]) {
                        [picklist addObject:tmp];
                        break;
                    }
                }
            }
        }
        [dbPicklist release];
        return picklist;
    }
}


+ (NSArray *)getPicklist:(NSString *)entity field:(NSString *)field item:(Item *)item {
    return [self getPicklist:entity field:field item:item filterText:nil];
}


// this method fixes the many picklist codes that are bugged in Oracle CRM...
+ (NSString *)fixCode:(NSString *)codeToFix entity:(NSString *)entity {
    if ([codeToFix isEqualToString:@"ActivitySubType"] && [entity isEqualToString:@"Activity"]) {
        return @"CODActivitySubType";
    }
    if ([codeToFix isEqualToString:@"PrimaryShipToCountry"]) {
        return @"PrimaryBillToCountry";
    }
    if ([codeToFix isEqualToString:@"MrMrs"]) {
        return @"M/M";
    }
    if ([codeToFix isEqualToString:@"Gender"]) {
        return @"M/F";
    }
    if ([entity isEqualToString:@"Lead"]) {
        if ([codeToFix isEqualToString:@"Rating"]) {
            return @"LeadRating";
        }
        if ([codeToFix isEqualToString:@"Source"]) {
            return @"LeadSource";
        }
    }
    if ([entity isEqualToString:@"Contact"]) {
        if ([codeToFix isEqualToString:@"PrimaryGoal"]) {
            return @"PrimaryFinancialGoals";
        }
        if ([codeToFix isEqualToString:@"BuyingRole"]) {
            return @"Role";
        }
    }
    if ([entity isEqualToString:@"Account"]) {
        if ([codeToFix isEqualToString:@"Status"]) {
            return @"AccountStatus";
        }
        if ([codeToFix isEqualToString:@"MarketSegment"]) {
            return @"PrimaryMarket";
        }
    }
    if ([entity isEqualToString:@"Opportunity"]) {
        if ([codeToFix isEqualToString:@"Probability"]) {
            return @"PrimaryRevenueWinProbability";
        }
        if ([codeToFix isEqualToString:@"OpportunityType"]) {
            return @"SalesType";
        }
    }
    
    if ([entity isEqualToString:@"ServiceRequest"] && [codeToFix isEqualToString:@"Type"]) {
        return @"SRType";
    }
    if ([entity isEqualToString:@"Asset"]) {
        if ([codeToFix isEqualToString:@"Contract"]) {
            return @"ContractType";
        }
        if ([codeToFix isEqualToString:@"Warranty"]) {
            return @"WarrantyInterval";
        }
        if ([codeToFix isEqualToString:@"Type"]) {
            return @"AutoType";
        }
        if ([codeToFix isEqualToString:@"AssetType"]) {
            return @"AutoType";
        }
        
    }
    
    if ([entity isEqualToString:@"Product"]) {
        if ([codeToFix isEqualToString:@"Status"]) {
            return @"VersionStatus";
        }
    }
    
    if ([entity isEqualToString:@"AccountRelationship"]) {
        if ([codeToFix isEqualToString:@"RelationshipRole"] || [codeToFix isEqualToString:@"ReverseRelationshipRole"]) {
            return @"Role";
        }
    }
    
    if ([codeToFix rangeOfString:@"CustomPickList"].location == 0) {
        NSString *tmp = [codeToFix substringFromIndex:14];
        if ([tmp length] == 1) {
            return [NSString stringWithFormat:@"PICK_00%@", tmp];
        } else {
            return [NSString stringWithFormat:@"PICK_0%@", tmp];
        }
    }
    
    if ([codeToFix rangeOfString:@"CustomMultiSelectPickList"].location == 0) {
        NSString *tmp = [codeToFix substringFromIndex:25];
        if ([tmp length] == 1) {
            return [NSString stringWithFormat:@"MSPICK_00%@", tmp];
        } else {
            return [NSString stringWithFormat:@"MSPICK_0%@", tmp];
        }
    }
    
    return codeToFix;
}


@end
