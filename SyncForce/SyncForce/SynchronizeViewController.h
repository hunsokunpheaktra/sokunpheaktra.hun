//
//  SynchronizeViewController.h
//  kba
//
//  Created by Sy Pauv on 10/3/11.
//  Copyright 2011 GAEASYS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LogItem.h"
#import "SyncProcess.h"
#import "PropertyManager.h"
#import "SynchronizeViewInterface.h"
#import "FDCOAuthViewController.h"
#import "FDCServerSwitchboard.h"

@class MainMergeRecord;

// Vertical space between a section header and the fields in that section
#define SECTIONSPACING 10

// Vertical space between field rows within a section
#define FIELDSPACING 5

// Standard width of a field label
#define FIELDLABELWIDTH 140

// Standard width of a field value
#define FIELDVALUEWIDTH 190

// Maximum height for a field value
#define FIELDVALUEHEIGHT 999



@interface SynchronizeViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate,SynchronizeViewInterface> {
    
    UILabel *percentView;
    UILabel *status;
    NSArray *listLog;
    UIButton *btnSync;
    UITableView *mytableView;
    UIProgressView *progress;
    UIActivityIndicatorView *indicSync;
    UIToolbar *toolbarButtons;
    FDCOAuthViewController *oAuthViewController;
    FDCServerSwitchboard *connector;
    
    NSThread *current;
    
     NSArray *listrecods;
    
}
@property(nonatomic , retain) UILabel *status;
@property(nonatomic , retain) UILabel *percentView;
@property(nonatomic , retain) UIButton *btnSync;
@property(nonatomic , retain) UIActivityIndicatorView *indicSync;
@property(nonatomic , retain) UIProgressView *progress;
@property(nonatomic , retain) UITableView *mytableView;
@property(nonatomic , retain) NSArray *listLog;
@property (nonatomic, retain) NSArray *listrecods;

- (void) startSync;

@end
