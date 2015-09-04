//
//  ConfigSubtype.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 8/2/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "ConfigSubtype.h"


@implementation ConfigSubtype

@synthesize name;
@synthesize entity;
@synthesize detailLayout;
@synthesize iconName;
@synthesize orderField, displayText, secondaryText, groupBy, mandatoryFields;
@synthesize iconField, listIcons, actions;
@synthesize filterField, filters;
@synthesize criterias;
@synthesize sublists;
@synthesize customNames, readonly;
@synthesize pdfLayout;
@synthesize disabledRelations;

- (id)initWithEntity:(NSString *)newEntity {
    self = [super init];
    self.entity = newEntity;
    self.name = newEntity;
    self.pdfLayout = [[Page alloc] initWithName:@"pdf"];
    self.detailLayout = [[DetailLayout alloc] init];
    self.orderField = @"search";
    self.orderAscending = YES;
    self.groupBy = @"";
    self.mandatoryFields = [[NSMutableArray alloc] initWithCapacity:1];
    self.listIcons = [[NSMutableDictionary alloc] initWithCapacity:1];
    self.actions = [[NSMutableArray alloc] initWithCapacity:1];
    self.filters = [[NSMutableArray alloc] initWithCapacity:1];
    self.iconName = @"157-wrench.png"; // default icon
    self.criterias = [[NSMutableArray alloc] initWithCapacity:1];
    self.sublists = [[NSMutableArray alloc] initWithCapacity:1];
    self.customNames = [[NSMutableDictionary alloc] initWithCapacity:1];
    self.readonly = [[NSMutableArray alloc] initWithCapacity:1];
    self.canCreate = YES;
    self.disabledRelations = [[NSMutableArray alloc] initWithCapacity:1];
    return self;
}

- (void) dealloc
{
    [self.mandatoryFields release];
    [self.customNames release];
    [self.readonly release];
    [super dealloc];
}


- (NSArray *)listFields {
    NSMutableArray *listFields = [[NSMutableArray alloc] initWithCapacity:1];
    [listFields addObject:@"Id"];
    if (self.iconField != nil) {
        [listFields addObject:self.iconField];
    }
    for (NSObject <Criteria> *criteria in self.criterias) {
        [listFields addObject:[criteria column]];
    }
    [listFields addObjectsFromArray:[EvaluateTools getFieldsFromFormula:self.displayText]];
    [listFields addObjectsFromArray:[EvaluateTools getFieldsFromFormula:self.secondaryText]];
    [listFields addObjectsFromArray:[EvaluateTools getFieldsFromFormula:self.groupBy]];
    NSObject <EntityInfo> *einfo = [Configuration getInfo:self.entity];
    for (ConfigSubtype *otherSubtype in [einfo getSubtypes]) {
        for (NSObject <Criteria> *criteria in otherSubtype.criterias) {
            if ([listFields indexOfObject:[criteria column]] == NSNotFound) {
                [listFields addObject:[criteria column]];
            }
        }
    }
    return listFields;
}

- (NSString *)getDisplayText:(Item *)item {
    return [EvaluateTools evaluate:self.displayText item:item];
}

- (NSString *)getDetailText:(Item *)item {
    return [EvaluateTools evaluate:self.secondaryText item:item];
}


- (NSObject<Sublist> *)getSublist:(NSString *)sublist {
    for (ConfigSublist *config in [self sublists]) {
        if ([config.name isEqualToString:sublist]) {
            return config;
        }
    }
    return nil;
}

- (NSString *)getGroupName:(Item *)item {
    // contact : ignore the settings in XML and use preferences
    if ([item.entity isEqualToString:@"Contact"]) {
        if ([[PropertyManager read:@"SortingContact"] isEqualToString:@"FirstName"]) {
            return [EvaluateTools evaluate:@"{FIRST:ContactFirstName}" item:item];
        } else {
            return [EvaluateTools evaluate:@"{FIRST:ContactLastName}" item:item];
        }
    }
    return [EvaluateTools evaluate:self.groupBy item:item];
}

- (NSString *)getGroupShortName:(Item *)item {
    return [EvaluateTools evaluate:self.groupBy item:item shortFormat:YES];
}


- (BOOL)isReadonly:(NSString *)field {
    if ([field isEqualToString:@"PrimaryGroup"] && [self.entity isEqualToString:@"Account"]) {
        return YES;
    }
    if ([field isEqualToString:@"ExpectedRevenue"] && [self.entity isEqualToString:@"Opportunity"]) {
        return YES;
    }
    return [self.readonly containsObject:field];
}

- (BOOL)isMandatory:(NSString *)field {
    for (Relation *relation in [Relation getEntityRelations:self.entity]) {
        if ([relation.srcKey isEqualToString:field]) {
            for (NSString *srcField in relation.srcFields) {
                if ([self.mandatoryFields containsObject:srcField]) {
                    return true;
                }
            }
        }
    }
    return [self.mandatoryFields containsObject:field];
}


- (NSString *)getIcon:(Item *)item {
    if (self.iconField == nil) return nil;
    NSString *value = [item.fields objectForKey:self.iconField];
    return [self.listIcons objectForKey:value];
}

- (NSArray *)getFilters:(BOOL)isIphone {
    NSMutableArray *tmp = [[NSMutableArray alloc] initWithCapacity:1];
    for (ConfigFilter *filter in self.filters) {
        if (filter.optional == NO || !isIphone) {
            [tmp addObject:filter];
        }
    }
    return tmp;
}


