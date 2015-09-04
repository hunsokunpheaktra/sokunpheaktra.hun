//
//  FormulaParser.m
//  CRMiOS
//
//  Created by Arnaud on 1/14/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import "FormulaParser.h"

@implementation FormulaParser

+ (NSObject<Formula> *)parse:(NSString *)s {
    s = [s stringByTrimmingCharactersInSet:
         [NSCharacterSet whitespaceCharacterSet]];
    NSString *escaped = [FormulaParser hideParams:s];
    int posPlus = [escaped rangeOfString:@"+"].location;
    int posPar = [escaped rangeOfString:@"("].location;
    NSObject<Formula> *formula = nil;
    if (posPlus != NSNotFound && (posPlus < posPar || posPar == NSNotFound)) {
        formula = [FormulaParser parseSum:s];
    } else if (posPar != NSNotFound && (posPar < posPlus || posPlus == NSNotFound)) {
        formula = [FormulaParser parseFunction:s];
    } else if ([s hasSuffix:@"IS NULL"]) {
        formula = [[Function alloc] initWithName:@"IS NULL" param:[FormulaParser parse:[s substringToIndex:s.length - 7]]];
    } else if ([s hasPrefix:@"[<"] && [s hasSuffix:@">]"]) {
        formula = [[Function alloc] initWithName:@"FIELD" param:[FormulaParser parse:[s substringWithRange:NSMakeRange(2, s.length - 4)]]];
    } else if ([s hasPrefix:@"'<" ] && [s hasSuffix:@">'"]) {
        formula = [[Constant alloc] initWithValue:[s substringWithRange:NSMakeRange(2, s.length - 4)]];
    } else if ([s hasPrefix:@"'"] && [s hasSuffix:@"'"]) {
        formula = [[Constant alloc] initWithValue:[s substringWithRange:NSMakeRange(1, s.length - 2)]];
    } else if ([s hasPrefix:@"\""] && [s hasSuffix:@"\""]) {
        formula = [[Constant alloc] initWithValue:[s substringWithRange:NSMakeRange(1, s.length - 2)]];
    } else {
        formula = [[Constant alloc] initWithValue:s];
    }
    return formula;
}

+ (NSString *)hideParams:(NSString *)s  {
    NSMutableString *tmp = [[NSMutableString alloc] initWithCapacity:[s length]];
    int lvl = 0;
    for (int i = 0; i < [s length]; i++) {
        unichar c = [s characterAtIndex:i];
        if (i > 0 && [s characterAtIndex:i - 1] == '(') {
            lvl++;
        } else if (c == ')') {
            lvl--;
        }
        if (lvl > 0) {
            if (c == ',' && lvl == 1) {
                c = ',';
            } else {
                c = ' ';
            }
        }
        [tmp appendFormat:@"%c", c];
    }
    return tmp;
}

+ (NSArray *)split:(NSString *)s with:(NSString *)chars {
    NSCharacterSet *charset = [NSCharacterSet characterSetWithCharactersInString:chars];
    NSString *escaped = [FormulaParser hideParams:s];
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableString *tmp = [[NSMutableString alloc] initWithCapacity:1];
    for (int i = 0; i < escaped.length; i++) {
        BOOL found = NO;
        if ([charset characterIsMember:[escaped characterAtIndex:i]]) {
            found = YES;
            if (tmp.length > 0) {
                [results addObject:[NSString stringWithString:tmp]];
                [tmp setString:@""];
            }
        }
        if (!found) {
            [tmp appendFormat:@"%c", [s characterAtIndex:i]];
        }
    }
    if (tmp.length > 0) {
        [results addObject:[NSString stringWithString:tmp]];
    }
    return results;
}

+ (Function *)parseSum:(NSString *)s {
    Function *function =  [[Function alloc] initWithName:@"CONCAT"];
    NSArray *parts = [FormulaParser split:s with:@"+"];
    for (NSString *part in parts) {
        [function.parameters addObject:[FormulaParser parse:part]];
    }
    return function;
}

+ (Function *)parseFunction:(NSString *)s {
    NSArray *parts = [FormulaParser split:s with:@"(,)"];
    Function *function = nil;
    if (parts.count > 0) {
        function = [[Function alloc] initWithName:[[parts objectAtIndex:0] stringByTrimmingCharactersInSet:
                    [NSCharacterSet whitespaceCharacterSet]]];
        for (int i = 1; i < parts.count; i++) {
            NSString *part = [[parts objectAtIndex:i] stringByTrimmingCharactersInSet:
                              [NSCharacterSet whitespaceCharacterSet]];
            [function.parameters addObject:[FormulaParser parse:part]];
        }
    } else {
        function = [[Function alloc] initWithName:s];
    }
    return function;
    
}

@end
