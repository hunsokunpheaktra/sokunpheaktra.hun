//
//  CRMAppDelegate.h
//  CRM
//
//  Created by MACBOOK on 3/2/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//
#import "Configuration.h"
#import "PreferencesViewController.h"
#import "SyncProcess.h"
#import "ListViewController.h"
#import "LayoutViewController.h"
#import "DBTools.h"
#import "IphoneAbout.h"
#import "TodayViewController.h"
#import "IphoneSynchronizationView.h"
#import "GoogleTracker.h"
#import "Appirater.h"
#import "AlertViewTool.h"
#import "EncryptedDatabase.h"
#import "TabLayout.h"
#import "TabTools.h"
#import "SoundTool.h"
#import "FBConnect.h"
#define FB_appId @"521592177860864"

@interface CRMAppDelegate : UIViewController <UIApplicationDelegate, UITabBarControllerDelegate, TabLayout> {
    UIWindow *window;	
	UITabBarController *tabBarController;
    NSNumber *isbackground;
}

@property(nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) NSTimer *timer;

- (void)tabBarController:(UITabBarController *)tabBarController willEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed;
- (void)initLayout;
- (void)selectFeedTab;
- (UIViewController *)getPrefTab;

- (void)runScheduleTimer;
- (void)abortScheduleTimer;



@end

