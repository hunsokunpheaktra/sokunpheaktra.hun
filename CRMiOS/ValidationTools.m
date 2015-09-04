//
//  ValidationController.m
//  CRMiOS
//
//  Created by Sy Pauv on 6/1/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "ValidationTools.h"


@implementation ValidationTools


+ (void)setCalculated:(Item *)item {
    
    NSObject <EntityInfo> *info = [Configuration getInfo:item.entity];
    
    // sets the primary group
    if ([item.entity isEqualToString:@"Account"] && [info.fields indexOfObject:@"PrimaryGroup"] != NSNotFound) {
        NSString *ownerId = [item.fields objectForKey:@"OwnerId"];
        Item *user = [EntityManager find:@"User" column:@"Id" value:ownerId];
        if (user != nil) {
            NSString *primaryGroup = [user.fields objectForKey:@"PrimaryGroup"];
            if (primaryGroup != nil) {
                [item.fields setObject:primaryGroup forKey:@"PrimaryGroup"];
            }
        }
        
    }
    
    // compute opportunities expected revenue
    if ([item.entity isEqualToString:@"Opportunity"]
            && [info.fields indexOfObject:@"Probability"] != NSNotFound
            && [info.fields indexOfObject:@"Revenue"] != NSNotFound
            && [info.fields indexOfObject:@"ExpectedRevenue"] != NSNotFound
        ) {
        NSString *probability = [item.fields objectForKey:@"Probability"];
        NSString *revenue = [item.fields objectForKey:@"Revenue"];
        if (probability.length > 0 && revenue.length > 0) {
            NSString *expected = [NSString stringWithFormat:@"%d", [probability intValue] * [revenue intValue] / 100];
            [item.fields setObject:expected forKey:@"ExpectedRevenue"];
        }
    }
    
    // sets sales stage id
    if ([item.entity isEqualToString:@"Opportunity"]
        && [info.fields indexOfObject:@"SalesStage"] != NSNotFound
        && [info.fields indexOfObject:@"SalesStageId"] != NSNotFound
        ) {
        NSArray *stages = [SalesStageManager read:[item.fields objectForKey:@"OpportunityType"]];
        for (NSDictionary *stage in stages) {
            if ([[stage objectForKey:@"Name"] isEqualToString:[item.fields objectForKey:@"SalesStage"]]) {
                [item.fields setObject:[stage objectForKey:@"Id"] forKey:@"SalesStageId"];
                break;
            }
        }
    }
    
    // compute fields with formula that are readonly
    NSArray *formulas = [FieldMgmtManager list:item.entity];
    NSObject<Subtype> *sinfo = [Configuration getSubtypeInfo:[Configuration getSubtype:item] entity:item.entity];
    for (NSDictionary *dict in formulas) {
        NSString *field = [dict objectForKey:@"GenericIntegrationTag"];
        if ([sinfo isReadonly:field] && [info.fields containsObject:field]) {
            NSString *expr = [dict objectForKey:@"DefaultValue"];
            if ([expr length] > 0) {
                NSObject<Formula> *formula = [FormulaParser parse:expr];
                NSString *value = [formula evaluateWithItem:item];
                if (value != nil) {
                    [item.fields setObject:value forKey:field];
                }
            }
        }
    }
    
    // Compute fields that are relation-based, e.g. ContactFirstName, ContactLastName, ContactFullName
    for (Relation *relation in [Relation getEntityRelations:item.entity]) {
        if ([relation.srcEntity isEqualToString:item.entity]) {
            Item *otherItem = [RelationManager getRelatedItem:item.entity field:relation.srcKey value:[item.fields objectForKey:relation.srcKey]];
            for (int i = 0; i < [relation.srcFields count]; i++) {
                NSString *srcField = [relation.srcFields objectAtIndex:i];
                NSString *destField = [relation.destFields objectAtIndex:i];
                NSString *value = [otherItem.fields objectForKey:destField];
                if (value == nil) value = @"";
                [item.fields setObject:value forKey:srcField];
            }
        }
    }
    
}

