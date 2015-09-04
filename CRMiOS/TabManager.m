//
//  TabManager.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/28/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "TabManager.h"


@implementation TabManager

+ (void)initTable {
    Database *database = [Database getInstance];
    
    NSMutableArray *columns = [NSMutableArray arrayWithObjects:@"num", @"code", nil];
    NSMutableArray *types = [NSMutableArray arrayWithObjects:@"INTEGER PRIMARY KEY", @"TEXT", nil];
    [database check:@"TabLayout" columns:columns types:types];
}

+ (void)initData {
    NSMutableArray *existing = [NSMutableArray arrayWithArray:[self readTabs]];
    NSMutableArray *requiredTabs = [NSMutableArray arrayWithObjects:@"Preferences", @"Synchronization", nil];
    for (NSString *entity in [Configuration getEntities]) {
        NSObject <EntityInfo> *info = [Configuration getInfo:entity];
        if (![info hidden]) {
            if ([info.name isEqualToString:@"Activity"]) {
                for (int i = 0; i < [[info getSubtypes] count]; i++) {
                    ConfigSubtype *stype = [[info getSubtypes] objectAtIndex:i];
                    [requiredTabs addObject:[stype name]];
                }
            } else {
                [requiredTabs addObject:info.name];     
            }
        }
    }
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {

        if ([[[Configuration getInstance].properties objectForKey:@"feedURL"] length] > 0) {
            [requiredTabs insertObject:@"Feed" atIndex:2];
        }
        [requiredTabs addObject:@"DailyAgenda"];
        [requiredTabs addObject:@"Calendar"];
        [requiredTabs addObject:@"About"];
    } else {
        [requiredTabs addObject:@"Calendar"];
        [requiredTabs addObject:@"Layouts"];
        [requiredTabs addObject:@"Today"];
        //[tabs addObject:@"Scan"];
        [requiredTabs addObject:@"About"];
        if ([[[Configuration getInstance].properties objectForKey:@"feedURL"] length] > 0) {
            [requiredTabs insertObject:@"Feed" atIndex:2];
        }
    }
    BOOL somethingChanged = NO;
    // 1. remove tabs that are not required
    while (YES) {
        BOOL again = NO;
        for (NSString *tab in existing) {
            BOOL found = NO;
            for (NSString *required in requiredTabs) {
                if ([required isEqualToString:tab]) {
                    found = YES;
                    break;
                }
            }
            if (!found) {
                [existing removeObject:tab];
                somethingChanged = YES;
                again = YES;
                break;
            }
        }
        if (!again) {
            break;
        }
    }
    // 2. add required tabs at the end
    for (NSString *required in requiredTabs) {
        BOOL found = NO;
        for (NSString *tab in existing) {
            if ([required isEqualToString:tab]) {
                found = YES;
                break;
            }
        }
        if (!found) {
            [existing addObject:required];
            somethingChanged = YES;
        }
    }
    if (somethingChanged) {
        [TabManager saveTabs:existing];
    }
}

+ (NSArray *)readTabs {
    NSMutableArray *fields = [NSMutableArray arrayWithObject:@"code"];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:1];
    NSArray *tmp = [[Database getInstance] select:@"TabLayout" fields:fields criterias:Nil order:@"num" ascending:YES];
    for (NSMutableDictionary *item in tmp) {
        [result addObject:[item objectForKey:@"code"]];
    }
    [tmp release];
    return result;
}

+ (void)saveTabs:(NSMutableArray *)tabs {
    [[Database getInstance] remove:@"TabLayout" criterias:Nil];    
    int i = 0;
    for (NSString *field in tabs) {
        NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
        [item setObject:[NSString stringWithFormat:@"%i",i] forKey:@"num"];
        [item setObject:field forKey:@"code"];
        [[Database getInstance] insert:@"TabLayout" item:item];
        i++;
        [item release];
    }
}


@end
