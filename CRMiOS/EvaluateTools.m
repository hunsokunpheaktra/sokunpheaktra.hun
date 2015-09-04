//
//  EvaluateTools.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 8/1/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "EvaluateTools.h"


@implementation EvaluateTools

// These are static for perf reasons.
// Alloc and init are slow.
NSDateFormatter *timeFormat;
NSDateFormatter *dateFormat;
NSDateFormatter *shortDateFormat;
NSDateFormatter *timeParser;
NSDateFormatter *dateParser;


+ (NSDateFormatter *)getTimeFormat {
    if (timeFormat == nil) {
        timeFormat = [[NSDateFormatter alloc] init];
        [timeFormat setTimeZone:[CurrentUserManager getUserTimeZone]];
        [timeFormat setTimeStyle:NSDateFormatterShortStyle];
        [timeFormat setDateStyle:NSDateFormatterNoStyle];
    }
    return timeFormat;
}

+ (NSDateFormatter *)getDateFormat {
    if (dateFormat == nil) {
        dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setTimeZone:[CurrentUserManager getUserTimeZone]];
        [dateFormat setTimeStyle:NSDateFormatterNoStyle];
        [dateFormat setDateStyle:NSDateFormatterLongStyle];
    }
    return dateFormat;
}

+ (NSDateFormatter *)getShortDateFormat {
    if (shortDateFormat == nil) {
        shortDateFormat = [[NSDateFormatter alloc] init];
        [shortDateFormat setTimeZone:[CurrentUserManager getUserTimeZone]];
        [shortDateFormat setTimeStyle:NSDateFormatterNoStyle];
        [shortDateFormat setDateStyle:NSDateFormatterShortStyle];
    }
    return shortDateFormat;
}

