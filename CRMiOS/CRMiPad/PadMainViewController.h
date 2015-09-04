//
//  MainView.h
//  Orientation
//
//  Created by Sy Pauv Phou on 3/25/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreationListener.h"
#import "NavigateListener.h"
#import "PadSyncController.h"
#import "PadListViewController.h"
#import "MGSplitViewController.h"

#define LANDSCAPE_BOTTOM 93
#define LANDSCAPE_TOP 0
#define LANDSCAPE_MARGIN 0

#define PORTRAIT_BOTTOM 93
#define PORTRAIT_TOP 0
#define PORTRAIT_MARGIN 0

@class PadListViewController;
@class BigDetailViewController;

@interface PadMainViewController : MGSplitViewController <UpdateListener, SyncInterface, CreationListener> {
    NSString *subtype;
    PadListViewController *listViewController;
    BigDetailViewController *itemViewController;
    NSNumber *isLandscape;
    UITabBarController *tabBarController;
}

@property (nonatomic, retain) NSString *subtype;
@property (nonatomic, retain) PadListViewController *listViewController;
@property (nonatomic, retain) BigDetailViewController *itemViewController;
@property (nonatomic, retain) NSNumber *isLandscape;
@property (nonatomic, retain) UITabBarController *tabBarController;

- (id)initWithSubtype:(NSString *)subtype tabBarController:(UITabBarController *)tabBarController;
- (void)setCurrentDetail:(Item *)item;

@end
