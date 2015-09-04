//
//  PadSyncFiltersView.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 1/25/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Configuration.h"
#import "SyncProcess.h"
#import "LoginRequest.h"
#import "DetailFilterPopup.h"
#import "SelectionPopup.h"
#import "IpadAboutController.h"
#import "PadSyncController.h"
#import "DBTools.h"
#import "MergeContacts.h"
#import "ContactExportView.h"
#import "PadTabTools.h"
#import "LoginListener.h"
#import "AlertViewTool.h"
#import "gadgetAppDelegate.h"
#import "CalendarEventTool.h"
#import "AppPurchaseManager.h"

@interface PadSyncFiltersView : UITableViewController<SyncInterface, UITextFieldDelegate, UIAlertViewDelegate>{

    NSArray *fields;
    NSMutableArray *entities;
    UIButton *btnReinitDB;
    // CH : Add Merge Address Book
    NSString *mergeContact;
    UISwitch *mergeBtn;
    UILabel *urlLabel;
    NSArray *displayFields;
    BOOL isFilterChange;
    NSMutableDictionary *footerViews;
    UITextField *txtRemote;
    NSMutableArray *otherProperty;
    
}
@property (nonatomic, retain) NSMutableArray *otherProperty;
@property (nonatomic, retain) NSMutableDictionary *footerViews;
@property (nonatomic, retain) UILabel *urlLabel;
@property (nonatomic, retain) NSArray *displayFields;
@property (nonatomic, retain) NSMutableArray *entities;
@property (nonatomic, retain) UIButton *btnReinitDB;

@property (nonatomic, retain) NSString *mergeContact;
@property (nonatomic, retain) UISwitch *mergeBtn;


- (void)optionchange:(id)sender;
- (void)switchChanged:(id)sender;
- (void)showOwnerFilter:(id)sender;
- (void)showDateFilter:(id)sender;
- (void)refresh;
- (void)reInitDB;
- (void)importContact:(id)sender;
- (void)exportContact:(id)sender;
- (void)filterChanged;
- (void)buyNow:(id)sender;
- (void)initOtherProperty;
- (void)showModifiedMSG;

@end
