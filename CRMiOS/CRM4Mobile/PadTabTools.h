//
//  TabTools.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 9/29/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TabManager.h"
#import "PadPreferences.h"
#import "SynchronizeViewController.h"
//#import "FeedViewController.h"
#import "DragAndDropViewController.h"
#import "IpadAboutController.h"

@interface PadTabTools : NSObject {
    
}

+ (void)buildTabs:(UITabBarController *)tabBarController;
+ (void)navigateTab:(Item *)item;

@end
