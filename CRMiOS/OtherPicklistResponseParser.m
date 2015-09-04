//
//  OtherPicklistResponseParser.m
//  CRMiOS
//
//  Created by Sy Pauv on 6/10/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "OtherPicklistResponseParser.h"


@implementation OtherPicklistResponseParser

@synthesize picklistValue,entity,field;

- (id)initWithEntity:(NSString *)newEntity fields:(NSString *)newField;{
    self = [super init];
    self.field = newField;
    self.entity = newEntity;
    self.picklistValue = [[NSMutableDictionary alloc] initWithCapacity:1];
    [PicklistManager purge:self.field entity:self.entity];
    return self;
}

- (void)handleTag:(NSString *)tag value:(NSString *)value level:(int)level {
    
    if (level == 6 && [tag isEqualToString:@"Language"]) {
       
        if ([tag isEqualToString:@"Language"]) {
            tag = @"LanguageCode";
        }
        [picklistValue setObject:value forKey:tag];
    }
    
    if (level == 8 && ([tag isEqualToString:@"Code"] || [tag isEqualToString:@"DisplayValue"] || [tag isEqualToString:@"Disabled"])) {
      
        if ([tag isEqualToString:@"Code"]) {
            tag = @"ValueId";
        }
        if ([tag isEqualToString:@"DisplayValue"]) {
            tag = @"Value";
        }
        if ([tag isEqualToString:@"Disabled"]) {
            if ([value isEqualToString:@"N"]) {
                value = @"false";
            } else {
                value = @"true";
            }
        }
        [picklistValue setObject:value forKey:tag];
    }
    
    if (level == 8 && [tag isEqualToString:@"Disabled"]) {
        [self.picklistValue setObject:entity forKey:@"ObjectName"];
        [self.picklistValue setObject:field forKey:@"Name"];  
        [self oneMoreItem];
        
        [PicklistManager insert:self.picklistValue];
    }
    
}


@end
