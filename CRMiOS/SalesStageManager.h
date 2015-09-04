//
//  SalesStageManager.h
//  CRMiOS
//
//  Created by Sy Pauv on 5/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Database.h"

@interface SalesStageManager : NSObject {
    
}
+ (void)initTable;
+ (void)initData;
+ (void)insert:(NSDictionary *)newSalesStage;
+ (void)purge;
+ (NSArray *)read:(NSString *)type;

@end
