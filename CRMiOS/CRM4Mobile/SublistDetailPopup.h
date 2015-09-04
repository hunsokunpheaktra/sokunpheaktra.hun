//
//  SublistDetailView.h
//  CRMiOS
//
//  Created by Sy Pauv on 11/15/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Configuration.h"
#import "ConfigSublist.h"
#import "Item.h"
#import "SublistManager.h"
#import "UITools.h"
#import "Base64.h"
#import "SublistEditVC.h"
#import "URLViewerVC.h"
#import "gadgetAppDelegate.h"

@interface SublistDetailPopup : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    UIPopoverController *popoverController;
    UITableView *tableView;
    SublistItem *item;
    Item *parentItem;
    NSArray *listFields;
    BOOL canDelete;
    NSObject<CreationListener, UpdateListener> *listener;
    UINavigationController *navController;
}

@property (nonatomic, retain) NSArray *listFields;
@property (nonatomic, retain) SublistItem *item;
@property (nonatomic, retain) Item *parentItem;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) NSObject<CreationListener, UpdateListener> *listener;
@property (nonatomic, retain) UINavigationController *navController;
@property (readwrite) BOOL canDelete;

- (id)initWithItem:(SublistItem *)newItem parentItem:(Item *)parentItem listener:(NSObject<CreationListener, UpdateListener> *)newListener navController:(UINavigationController *)navController;
- (void)show:(CGRect)rect parentView:(UIView *)parentView ;

@end
