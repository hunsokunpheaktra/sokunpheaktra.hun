//
//  CascadingPicklistParser.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 7/30/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "CascadingPicklistParser.h"

@implementation CascadingPicklistParser
@synthesize cascadingValue;

- (id)init {
    self = [super init];
    self.cascadingValue = [[NSMutableDictionary alloc]initWithCapacity:1];
    [CascadingPicklistManager purge];
    return self;
}

- (void)handleTag:(NSString *)tag value:(NSString *)value level:(int)level {    
    
    if ([tag isEqualToString:@"ObjectName"] && level == 6) {
        [self.cascadingValue setObject:[value stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"ObjectName"];
    }
    if ([tag isEqualToString:@"ParentPicklist"] && level==8) {
        [self.cascadingValue setObject:[value stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"ParentPicklist"];
    }
    if ([tag isEqualToString:@"RelatedPicklist"] && level==8) {
        [self.cascadingValue setObject:[value stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"RelatedPicklist"];
    }
    if ([tag isEqualToString:@"ParentPicklistValue"] && level==10) {
        [self.cascadingValue setObject:value forKey:@"ParentValue"];
    }
    //save cascading value here
    if ([tag isEqualToString:@"RelatedPicklistValue"] && level==10 && value !=nil) {
        [self oneMoreItem];
        [self.cascadingValue setObject:value forKey:@"RelatedValue"];
        [CascadingPicklistManager insert:self.cascadingValue];
    }
}

@end
