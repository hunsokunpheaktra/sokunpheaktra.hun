//
//  PreferencesController.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/22/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PropertyManager.h"
#import "SyncProcess.h"
#import "SyncController.h"
#import "ViewLogController.h"
#import "LoginRequest.h"
#import "AdvancedPreferencesVC.h"
#import "UpdateListener.h"
#import "CRMAppDelegate.h"

@interface PreferencesViewController : UITableViewController<UpdateListener, UITextFieldDelegate, LoginListener> {


    UILabel *urlLabel;
    UIActivityIndicatorView *indicSync;
    UIButton *btnTest;
    NSArray *fields;
    NSArray *displayFields;
    UIButton *btnSync;
}

@property(nonatomic, retain) UIButton *btnTest;
@property(nonatomic, retain) UILabel *urlLabel;
@property(nonatomic, retain) UIActivityIndicatorView *indicSync;
@property(nonatomic, retain) NSArray *fields;
@property(nonatomic, retain) NSArray *displayFields;
@property(nonatomic, retain) UIButton *btnSync;

- (id)init;
- (void)updateSyncButton:(BOOL)animated;
- (void)testConnection;
- (void)changeText:(id)sender;
- (void)goFilters;
// - (void)viewinbox;
- (void)startSync;

@end
