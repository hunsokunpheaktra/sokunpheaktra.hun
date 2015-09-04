//
//  CurrencyCodeParser.m
//  CRMiOS
//
//  Created by Sy Pauv on 7/1/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "CurrencyCodeParser.h"


@implementation CurrencyCodeParser

@synthesize currency;

- (id)init {
    currency = [[NSMutableDictionary alloc]initWithCapacity:1];
    return [super init];
}

- (void)handleTag:(NSString *)tag value:(NSString *)value level:(int)level {
    
    if (level == 6 && (
        [tag isEqualToString:@"Name"]
            || [tag isEqualToString:@"Code"]
            || [tag isEqualToString:@"Symbol"]
            || [tag isEqualToString:@"IssuingCountry"]
            || [tag isEqualToString:@"Active"]
        )) {
        [currency setObject:value forKey:tag];
    }
    if (level == 5 && [tag isEqualToString:@"Currency"]) {
        [self oneMoreItem];
        if ([currency objectForKey:@"Code"] != nil && ![CurrencyManager exists:self.currency]) {
            [CurrencyManager insert:self.currency];
        }
    }
       
}

@end
