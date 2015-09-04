//
//  EvaluateTools.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 8/1/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"
#import "CurrentUserManager.h"

@interface EvaluateTools : NSObject {
    
}

+ (NSDate *)getTodayGMT;
+ (NSString *)evaluate:(NSString *)formula item:(Item *)item;
+ (NSString *)evaluate:(NSString *)formula item:(Item *)item shortFormat:(BOOL)shortFormat;
+ (NSDate *)dateFromString:(NSString *)s;
+ (NSString *)translateWithPrefix:(NSString *)str prefix:(NSString *)prefix;
+ (NSArray *)getFieldsFromFormula:(NSString *)formula;
+ (NSString *)formatDisplayField:(NSString *)field;
+ (NSString *)removeIdSuffix:(NSString *)name;
+ (NSDateFormatter *)getDateParser;
+ (void)initAppointment:(Item *)appointment date:(NSDate *)date;

@end
