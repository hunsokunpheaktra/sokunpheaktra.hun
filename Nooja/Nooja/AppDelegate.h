//
//  AppDelegate.h
//  Nooja
//
//  Created by Arnaud Marguerat on 4/18/12.
//  Copyright Fellow Consulting 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
