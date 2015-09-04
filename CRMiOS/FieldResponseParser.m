//
//  FieldResponseParser.m
//  CRMiOS
//
//  Created by Sy Pauv on 5/11/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "FieldResponseParser.h"

@implementation FieldResponseParser

@synthesize currentField;
@synthesize entity;

- (id)initWithEntity:(NSString *)newEntity {
    self = [super init];
    self.entity = newEntity;
    self.currentField = [[NSMutableDictionary alloc]initWithCapacity:1];
    [FieldsManager purge:self.entity];
    return self;
}

- (void)handleTag:(NSString *)tag value:(NSString *)value level:(int)level {
    if ([currentField objectForKey:@"ObjectName"]==nil) {
        [currentField setValue:self.entity forKey:@"ObjectName"];
    }
    
    
    if(level == 6 && ([tag isEqualToString:@"DisplayName"] || [tag isEqualToString:@"ElementName"] || [tag isEqualToString:@"DataType"])) {
        // Fix the Oracle CRM bugs
        if ([entity isEqualToString:@"Asset"] && [tag isEqualToString:@"ElementName"]) {
            if ([value isEqualToString:@"OwnerAccountId"]) {
                value = @"AccountId";
            }
        }
        [currentField setObject:value forKey:tag];
        if ([tag isEqualToString:@"DataType"]) {
            // Fix some Oracle CRM bugs
            if ([[currentField valueForKey:@"ElementName"] isEqualToString:@"Probability"]) {
                [currentField setObject:@"Picklist" forKey:@"DataType"];
            }
            [self oneMoreItem];
            [FieldsManager insert:currentField];
            [currentField removeAllObjects];
                
        }
    }
}

- (void)dealloc {
    [self.currentField release];
    [super dealloc];
}

@end
