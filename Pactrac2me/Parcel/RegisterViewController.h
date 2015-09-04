//
//  RegisterViewController.h
//  Parcel
//
//  Created by Hun Sokunpheaktra on 11/7/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "Item.h"
#import "BSKeyboardControls.h"

@interface RegisterViewController : UITableViewController<UITextFieldDelegate,BSKeyboardControlsDelegate>{
    
    MBProgressHUD *hud;
    Item *currentUser;

}

@property (nonatomic, retain) id parentClass;
@property (nonatomic,retain) MBProgressHUD *hud;

-(id)initWithUserInfo:(Item*)newUser parent:(id)parent;

- (void)scrollViewToTextField:(id)textField;

-(void)cancel;
-(void)createUser;
-(BOOL)isValidEmail:(NSString *)checkString;

@end
