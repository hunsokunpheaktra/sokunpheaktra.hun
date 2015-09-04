//
//  SalesStageResponseParser.m
//  CRMiOS
//
//  Created by Sy Pauv on 5/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "SalesStageResponseParser.h"


@implementation SalesStageResponseParser

@synthesize currentSalesStage;
@synthesize currentSalesProcess;

- (id)init {

    self = [super init];
    currentSalesStage = [[NSMutableDictionary alloc] initWithCapacity:1];
    currentSalesProcess = [[NSMutableDictionary alloc] initWithCapacity:1];
    [SalesStageManager purge];
    [SalesProcessManager purge];
    return self;
    
}

- (void)handleTag:(NSString *)tag value:(NSString *)value level:(int)level {
    
    if ([tag isEqualToString:@"Order"]) {
        tag = @"Order1";
    }

    if (level == 6 && [tag isEqualToString:@"Default"]) {
        [currentSalesStage setObject:value forKey:@"Default1"];
    }
    //save salesprocessid
    if (level == 6 && [tag isEqualToString:@"Id"]) {
        [currentSalesStage setObject:value forKey:@"SalesProcessId"];
        [currentSalesProcess setObject:value forKey:@"Id"];
    }
    
    // Default
    if (level == 8 && ([tag isEqualToString:@"Id"] || [tag isEqualToString:@"Name"] || [tag isEqualToString:@"SalesCategoryName"] || [tag isEqualToString:@"Order1"] || [tag isEqualToString:@"Probability"])) {
        
        [currentSalesStage setObject:value forKey:tag];
        if (level == 8 && [tag isEqualToString:@"Probability"]) {
            [self oneMoreItem];
            [SalesStageManager insert:currentSalesStage];
        }
    }
    if (level == 8 && ([tag isEqualToString:@"Type"])) {
        [currentSalesProcess setObject:value forKey:@"OpportunityType"];
        [SalesProcessManager insert:currentSalesProcess];
    }
}

@end
