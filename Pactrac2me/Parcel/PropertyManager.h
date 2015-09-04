//
//  PropertyManager.h
//  Pactrac2me
//
//  Created by Hun Sokunpheaktra on 4/8/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@interface PropertyManager : NSObject

+ (void)initTable;
+ (void)initDatas;
+ (void)save:(NSString *)property value:(NSString *)value;
+ (NSString *)read:(NSString *)property;

@end
