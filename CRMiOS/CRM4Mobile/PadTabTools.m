//
//  TabTools.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 9/29/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "PadTabTools.h"
#import "Configuration.h"
#import "FeedsViewController.h"

@implementation PadTabTools

+ (void)buildTabs:(UITabBarController *)tabBarController {
    
    // retrieve synchronize view from existing controllers
    UIViewController *existingSyncController = nil;
    UIViewController *existingPrefsController = nil;
    
    for (NamedNavigationController *navController in tabBarController.viewControllers) {
        /*
         *when Synchronization is in more tab navController.visibleViewController is null
         *so we cannot check if it is SynchronizeViewController
         */
        if ([[navController name] isEqualToString:@"Synchronization"]) {
            existingSyncController = navController;
        } else if ([navController.visibleViewController isKindOfClass:[PadSyncFiltersView class]]) {
            NSArray *viewControllers = navController.viewControllers;
            UIViewController *rootViewController = [viewControllers objectAtIndex:viewControllers.count - 2];
            existingPrefsController = rootViewController;
        }  else {
            [navController release];
        }
    }
    
    [[PadSyncController getInstance] clearListControllers];
    NSArray *tabs = [TabManager readTabs];
    NSMutableArray *controllers = [NSMutableArray arrayWithCapacity:1];
    for (NSString *tab in tabs) {
        NamedNavigationController *navController = nil;
        UIViewController *newVC = nil;
        if ([tab isEqualToString:@"Preferences"]) {
            if (existingPrefsController != nil) {
                navController = (NamedNavigationController *)existingPrefsController.navigationController;
            } else {
                newVC = [[PadPreferences alloc] init];
                newVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"PREFERENCES", @"preference tab label") image:[UIImage imageNamed:@"20-gear2.png"] tag:0];
                [[PadSyncController getInstance] setPrefSyncControler:(PadPreferences *)newVC];
            }
            
        } else if ([tab isEqualToString:@"Synchronization"]) {
            if (existingSyncController != nil) {
                navController = (NamedNavigationController *)existingSyncController;
            } else {
                newVC = [[SynchronizeViewController alloc] init];
                newVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"SYNCHRONIZE", @"synchronize tab label") image:[UIImage imageNamed:@"02-redo.png"] tag:0];
                [[PadSyncController getInstance] setSyncController:(SynchronizeViewController *)newVC];
            }
            
        } else if ([tab isEqualToString:@"DailyAgenda"]) {
            if ([[Configuration getEntities] indexOfObject:@"Activity"] != NSNotFound) {
                newVC = [[DailyAgendaViewController alloc]init];
                newVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"DAILY_AGENDA", @"Daily Agenda tab label") image:[UIImage imageNamed:@"103-map.png"] tag:0];
            } else {
                continue;
            }
        } else if ([tab isEqualToString:@"Calendar"]) {
            if ([[Configuration getEntities] indexOfObject:@"Activity"] != NSNotFound) {
                //Biogen tab
                newVC = [[DragAndDropViewController alloc]init];
                newVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"CALENDAR", @"Calendar Tab")  image:[UIImage imageNamed:@"Calendar-Month.png"] tag:0];
            } else {
                continue;
            }
        } else if ([tab isEqualToString:@"Feed"]) {
            
            newVC = [[FeedsViewController alloc] init];
            newVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"FEED_TITLE", @"Feed")  image:[UIImage imageNamed:@"08-chat.png"] tag:0];
            
        } else if ([tab isEqualToString:@"About"]) {
            
            newVC = [[IpadAboutController alloc]init];
            newVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"ABOUT", @"about") image:[UIImage imageNamed:@"about.png"] tag:0];
            
        } else {
            NSObject<Subtype> *sinfo = [Configuration getSubtypeInfo:tab];
            if ([[PropertyManager read:[NSString stringWithFormat:@"sync%@", [sinfo entity]]] isEqualToString:@"true"]) {
                NSString *iconName = [sinfo iconName];
                newVC = [[PadMainViewController alloc] initWithSubtype:[sinfo name] tabBarController:tabBarController];
                newVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:[sinfo localizedPluralName] image:[UIImage imageNamed:iconName] tag:0];
                [[PadSyncController getInstance] addListController:(PadMainViewController *)newVC];
                
            } else {
                continue;
            }
            
        }
        if (navController == nil) {
            navController = [[NamedNavigationController alloc] initWithRootViewController:newVC name:tab];
        }
        [navController.navigationBar setTintColor:[UITools readHexColorCode:[Configuration getProperty:@"headerColor"]]];
        [controllers addObject:navController];
    }
    
    [tabBarController setViewControllers:controllers];
}


+ (void)navigateTab:(Item *)item {
    
    gadgetAppDelegate *delegate = (gadgetAppDelegate*)[[UIApplication sharedApplication] delegate];
    UITabBarController *tab = (UITabBarController*)delegate.window.rootViewController;
    
    NSString *subtype = [Configuration getSubtype:item];
    NSObject<Subtype> *sinfo = [Configuration getSubtypeInfo:subtype]; // #4933
    
    PadMainViewController *main = nil;
    int sel = -1;
    // first pass : search by subtype
    // second pass : search by entity (#4933)
    for (int j = 0; j < 2; j++) {
        int i = 0;
        for (UIViewController *con in tab.viewControllers) {
            if ([con isKindOfClass:[UINavigationController class]]) {
                UINavigationController *nav = (UINavigationController*)con;
                if ([nav.topViewController isKindOfClass:[PadMainViewController class]]) {
                    PadMainViewController *pad = (PadMainViewController*)nav.topViewController;
                    if ((j == 0 && [pad.subtype isEqualToString:subtype])
                        || (j == 1 && [pad.subtype isEqualToString:[sinfo entity]])) {
                        main = pad;
                        sel = i;
                        break;
                    }
                }
                i++;
            }
        }
        if (main != nil) break;
    }
    
    if (main != nil) {
        [main.listViewController selectItem:[item.fields objectForKey:@"gadget_id"]];
        
        if (sel >= 7) {
            // to highlight the "more" button
            [tab setSelectedViewController:tab.moreNavigationController];
        }
        
        [tab setSelectedViewController:main.navigationController];
    }
}

@end
