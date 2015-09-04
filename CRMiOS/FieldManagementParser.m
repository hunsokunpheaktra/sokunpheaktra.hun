//
//  FieldManagementParser.m
//  CRMiOS
//
//  Created by Arnaud on 1/11/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import "FieldManagementParser.h"

@implementation FieldManagementParser

@synthesize currentField;

- (id)init {
    self = [super init];
    self.currentField = [[NSMutableDictionary alloc]initWithCapacity:1];
    [FieldMgmtManager purge];
    return self;
}

- (void)handleTag:(NSString *)tag value:(NSString *)value level:(int)level {
    if ([tag isEqualToString:@"GenericIntegrationTag"] || [tag isEqualToString:@"DefaultValue"] || [tag isEqualToString:@"ObjectName"]) {
        [currentField setValue:value forKey:tag];
        if ([tag isEqualToString:@"DefaultValue"]) {
            [FieldMgmtManager insert:currentField];
            [self oneMoreItem];
        }
    }
}

- (void)dealloc {
    [self.currentField release];
    [super dealloc];
}

@end
