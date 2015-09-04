//
//  TabManager.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/28/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Database.h"
#import "Configuration.h"
#import "ConfigSubtype.h"

@interface TabManager : NSObject {
    
}

+ (NSMutableArray *)readTabs;
+ (void)saveTabs:(NSMutableArray *)tabs;
+ (void)initTable;
+ (void)initData;

@end
