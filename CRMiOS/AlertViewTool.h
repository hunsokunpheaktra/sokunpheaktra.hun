//
//  AlertViewTool.h
//  CRMiOS
//
//  Created by Hun Sokunpheaktra on 9/5/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Database.h"
#import "EncryptedDatabase.h"
#import "TabLayout.h"

@class Database;

@interface AlertViewTool : UIViewController<UIPopoverControllerDelegate, UITextFieldDelegate> {
    
    Database *controlDb;
    
    UITextField *txtPassword;
    UITextField *txtConfirm;
    UILabel *lblHead;
    UITextView *tvDesc;
    UILabel *lblPass;
    UILabel *lblConfirm;
    UIButton *btnCreate;
    UIButton *btnCancel;
    
    UIPopoverController *popup;
    UIView *mainView;
    UITextView *lblMessage;
    
    NSObject <TabLayout> *tabLayout;

}

@property (nonatomic, retain) UIPopoverController *popup;
@property (nonatomic, retain) Database *controlDb;
@property (nonatomic, retain) NSObject <TabLayout> *tabLayout;
@property (nonatomic, retain) UIView *mainView;

- (id)initWithDatabase:(Database*)db parentView:(UIView *)parentView tabLayout:(NSObject <TabLayout> *)tabLayout;
- (void)loadOpenDatabase;
- (void)loadEncryptedDatabase;
- (void)loadLayout;
- (IBAction)createEncryptedDatabase:(id)sender;
- (IBAction)notUsePassword:(id)sender;
- (IBAction)validateDatabase:(id)sender;
- (void)loadGUI;

@end
