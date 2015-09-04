//
//  Function.m
//  CRMiOS
//
//  Created by Arnaud on 1/14/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import "Function.h"

@implementation Function

@synthesize name;
@synthesize parameters;

- (id)initWithName:(NSString *)pName {
    self = [super init];
    self.name = pName;
    self.parameters = [[NSMutableArray alloc] initWithCapacity:1];
    return self;
}

- (id)initWithName:(NSString *)pName param:(NSObject<Formula> *)parameter {
    self = [super init];
    self.name = pName;
    self.parameters = [NSMutableArray arrayWithObject:parameter];
    return self;
}

- (NSString *)evaluateWithItem:(Item *)item {
    if ([name isEqualToString:@"FIELD"]) {
        NSObject<Formula> *parameter = [self.parameters objectAtIndex:0];
        NSString *fieldName = [parameter evaluateWithItem:item];
        if ([fieldName hasSuffix:@"_ITAG"]) {
            // handle fields such as
            NSString *displayName = [fieldName substringWithRange:NSMakeRange(2, fieldName.length - 7)];
            displayName = [displayName stringByReplacingOccurrencesOfString:@"_" withString:@" "];
            CRMField *field = [FieldsManager read:item.entity display:displayName];
            fieldName = field.code;
        }
        return [item.fields objectForKey:fieldName];
    } else if ([name isEqualToString:@"CONCAT"]) {
        NSMutableString *tmp = [[NSMutableString alloc] initWithCapacity:1];
        for (NSObject<Formula> *parameter in self.parameters) {
            NSString *paramValue = [parameter evaluateWithItem:item];
            if (paramValue != nil) {
                [tmp appendString:paramValue];
            }
        }
        return tmp;
    } else if ([name isEqualToString:@"IS NULL"]) {
        NSObject<Formula> *parameter = [self.parameters objectAtIndex:0];
        if ([parameter evaluateWithItem:item] == nil) {
            return @"true";
        } else {
            return @"false";
        }
    } else if ([name isEqualToString:@"IIf"]) {
        NSObject<Formula> *parameter0 = [self.parameters objectAtIndex:0];
        NSObject<Formula> *parameter1 = [self.parameters objectAtIndex:1];
        NSObject<Formula> *parameter2 = [self.parameters objectAtIndex:2];
        if ([[parameter0 evaluateWithItem:item] isEqualToString:@"true"]) {
            return [parameter1 evaluateWithItem:item];
        } else {
            return [parameter2 evaluateWithItem:item];
        }
    } else if ([name isEqualToString:@"JoinFieldValue"]) {
        // JoinFieldValue('<Account>',[<AccountId>],'<AccountName>')
        NSObject<Formula> *parameter0 = [self.parameters objectAtIndex:0];
        NSObject<Formula> *parameter1 = [self.parameters objectAtIndex:1];
        NSObject<Formula> *parameter2 = [self.parameters objectAtIndex:2];
        Item *related = [EntityManager find:[parameter0 evaluateWithItem:item] column:@"Id" value:[parameter1 evaluateWithItem:item]];
        if (related == nil) return nil;
        return [related.fields objectForKey:[parameter2 evaluateWithItem:item]];
    } else if ([name isEqualToString:@"LookupValue"]) {
        NSObject<Formula> *parameter0 = [self.parameters objectAtIndex:0];
        NSObject<Formula> *parameter1 = [self.parameters objectAtIndex:1];
        return [PicklistManager getPicklistDisplay:item.entity field:[parameter0 evaluateWithItem:item] value:[parameter1 evaluateWithItem:item]];
    } else if ([name isEqualToString:@"ToChar"]) {
        // todo : format the date with second parameter
        NSObject<Formula> *parameter = [self.parameters objectAtIndex:0];
        return [parameter evaluateWithItem:item];
    }
    return @"";
}



@end
