//
//  CompanyResponseParser.m
//  CRMiOS
//
//  Created by Arnaud Marguerat on 8/30/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "CompanyResponseParser.h"

@implementation CompanyResponseParser


- (id)init {
    return [super init];
}

- (void)handleTag:(NSString *)tag value:(NSString *)value level:(int)level {
    
    if (level==5 && [tag isEqualToString:@"DefaultLanguage"]) {
        // clever Oracle does not give us the language code, but the name
        // so we need to convert it manually
        NSString *code = @"ENU";
        if ([value isEqualToString:@"English-British"]) {
            code = @"ENG";
        }
        if ([value isEqualToString:@"German"]) {
            code = @"DEU";
        }
        if ([value isEqualToString:@"French"]) {
            code = @"FRA";
        }
        if ([value isEqualToString:@"Italian"]) {
            code = @"ITA";
        }
        if ([value isEqualToString:@"Spanish"]) {
            code = @"ESN";
        }
        if ([value isEqualToString:@"Dutch"]) {
            code = @"NLD";
        }
        [PropertyManager save:@"DefaultLanguage" value:code];
        [self oneMoreItem];
        
    }
    
    if (level == 5 && [tag isEqualToString:@"DefaultCurrency"]) {
        [PropertyManager save:@"DefaultCurrency" value:value];
    }
    
}
@end
