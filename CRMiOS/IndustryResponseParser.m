//
//  IndustryResponseParser.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 7/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "IndustryResponseParser.h"


@implementation IndustryResponseParser


@synthesize industry;

- (id)init {
    self.industry = [[NSMutableDictionary alloc]initWithCapacity:1];
    [IndustryManager purge];
    return [super init];
}

- (void)handleTag:(NSString *)tag value:(NSString *)value level:(int)level {
    
    if (level == 6 && [tag isEqualToString:@"SICcode"]) {
        [industry setObject:value forKey:@"Code"];
    }
    if (level == 6 && [tag isEqualToString:@"Active"]) {
        [industry setObject:value forKey:@"Active"];
    }
    if (level == 8 && ([tag isEqualToString:@"LanguageCode"] || [tag isEqualToString:@"Title"])) {
        [industry setObject:value forKey:tag];
    }
    if (level == 7 && [tag isEqualToString:@"IndustryTranslation"]) {
        [self oneMoreItem];
        if ([[self.industry objectForKey:@"Active"] isEqualToString:@"Y"]) {
            [self.industry removeObjectForKey:@"Active"];
            [IndustryManager insert:self.industry];
        }
    }
    
}

@end
