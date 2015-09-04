//
//  IndustryManager.h
//  CRMiOS
//
//  Created by Sy Pauv on 5/27/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Database.h"
#import "LikeCriteria.h"

@interface IndustryManager : NSObject {
    
}

+ (void)initTable;
+ (void)initData;
+ (void)purge;
+ (void)insert:(NSDictionary *)currency;
+ (NSArray *)read:(NSString *)languageCode filter:(NSString *)filter;

@end
