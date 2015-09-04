//
//  CRMiPadAppDelegate.h
//  CRMiPad
//
//  Created by Sy Pauv Phou on 3/29/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Configuration.h"
#import "Database.h"
#import "DBTools.h"
#import "Configuration.h"
#import "PadPreferences.h"
#import "TabManager.h"
#import "GoogleTracker.h"
#import "DailyAgendaViewController.h"
#import "AlertViewTool.h"
#import "Appirater.h"
#import "Database.h"
#import "EncryptedDatabase.h"
#import "PadTabTools.h"
#import "TabLayout.h"
#import "CurrentUserManager.h"
#import "SoundTool.h"
#import "FeedsViewController.h"
#import "UAirship.h"
#import "UAPush.h"
#import "UAInboxPushHandler.h"
#import "UAInboxUI.h"
#import "UAInbox.h"
#import "UAInboxMessageList.h"
#import "TestFlight.h"
#import "FBConnect.h"

#define FB_appId @"521592177860864"

@interface gadgetAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, TabLayout> {
    NSNumber *isbackground;
}
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) Facebook *facebook;

- (void)initLayout;
- (void)selectFeedTab;
- (UIViewController *)getPrefTab;

- (void)runScheduleTimer;
- (void)abortScheduleTimer;

@end