- (NSString *)localizedName {
    NSString *customName = [CustomRecordTypeManager read:self.name languageCode:[CurrentUserManager getLanguageCode] plural:NO];
    if (customName != nil) {
        return customName;
    }
    NSString *singularCode = [NSString stringWithFormat:@"%@_SINGULAR", self.name];
    NSString *value = NSLocalizedString(singularCode, @"subtype name");
    if ([value hasSuffix:@"_SINGULAR"]) {
        value = [value substringToIndex:[value length] - 9];
    }
    return value;
}

- (NSString *)localizedPluralName {
    NSString *customName = [CustomRecordTypeManager read:self.name languageCode:[CurrentUserManager getLanguageCode] plural:YES];
    if (customName != nil) {
        return customName;
    }
    NSString *pluralCode = [NSString stringWithFormat:@"%@_PLURAL", self.name];
    NSString *value = NSLocalizedString(pluralCode, @"plural name");
    if ([value hasSuffix:@"_PLURAL"]) {
        value = [value substringToIndex:[value length] - 7];
    }
    return value;
}

- (NSArray *)getCriterias {
    return self.criterias;
}

- (void)fillItem:(Item *)item {
    NSObject <EntityInfo> *info = [Configuration getInfo:item.entity];
    Item *user = [CurrentUserManager getCurrentUserInfo];
    if (user != nil) {
        if ([info.fields indexOfObject:@"OwnerId"] != NSNotFound && [user.fields objectForKey:@"Id"] != nil) {
            [item.fields setValue:[user.fields objectForKey:@"Id"] forKey:@"OwnerId"];
        }
        if ([self.entity isEqualToString:@"Activity"] && [info.fields indexOfObject:@"Alias"] != NSNotFound && [user.fields objectForKey:@"Alias"] != nil) {
            [item.fields setValue:[user.fields objectForKey:@"Alias"] forKey:@"Alias"];
        }
        if ([info.fields indexOfObject:@"CurrencyCode"] != NSNotFound && [user.fields objectForKey:@"CurrencyCode"] != nil) {
            [item.fields setValue:[user.fields objectForKey:@"CurrencyCode"] forKey:@"CurrencyCode"];
        }
        if ([user.fields objectForKey:@"PersonalCountry"] != nil) {
            if ([info.fields indexOfObject:@"PrimaryBillToCountry"] != NSNotFound) {
                [item.fields setValue:[user.fields objectForKey:@"PersonalCountry"] forKey:@"PrimaryBillToCountry"];
            }
            if ([info.fields indexOfObject:@"PrimaryShipToCountry"] != NSNotFound) {
                [item.fields setValue:[user.fields objectForKey:@"PersonalCountry"] forKey:@"PrimaryShipToCountry"];
            }
            if ([info.fields indexOfObject:@"AlternateCountry"] != NSNotFound) {
                [item.fields setValue:[user.fields objectForKey:@"PersonalCountry"] forKey:@"AlternateCountry"];
            }
        }
    }

    if ([item.entity isEqualToString:@"Lead"]) {
        if ([info.fields indexOfObject:@"Qualifying"] != NSNotFound) {
            [item.fields setValue:@"Qualifying" forKey:@"Status"];
        }
    }

    for (NSObject <Criteria> *criteria in self.criterias) {
        if ([criteria isKindOfClass:[ValuesCriteria class]]) {
            [item.fields setValue:[((ValuesCriteria *) criteria).values objectAtIndex:0] forKey:[criteria column]];
        }
    }
    if ([info.fields containsObject:@"CreatedDate"] && ([item.fields objectForKey:@"CreatedDate"] == nil || [[item.fields objectForKey:@"CreatedDate"] length] == 0)) {
        NSString *value = [[EvaluateTools getDateParser] stringFromDate:[[NSDate alloc] init]];
        [item.fields setValue:value forKey:@"CreatedDate"];
    }
    
    // fields with formula
    NSArray *formulas = [FieldMgmtManager list:item.entity];
    for (NSDictionary *dict in formulas) {
        NSString *expr = [dict objectForKey:@"DefaultValue"];
        NSString *field = [dict objectForKey:@"GenericIntegrationTag"];
        if ([info.fields containsObject:field]) {
            if ([expr length] > 0) {
                NSObject<Formula> *formula = [FormulaParser parse:expr];
                NSString *value = [formula evaluateWithItem:item];
                if (value != nil) {
                    [item.fields setObject:value forKey:field];
                }
            }
        }
    }

    if ([self.name isEqualToString:@"Appointment"] || [self.name isEqualToString:@"Call"]) {
        NSDate *today = [EvaluateTools getTodayGMT];
        [EvaluateTools initAppointment:item date:today];
    }
    
    [formulas release];

}

- (NSString *)getSublistIcon:(NSString *)sublist {
    NSObject<Sublist> *config = [self getSublist:sublist];
    return config.icon;
}


- (NSString *)getOrderField {
    // contact : ignore the settings in XML and use preferences
    if ([self.entity isEqualToString:@"Contact"]) {
        if ([[PropertyManager read:@"SortingContact"] isEqualToString:@"FirstName"]) {
            return @"search2";
        } else {
            return @"search";
        }
    }
    return self->orderField;
}

- (NSString *)customName:(NSString *)field {
    return [self.customNames objectForKey:field];
}

- (BOOL)enabledRelation:(NSString *)field {
    return ![self.disabledRelations containsObject:field];
}

@end
