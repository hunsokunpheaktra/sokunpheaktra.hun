//
//  CurrencyManager.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 7/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Database.h"

@interface CurrencyManager : NSObject {
    
}

+ (void)initTable;
+ (void)initData;
+ (BOOL)exists:(NSDictionary *)currency;
+ (void)insert:(NSDictionary *)currency;
+ (NSArray *)read:(NSString *)filter;

@end
