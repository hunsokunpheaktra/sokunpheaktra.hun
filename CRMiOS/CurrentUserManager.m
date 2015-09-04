//
//  CurrentUserManager.m
//  CRMiOS
//
//  Created by Sy Pauv on 7/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "CurrentUserManager.h"


@implementation CurrentUserManager


+ (void)initTable {
    
    Database *database = [Database getInstance];
    NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    [columns addObject:@"UserId"];
    [types addObject:@"TEXT"];
    [columns addObject:@"Alias"];
    [types addObject:@"TEXT"];
    [columns addObject:@"UserSignInId"];
    [types addObject:@"TEXT"];
    
    [database check:@"currentUser" columns:columns types:types];
    NSMutableArray *indexColumns;
    // name index
    indexColumns = [NSMutableArray arrayWithObjects:@"UserId", @"UserSignInId", Nil];
    [database createIndex:@"currentUser" columns:indexColumns unique:true];
}

static NSDictionary *cache = nil;
static NSString *cacheLanguage = nil;
static NSString *cacheSalesProcessId;
static NSTimeZone *cacheTimezone = nil;


+ (void)initData {
    [cache release];
    cache = nil;
    cacheLanguage = nil;
    cacheTimezone = nil;
}




+ (void)upsert:(NSDictionary *)newItem {
    [CurrentUserManager initData];
    Database *database = [Database getInstance];
    [database remove:@"currentUser" criterias:nil];
    [database insert:@"currentUser" item:newItem];    
}


+ (NSDictionary *)read {
    if (cache != nil) return cache;
    NSArray *fields = [NSArray arrayWithObjects:@"UserId", @"Alias", @"UserSignInId", nil];
    NSArray *tmp = [[Database getInstance] select:@"currentUser" fields:fields criterias:nil order:nil ascending:YES];
    NSDictionary *user = nil;
    if ([tmp count] > 0) {
        user = [tmp objectAtIndex:0];
    }
    cache = user;
    return user;
}

+ (NSString *)getLanguageCode {
    if (cacheLanguage != nil) return cacheLanguage;
    NSDictionary *currentUser = [CurrentUserManager read];
    NSString *languageCode = nil;
    if (currentUser != nil) {
        Item *userInfo = [EntityManager find:@"User" column:@"Id" value:[currentUser objectForKey:@"UserId"]];
        if (userInfo != nil) {
            NSString *userLanguage = [userInfo.fields objectForKey:@"LanguageCode"];
            if (userLanguage != nil && ![[userLanguage stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]] isEqualToString:@""]) {
                languageCode = [userInfo.fields objectForKey:@"LanguageCode"];
            }
        }
        [userInfo release];
    }
    if (languageCode == nil) {
        // language not found : read the company's default language
        languageCode = [PropertyManager read:@"DefaultLanguage"];
        if (languageCode == nil) {
            languageCode = @"ENU";
        }
    }
    if (languageCode != nil) {
        cacheLanguage = [[NSString alloc] initWithString:languageCode];
    }
    return languageCode;
}


+ (NSString *)getSalesProcessId{
    if (cacheSalesProcessId != nil) return cacheSalesProcessId;
    NSDictionary *currentUser = [CurrentUserManager read];
    NSString *salesProcessId;
    if (currentUser != nil) {
        Item *userInfo = [EntityManager find:@"User" column:@"Id" value:[currentUser objectForKey:@"UserId"]];
        if (userInfo != nil && [userInfo.fields objectForKey:@"SalesProcessId"] != nil) {
            salesProcessId = [userInfo.fields objectForKey:@"SalesProcessId"];
        }
        [userInfo release];
    }

    return salesProcessId;
}

+ (Item *)getCurrentUserInfo {
    NSDictionary *currentUser = [CurrentUserManager read];
    if (currentUser != nil) {
        
        Item *userInfo = [EntityManager find:@"User" column:@"Id" value:[currentUser objectForKey:@"UserId"]];
        if (userInfo!=nil) {
            return userInfo;
        }
        
    }
    return nil;

}

+ (NSTimeZone *)getUserTimeZone {
    if (cacheTimezone != nil) return cacheTimezone;
    NSDictionary *currentUser = [CurrentUserManager read];
    NSTimeZone *timezone = nil;
    if (currentUser != nil) {
        Item *userInfo = [EntityManager find:@"User" column:@"Id" value:[currentUser objectForKey:@"UserId"]];
        if (userInfo != nil && [userInfo.fields objectForKey:@"TimeZoneName"] != nil) {
            NSString *tzName = [userInfo.fields objectForKey:@"TimeZoneName"];
            // hack for US central time
            if ([tzName rangeOfString:@"Central Time (US & Canada)"].location != NSNotFound) {
                tzName = @"Chicago";
            }
            NSArray *chunks = [tzName componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@", "]];

            // first, search on city name : this is more precise
            for (NSString *tmpz in [NSTimeZone knownTimeZoneNames]) {
                for (int i = 0; i < [chunks count]; i++) {
                    NSString *curTimeZone = [chunks objectAtIndex:i];
                    curTimeZone = [curTimeZone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    // less than 4 characters is not significant
                    if ([curTimeZone length] < 4) continue;
                    curTimeZone = [NSString stringWithFormat:@"/%@", curTimeZone];
                    if ([tmpz rangeOfString:curTimeZone].location != NSNotFound) {
                        timezone = [[NSTimeZone alloc] initWithName:tmpz];
                        break;
                    }
                }
            }
            
            // if not found, set the timezone with hour difference
            if (timezone == nil) {
                if ([tzName rangeOfString:@"(GMT"].location != NSNotFound) {
                    for (NSString *tmpz in [NSTimeZone knownTimeZoneNames]) {
                        NSTimeZone *otherTz = [NSTimeZone timeZoneWithName:tmpz];
                        NSString *otherTzCode = [otherTz localizedName:NSTimeZoneNameStyleDaylightSaving locale:nil];
                        if ([tzName rangeOfString:otherTzCode].location != NSNotFound) {
                            timezone = [[NSTimeZone alloc] initWithName:tmpz];
                            break;
                        }
                    }
                }
            }
        }
        [userInfo release];
    }
    // if still not found, set timezone to GMT
    if (timezone == nil) {
        timezone = [[NSTimeZone alloc] initWithName:@"GMT"];
    }
    cacheTimezone = timezone;
    return timezone;
}


@end
