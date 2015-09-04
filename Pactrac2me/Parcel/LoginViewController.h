//
//  LoginViewController.h
//  Parcel
//
//  Created by Hun Sokunpheaktra on 10/30/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTMOAuth2SignIn.h"
#import "SBJSON.h"
#import "FBConnect.h"
#import "MBProgressHUD.h"
#import "RegisterViewController.h"
#import "Item.h"
#import "MBProgressHUD.h"
#import "MainViewController.h"
#import "SyncProcess.h"

#define Google_clientId @"663023883252-577klgdcq6lvpr0gpvn6f599m9irr457.apps.googleusercontent.com"
#define Google_clientSecret @"XPsb8rOohS6sm7Vz9908onOe"

#define FB_appId @"428974017156122"
#define FB_appSecret @"e9b1494aff34b6a20f82f66c3791cd9"

@interface LoginViewController : UITableViewController<FBRequestDelegate,FBSessionDelegate,UITextFieldDelegate,SyncListener,UIAlertViewDelegate>{
    
    GTMOAuth2Authentication *googleAuth;
    int mNetworkActivityCounter;
    MBProgressHUD *hud;
    Item *currentUser;
    NSString *loginFrom;
    
}

@property(nonatomic,retain)Item *currentUser;
@property(nonatomic,retain)GTMOAuth2Authentication *googleAuth;
@property(nonatomic,retain)MBProgressHUD *hud;
@property(nonatomic,retain)NSString *userEmail;
@property(nonatomic,retain)UIToolbar *toolbar;

//google authorize
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error;
- (void)incrementNetworkActivity:(NSNotification *)notify;
- (void)decrementNetworkActivity:(NSNotification *)notify;
- (void)signInNetworkLostOrFound:(NSNotification *)notify;
- (void)displayAlertWithMessage:(NSString *)str;

-(void)googleLogin;
-(void)localUserLogin;
-(void)logout;
-(void)forgotPassword;
-(void)loginToApp:(Item*)loginUser isLocal:(BOOL)isLocal;

-(void)registerScreen:(Item*)newUser;
-(void)login2Mainscreen:(Item*)user;
-(void)registerUser:(id)sender;

@end