+ (BOOL)check:(Item *)item {
    NSMutableArray *errors = [[NSMutableArray alloc] initWithCapacity:1];
    NSObject <EntityInfo> *info = [Configuration getInfo:item.entity];
    NSString *subtype = [Configuration getSubtype:item];
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:subtype];
    NSMutableArray *missingFields = [[NSMutableArray alloc] initWithCapacity:1];
    for (NSString *code in [info fields]) {
        if ([sinfo isMandatory:code]) {
            CRMField *field = [FieldsManager read:item.entity field:code];
            NSString *value = [item.fields objectForKey:field.code];
            NSString *trimmedValue = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (value == nil || [trimmedValue isEqualToString:@""]) {
                [missingFields addObject:field.displayName];
            }
        }
    }
    
    if ([missingFields count] > 0) {
        if ([missingFields count] > 1) {
            [errors addObject:[NSString stringWithFormat:NSLocalizedString(@"MANDATORY_FIELDS", @"mandatory"), [missingFields componentsJoinedByString:@", "]]];
        } else {
            [errors addObject:[NSString stringWithFormat:NSLocalizedString(@"MANDATORY_FIELD", @"mandatory"), [missingFields objectAtIndex:0]]];
        }
    }
    
    // TODO this is false, we must handle all the pages and sections
    NSArray *listField = [LayoutFieldManager read:subtype page:0 section:0];
    if ([listField containsObject:@"EndDate"]) {
        if (![self dateTimeCheck:[item.fields objectForKey:@"StartDate"] end:[item.fields objectForKey:@"EndDate"]]) {
            [errors addObject:NSLocalizedString(@"TIME_UPDATE_ERROR", @"endtime must greater than starttime")]; 
        }
    } else if ([listField containsObject:@"EndTime"]) {
        if (![self dateTimeCheck:[item.fields objectForKey:@"StartTime"] end:[item.fields objectForKey:@"EndTime"]]) {
            [errors addObject:NSLocalizedString(@"TIME_UPDATE_ERROR", @"endtime must greater than starttime")]; 
        }
    }
    
    // Handle error with saving existing accountName and location
    if ([item.entity isEqualToString:@"Account"]) {
        NSMutableArray *criterias = [NSMutableArray arrayWithObjects:
                [ValuesCriteria criteriaWithColumn:@"AccountName" value:[item.fields valueForKey:@"AccountName"]],
                [ValuesCriteria criteriaWithColumn:@"Location" value:[item.fields valueForKey:@"Location"]], nil];
        if ([item.fields objectForKey:@"gadget_id"]!=nil) {
            NotInCriteria *notin = [[NotInCriteria alloc] initWithColumn:@"gadget_id" values:[NSArray arrayWithObject:[item.fields objectForKey:@"gadget_id"]]];
            [criterias addObject:notin];
        }
        Item *checkedAcc = [EntityManager find:item.entity criterias:criterias];    
        if (checkedAcc != nil) {
            [errors addObject:NSLocalizedString(@"An account with the same name and location already exists!", @"")];
        }
    }
    
    if ([Configuration isYes:@"ZurichCheckNIF"]) {
        NSString *nif = [item.fields objectForKey:@"IndexedShortText1"];
        if (nif != nil) {
            BOOL correct = (nif.length == 9);
            BOOL missLetter = YES;
            for (int i = 0; i < nif.length; i++) {
                unichar car = [nif characterAtIndex:i];
                if (car >= 'A' && car <= 'Z') {
                    missLetter = NO;
                }
                if ((car < 'A' || car > 'Z') && (car < '0' || car > '9')) {
                    correct = NO;
                    break;
                }
            }
            if (!correct || missLetter) {
                [errors addObject:NSLocalizedString(@"WRONG_NIF", @"Wrong NIF")];
            }
            NSMutableArray *criterias = [[NSMutableArray alloc] initWithCapacity:1];
            [criterias addObject:[ValuesCriteria criteriaWithColumn:@"IndexedShortText1" value:nif]];
            if ([item.fields objectForKey:@"gadget_id"] != nil) {
                [criterias addObject:[[NotInCriteria alloc] initWithColumn:@"gadget_id" values:[NSArray arrayWithObject:[item.fields objectForKey:@"gadget_id"]]]];
            }
            Item *other = [EntityManager find:@"Contact" criterias:criterias];
            if (other != nil) {
                [errors addObject:NSLocalizedString(@"DUPLICATE_NIF", @"Duplicate NIF")];
            }
        }
    }

    if ([errors count] > 0) {
        [ValidationTools showAlert:[errors objectAtIndex:0]];
    }
    return [errors count] == 0;

}

+ (BOOL)validateSubItem:(SublistItem *)item parent:(Item *)parentItem {
    if (![item updatable]) {
        // for non-updatable sublists, check unicity of ID
        NSArray *criterias = [NSArray arrayWithObjects:[ValuesCriteria criteriaWithColumn:item.unicityKey value:[item.fields objectForKey:item.unicityKey]], [ValuesCriteria criteriaWithColumn:@"parent_oid" value:[parentItem.fields objectForKey:@"Id"]], nil];
        SublistItem *existing = [SublistManager find:item.entity sublist:item.sublist criterias:criterias];
        if (existing != nil) {
            [ValidationTools showAlert:NSLocalizedString(@"ALREADY_ADDED", @"Already added")];
            return NO;
        }
    }
    return YES;
}

+ (void)showAlert:(NSString *)errorMessage {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CANNOT_UPDATE", @"cannot update") message:errorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

+ (BOOL)dateTimeCheck:(NSString *)startTime end:(NSString *)endTime {

    NSDate *startDate = [EvaluateTools dateFromString:startTime];
    NSDate *endDate = [EvaluateTools dateFromString:endTime];
    
    return ([startDate compare:endDate] == NSOrderedAscending)|([startDate compare:endDate] == NSOrderedSame);
}

+ (BOOL)checkCredentials {
    NSString *error = nil;
    if ([PropertyManager read:@"Login"].length == 0) {
        error = @"EMPTY_LOGIN";
    } else if ([PropertyManager read:@"Password"].length == 0) {
        error = @"EMPTY_PASSWORD";
    } else if ([PropertyManager read:@"URL"].length != 40) {
        error = @"BAD_URL";
    } else {
        NSString *urlCode = [[PropertyManager read:@"URL"] substringWithRange:NSMakeRange(15, 9)];
        NSString *trimmedUrl = [urlCode stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]];
        if (trimmedUrl.length != 0) {
            error = @"BAD_URL";
        }
    }
    if (error != nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SYNCHRONIZE", nil) message:NSLocalizedString(error, nil) delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    return error == nil;
}


@end
