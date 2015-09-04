//
//  PicklistResponseParser.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/9/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "PicklistResponseParser.h"


@implementation PicklistResponseParser

@synthesize picklistValue;

- (id)init {
    self = [super init];
    self.picklistValue = [[NSMutableDictionary alloc] initWithCapacity:1];
    return self;
}

- (void)handleTag:(NSString *)tag value:(NSString *)value level:(int)level {
    if (level == 6 && [tag isEqualToString:@"ObjectName"]) {
        [picklistValue setObject:[value stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"ObjectName"];
    }
    if (level == 8 && [tag isEqualToString:@"Name"]) {
        [picklistValue setObject:[value stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"Name"];
        [PicklistManager purge:[picklistValue objectForKey:@"Name"] entity:[picklistValue objectForKey:@"ObjectName"]];
    }
    if (level == 10 && ([tag isEqualToString:@"ValueId"] || [tag isEqualToString:@"Disabled"])) {
        [picklistValue setObject:value forKey:tag];
    }
    if (level == 12 && ([tag isEqualToString:@"LanguageCode"] || [tag isEqualToString:@"Value"] || [tag isEqualToString:@"Order"])) {
        if ([tag isEqualToString:@"Order"]) {
            tag = @"Order1";
        }
        [picklistValue setObject:value forKey:tag];
    }
    if (level == 11 && [tag isEqualToString:@"ValueTranslation"]) {
        // save data only for english
        [self oneMoreItem];
        [PicklistManager insert:self.picklistValue];
    }

}

@end
