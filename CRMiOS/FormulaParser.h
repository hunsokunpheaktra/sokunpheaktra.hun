//
//  FormulaParser.h
//  CRMiOS
//
//  Created by Arnaud on 1/14/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Formula.h"
#import "Constant.h"
#import "Function.h"

@interface FormulaParser : NSObject

+ (NSObject<Formula> *)parse:(NSString *)s;
+ (NSString *)hideParams:(NSString *)s;
+ (NSArray *)split:(NSString *)s with:(NSString *)chars;

@end
