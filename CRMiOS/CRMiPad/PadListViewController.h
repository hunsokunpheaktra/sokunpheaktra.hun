//
//  ImageViewController.h
//  Orientation
//
//  Created by Sy Pauv Phou on 3/24/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntityInfo.h"
#import "Group.h"
#import "EntityManager.h"
#import "Configuration.h"
#import "FilterManager.h"
#import "GroupManager.h"
#import "BigDetailViewController.h"
#import "LikeCriteria.h"
#import "ContainsCriteria.h"
#import "OrCriteria.h"
#import "Subtype.h"
#import "NotInCriteria.h"
#import "EvaluateTools.h"
#import "FilterListPopup.h"
#import "PadMainViewController.h"
#import "MiniCalendarViewController.h"
#import "TaskSummaryViewController.h"
#import "PDFViewController.h"
#import "ExportCSV.h"
#import "CurrentUserManager.h"
#import <MessageUI/MessageUI.h>

@class PadMainViewController;
@class EditViewController;

@interface PadListViewController : UIViewController <UpdateListener, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
    NSString *subtype;
    NSObject <Subtype> *sinfo;
    PadMainViewController *parent;
    NSArray *groups; 
    UITableView *listView;
    NSString *nameFilter;
    Item *selectedItem;
    UIBarButtonItem *filter;
    UIBarButtonItem *addButton;
    UIBarButtonItem *swapButton;
    UIViewController *alternateVC;
    UINavigationBar *navigationBar;
    BOOL viewAlternate;
    NSArray *listData;
    UIActionSheet *actionsheet;
    NSMutableArray *actions;
}
@property (nonatomic, retain) NSArray *listData;
@property (readwrite) BOOL viewAlternate;
@property (nonatomic, retain) UIViewController *alternateVC;
@property (nonatomic, retain) PadMainViewController *parent;
@property (nonatomic, retain) NSString *subtype;
@property (nonatomic, retain) NSObject <Subtype> *sinfo;
@property (nonatomic, retain) NSArray *groups;
@property (nonatomic, retain) UITableView *listView;
@property (nonatomic, retain) UIBarItem *filter;
@property (nonatomic, retain) NSString *nameFilter;
@property (nonatomic, retain) Item *selectedItem;
@property (nonatomic, retain) UIBarButtonItem *addButton;
@property (nonatomic, retain) UIBarButtonItem *swapButton;
@property (nonatomic, retain) UINavigationBar *navigationBar;
@property (nonatomic, retain) NSMutableArray *actions;

- (id)initWithSubtype:(NSString *)subtype parent:(PadMainViewController *)newParent;
- (void)filterData;
- (void)selectItem:(NSString *)key;
- (void)filterClick:(id)sender;
- (void)addClick;
- (void)checkAddButton;
- (void)buildView;
- (void)swapView;
- (void)viewPDF;
- (void)exportCSV;
- (void)actionClick;
- (void)exportAppointments;


@end
