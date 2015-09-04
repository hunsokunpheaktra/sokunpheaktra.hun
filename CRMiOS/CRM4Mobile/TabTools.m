//
//  TabTools.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 9/30/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "TabTools.h"


@implementation TabTools

+ (void)buildTabs:(UITabBarController *)tabBarController {
        
    // retrieve synchronize view from existing controllers
    NamedNavigationController *syncController = nil;
    NamedNavigationController *prefsController = nil;
    for (NamedNavigationController *navController in tabBarController.viewControllers) {
        if ([[navController name] isEqualToString:@"Synchronization"]) {
            syncController = navController;
            break;
        }
        if ([[navController name] isEqualToString:@"Preferences"]) {
            prefsController = navController;
            break;
        }
    }
    
    
    NSMutableArray *controllers = [[NSMutableArray alloc] initWithCapacity:1];

    NSArray *tabs = [TabManager readTabs];
    [[SyncController getInstance] clearListControllers];
    for (NSString *tab in tabs) {
        
        
        
        if ([tab isEqualToString:@"Preferences"] && prefsController != nil) {
            [controllers addObject:prefsController];
        } else if ([tab isEqualToString:@"Synchronization"] && syncController != nil) {
            [controllers addObject:syncController];
        } else {
            UIViewController *tabViewController = nil;
            if ([tab isEqualToString:@"Calendar"]) {
                if ([[Configuration getEntities] indexOfObject:@"Activity"] != NSNotFound) {
                    tabViewController = [[IphoneCalendarView alloc] init];
                    tabViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"CALENDAR", @"Calendar Tab") image:[UIImage imageNamed:@"Calendar-Month.png"] tag:3];
                }
            } else if ([tab isEqualToString:@"Scan"]) {
                // Scan
//                tabViewController = [[ScanViewController alloc] init];
//                tabViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Scan" image:[UIImage imageNamed:@"195-barcode.png"] tag:5];
                
            } else if ([tab isEqualToString:@"Today"]) {
                if ([[Configuration getEntities] indexOfObject:@"Activity"] != NSNotFound) {
                    //Today activity
                    tabViewController = [[TodayViewController alloc] init];
                    tabViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"TODAY_VIEW", @"today tab label on iphone") image:[UIImage imageNamed:@"Todayblack.png"] tag:0];
                } else {
                    continue;
                }
            } else if ([tab isEqualToString:@"About"]) {
                
                //about
                tabViewController = [[IphoneAbout alloc] init];
                tabViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"ABOUT", @"about") image:[UIImage imageNamed:@"about.png"] tag:0];
                
            } else if ([tab isEqualToString:@"Preferences"]) {
                // settings
                tabViewController = [[PreferencesViewController alloc] init];
                tabViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"PREFERENCES", @"preferences tab label") image:[UIImage imageNamed:@"20-gear2.png"] tag:0];
            } else if ([tab isEqualToString:@"Synchronization"]) {
                // synchronization
                tabViewController = [[IphoneSynchronizationView alloc] init];
                tabViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"SYNCHRONIZE", @"synchronize tab label") image:[UIImage imageNamed:@"02-redo.png"] tag:0];
                [[SyncController getInstance] setSynchronize:(IphoneSynchronizationView *)tabViewController];
            } else if ([tab isEqualToString:@"Layouts"]) {
                // layouts
                tabViewController = [[LayoutViewController alloc] init];
                tabViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"CUSTOM_LAYOUTS", @"custom layout tab label") image:[UIImage imageNamed:@"187-pencil.png"] tag:0];
            } else if ([tab isEqualToString:@"Feed"]) {
                // layouts
                tabViewController = [[FeedsViewController alloc] init];
                tabViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"FEED_TITLE", @"Feed") image:[UIImage imageNamed:@"08-chat.png"] tag:0];
            } else  {
                // entity
                 NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:tab];
                 if ([[PropertyManager read:[NSString stringWithFormat:@"sync%@", [sinfo entity]]] isEqualToString:@"true"]) {
                    tabViewController = [[ListViewController alloc] initWithEntity:[sinfo entity] subtype:[sinfo name]];
                    NSString *iconName = [sinfo iconName]; 
                    tabViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:[sinfo localizedPluralName] image:[UIImage imageNamed:iconName] tag:0];
                    [[SyncController getInstance] addListController:(ListViewController *)tabViewController];
                 } else {
                     continue;
                 }
            }
            if (tabViewController != nil) {
                NamedNavigationController *navController = [[NamedNavigationController alloc] initWithRootViewController:tabViewController name:tab]; 
                [controllers addObject:navController];
            }
        }
    }
    
    tabBarController.viewControllers = controllers;
}

@end
