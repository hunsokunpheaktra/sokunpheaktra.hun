//
//  ViewController.h
//  Parcel
//
//  Created by Davin Pen on 10/2/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserManager.h"
#import "NewParcelViewController.h"

@interface MainViewController : UITabBarController<UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate>{
    
    UIImagePickerController *imagePicker;
    UIPopoverController *popover;
    Item *user;
    UITextField *password;
    
    UIViewController *containerController;
    
}

@property(nonatomic,retain)Item *user;

+ (MainViewController *)getInstance:(Item*)user;
+ (MainViewController *)getInstance;
+ (void)clearInstance;

-(void)reloadTabs;
-(void)logout;
-(NewParcelViewController*)getNewParcelController;

@end
