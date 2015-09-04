//
//  TabTools.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 9/30/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TabManager.h"
#import "TodayViewController.h"
#import "IphoneAbout.h"
#import "PreferencesViewController.h"
#import "IphoneCalendarView.h"
#import "NamedNavigationController.h"
#import "FeedsViewController.h"

@interface TabTools : NSObject {
    
}

+ (void)buildTabs:(UITabBarController *)tabBarController;

@end
