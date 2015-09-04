//
//  PadPreferences.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/25/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Configuration.h"
#import "SyncProcess.h"
#import "LoginRequest.h"
#import "IpadAboutController.h"
#import "DBTools.h"
#import "LoginListener.h"
#import "AlertViewTool.h"
#import "gadgetAppDelegate.h"
#import "SyncInterface.h"
#import "PadSyncFiltersView.h"

@interface PadPreferences : UITableViewController<SyncInterface, UITextFieldDelegate, UIAlertViewDelegate, LoginListener> {
    NSArray *fields;
    UIButton *btnTest;
    UIActivityIndicatorView *indicSync;
    // CH : Add Merge Address Book
    UILabel *urlLabel;
    NSArray *displayFields;
    NSMutableDictionary *footerViews;
    UIButton *btnSync;
    UIView *footerView;
}
@property (nonatomic, retain) UIView *footerView;
@property (nonatomic, retain) UIButton *btnSync;
@property (nonatomic, retain) UIButton *btnTest;
@property (nonatomic, retain) UILabel *urlLabel;
@property (nonatomic, retain) NSArray *fields;
@property (nonatomic, retain) NSArray *displayFields;
@property (nonatomic, retain) UIActivityIndicatorView *indicSync;

- (void)textChange:(id)sender;
- (void)testConnection:(id)sender;
- (void)refresh;
// - (void)viewinbox;
- (void)showAdvancedPreferences;

@end
