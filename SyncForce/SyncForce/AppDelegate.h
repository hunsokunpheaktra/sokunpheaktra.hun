//
//  SyncForceAppDelegate.h
//  SyncForce
//
//  Created by Gaeasys Admin on 10/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate,UITabBarControllerDelegate> {
    UINavigationController *theNavController;
    NSMutableArray* viewControllers;
    
    BOOL isPortrait;
    BOOL isFirstLoad;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain)  UINavigationController *theNavController;
@property (nonatomic, retain)  UITabBarController *tabController;

- (void)initTabs;
- (void)refreshTabs;

@end
