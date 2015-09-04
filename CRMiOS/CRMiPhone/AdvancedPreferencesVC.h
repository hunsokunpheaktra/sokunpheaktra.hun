//
//  SyncFiltersViewController.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/25/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Configuration.h"
#import "DetailFilterViewController.h"
#import "UpdateListener.h"
#import "SyncController.h"
#import "MergeContacts.h"
#import "ContactExportView.h"
#import "DBTools.h"
#import "SyncController.h"
#import "AlertViewTool.h"
#import "CRMAppDelegate.h"
#import "AutoSyncDelayVC.h"
#import "AppPurchaseManager.h"


@interface AdvancedPreferencesVC : UITableViewController<UITextFieldDelegate,UpdateListener> {
    NSMutableArray *entities;
    NSString *mergePhone;
    UISwitch *switchBtn;
    UIButton *btnReinitDB;
    NSObject<UpdateListener> *preferences;
    NSMutableArray *otherProperty;
}
@property (nonatomic, retain) NSMutableArray *otherProperty;
@property (nonatomic, retain) NSObject<UpdateListener> *preferences; 
@property (nonatomic, retain) NSMutableArray *entities;
@property (nonatomic, retain) NSString *mergePhone;
@property (nonatomic, retain) UIButton *btnReinitDB;


-(id)initWithPreference:(NSObject<UpdateListener> *)newupdate;

- (void)importContact:(id)sender;
- (void)exportContact:(id)sender;
- (void)optionchange:(id)sender;
- (void)initOtherProperty;
- (void)buyNow:(id)sender;

@end