+ (NSDateFormatter *)getTimeParser {
    if (timeParser == nil) {
        timeParser = [[NSDateFormatter alloc] init];
        [timeParser setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        [timeParser setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    }
    return timeParser;
}

+ (NSDateFormatter *)getDateParser {
    if (dateParser == nil) {
        dateParser = [[NSDateFormatter alloc] init];
        [dateParser setDateFormat:@"yyyy-MM-dd"];
        [dateParser setTimeZone:[CurrentUserManager getUserTimeZone]];
    }
    return dateParser;
}

+ (NSArray *)getFieldsFromFormula:(NSString *)formula {
    NSMutableArray *fields = [[NSMutableArray alloc] initWithCapacity:1];
    if (formula != nil) {
        NSMutableString *tmp = [NSMutableString stringWithString:formula];
        while (YES) {
            NSRange start = [tmp rangeOfString:@"{"];
            if (start.length == 0) {
                break;
            }
            NSRange end = [tmp rangeOfString:@"}"];
            if (end.length == 0 || end.location < start.location) {
                break;
            }
            int length = 1 + end.location - start.location;
            NSString *keyword = [tmp substringWithRange:NSMakeRange(start.location + 1, length - 2)];
            NSRange pos = [keyword rangeOfString:@":"];
            if (pos.length > 0) {
                keyword = [keyword substringFromIndex:pos.location + 1];
            }
            [fields addObject:keyword];
            
            [tmp replaceCharactersInRange:NSMakeRange(start.location, length) withString:@""];
        }
    }
    return fields;
}

+ (NSString *)evaluate:(NSString *)formula item:(Item *)item {
    return [EvaluateTools evaluate:formula item:item shortFormat:NO];
}


+ (NSString *)evaluate:(NSString *)formula item:(Item *)item shortFormat:(BOOL)shortFormat {
    if (formula == nil) return nil;
    NSMutableString *tmp = [NSMutableString stringWithString:formula];
    while (YES) {
        NSRange start = [tmp rangeOfString:@"{"];
        if (start.length == 0) {
            break;
        }
        NSRange end = [tmp rangeOfString:@"}"];
        if (end.length == 0 || end.location < start.location) {
            break;
        }
        int length = 1 + end.location - start.location;
        NSString *keyword = [tmp substringWithRange:NSMakeRange(start.location + 1, length - 2)];
        NSString *value = nil, *command = nil;
        // special command ?
        NSRange pos = [keyword rangeOfString:@":"];
        if (pos.length > 0) {
            command = [keyword substringToIndex:pos.location];
            keyword = [keyword substringFromIndex:pos.location + 1];
        }
        
        // 1) compute special value codes
        if ([keyword isEqualToString:@"NOW"]) {
            value = [[EvaluateTools getTimeParser] stringFromDate:[[[NSDate alloc] init] autorelease]];
        } else if ([keyword hasPrefix:@"TODAY"]) {
            NSDate *date = [[[NSDate alloc] init] autorelease];
            NSString *suffix = [keyword substringFromIndex:5];
            NSDateComponents *dayComponent = [[[NSDateComponents alloc] init] autorelease];
            dayComponent.day = [suffix intValue];
            NSCalendar *theCalendar = [NSCalendar currentCalendar];
            date = [theCalendar dateByAddingComponents:dayComponent toDate:date options:0];
            value = [[EvaluateTools getDateParser] stringFromDate:date];            
        } else {            
            value = [item.fields objectForKey:keyword];
        }
        // 2) apply commands, if any
        if ([command isEqualToString:@"HOUR"]) {
            // Extract HOUR from field
            NSDate *date = [EvaluateTools dateFromString:value];
            value = [[EvaluateTools getTimeFormat] stringFromDate:date];
        } else if ([command isEqualToString:@"DATE"]) {
            // Extract DATE from field
            NSDate *date = [EvaluateTools dateFromString:value];
            if (shortFormat) {
                value = [[EvaluateTools getShortDateFormat] stringFromDate:date];
            } else {
                NSDateFormatter *formatter = [EvaluateTools getDateFormat];
                value = [formatter stringFromDate:date];
            }
        } else if ([command isEqualToString:@"FIRST"]) {
            // Extract first letter from field
            if (value == nil || [value length] == 0) {
                value = @"#";
            } else {
                value = [[value substringToIndex:1] uppercaseString];
                if ([value compare:@"A"] < 0 || [value compare:@"Z"] > 0) {
                    value = @"#";
                }
            }
        }
        if (value == nil) value = @"";
        [tmp replaceCharactersInRange:NSMakeRange(start.location, length) withString:value]; 
    }
    return tmp;
}

+ (NSDate *)dateFromString:(NSString *)s {
    NSDateFormatter *parser = nil;
    if ([s length] == 10) {
        parser = [EvaluateTools getDateParser];
    } else {
        parser = [EvaluateTools getTimeParser];
    }
    return [parser dateFromString:s];
}



// RSK: translating section header
+ (NSString *)translateWithPrefix:(NSString *)str prefix:(NSString *)prefix {
    if ([str hasSuffix:@"%"] && [str hasPrefix:@"%"]) {
        NSString *code = [NSString stringWithFormat:@"%@%@", prefix, [str substringWithRange:NSMakeRange(1, [str length]-2)]];
        return NSLocalizedString(code, @"translate section header");
    }
    return str;
}

// Transforms the string "AccountName" into "Account Name"
+ (NSString *)formatDisplayField:(NSString *)field{
    NSMutableString *tmpfield = [NSMutableString stringWithString:field];
    int found = 0;
    for (int i = 0; i < [field length]; i++) {
        if (i > 0) {
            if (isupper([field characterAtIndex:i]) && !isupper([field characterAtIndex:i - 1])) {
                [tmpfield insertString:@" " atIndex:i+found];
                found++;
            }
        }
    }
    return tmpfield;
}


+ (NSString *)removeIdSuffix:(NSString *)name {
    if ([name hasSuffix:@" Id"]
            || [name hasSuffix:@"-ID"]
            || [name hasSuffix:@" ID"]) {
        name = [name substringToIndex:[name length] - 3];
    } 
    return name;
}

+ (void)initAppointment:(Item *)appointment date:(NSDate *)date {
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDateComponents *components = [calendar components: NSUIntegerMax fromDate: date];
    [components setTimeZone:[CurrentUserManager getUserTimeZone]];
    [components setHour: 9];
    [components setMinute: 0];
    [components setSecond: 0];
    NSDate *newDate = [calendar dateFromComponents: components];
    [calendar release];
    
    NSDateFormatter *timeParser = [[NSDateFormatter alloc] init];
    [timeParser setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [timeParser setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [appointment.fields setObject:[timeParser stringFromDate:newDate] forKey:@"StartTime"];
    [appointment.fields setObject:[timeParser stringFromDate:[NSDate dateWithTimeInterval:3600 sinceDate:newDate]] forKey:@"EndTime"];
}


+ (NSDate *)getTodayGMT {
    NSLocale *locale = [NSLocale currentLocale];
    NSCalendar *calendar = [locale objectForKey:NSLocaleCalendar];
    NSDateComponents *components = [calendar components: NSUIntegerMax fromDate: [NSDate date]];
    [components setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [components setHour: 0];
    [components setMinute: 0];
    [components setSecond: 0];
    return [calendar dateFromComponents: components];
    
}

@end
