//
//  AppDelegate.h
//  Parcel
//
//  Created by Davin Pen on 10/2/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "LoginViewController.h"
#import "AJNotificationView.h"
#import "SoundTool.h"
#import "MBProgressHUD.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>{
    Facebook *facebook;
    NSString *deviceTokenData;
    AJNotificationView *panel;
    LoginViewController *login;
    NSMutableData* receivedData;
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) NSString *deviceTokenData;
@property (nonatomic, retain) Facebook *facebook;
@property (strong, nonatomic) NSMutableDictionary *handleOpenPage;

-(void)openURLPage;

@end
