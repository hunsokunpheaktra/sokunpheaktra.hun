//
//  SalesStageResponseParser.h
//  CRMiOS
//
//  Created by Sy Pauv on 5/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseParser.h"
#import "SalesStageManager.h"
#import "SalesProcessManager.h"


@interface SalesStageResponseParser : ResponseParser {
    NSMutableDictionary *currentSalesStage;
    NSMutableDictionary *currentSalesProcess;
}

@property (nonatomic,retain) NSMutableDictionary *currentSalesStage;
@property (nonatomic,retain) NSMutableDictionary *currentSalesProcess;

- (id)init;

@end
