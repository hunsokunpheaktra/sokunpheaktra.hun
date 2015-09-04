//
//  DeletedItemsResponseParser.m
//  CRMiOS
//
//  Created by Sy Pauv on 7/13/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "DeletedItemsResponseParser.h"


@implementation DeletedItemsResponseParser
@synthesize currentItem;

-(id)init {
    self.currentItem=[[NSMutableDictionary alloc]initWithCapacity:1];
    return [super init];
    
}

- (void)handleTag:(NSString *)tag value:(NSString *)value level:(int)level {
    if ([tag isEqualToString:@"LastPage"] && [value isEqualToString:@"false"]) {
        self.lastPage = [NSNumber numberWithBool:NO];
    }
    if (level==6 && ([tag isEqualToString:@"Name"]||[tag isEqualToString:@"ObjectId"]||[tag isEqualToString:@"ExternalSystemId"]||[tag isEqualToString:@"Type"])) {
        if ([value isEqualToString:@"Action***Appointment"] || [value isEqualToString:@"Action***Task"]) {
            value = @"Activity";
        }
        if ([value isEqualToString:@"Service Request"]) {
            value = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
        [currentItem setObject:value forKey:tag];
        if ([tag isEqualToString:@"ExternalSystemId"]) {
            [[Database getInstance] remove:[currentItem objectForKey:@"Type"] column:@"Id" value:[currentItem objectForKey:@"ObjectId"]];
            NSLog(@"OD Delete Item %@",[currentItem objectForKey:@"ObjectId"]);
            [self oneMoreItem];
        }
    
    }
    
}


@end
