//
//  AutoSyncPopupViewController.h
//  CRMiOS
//
//  Created by Hun Sokunpheaktra on 5/21/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

/*
** Use by PadSyncFiltersView for show automatic synchronization picklist popup
*/

#import <UIKit/UIKit.h>
#import "SyncTools.h"
#import "PropertyManager.h"
#import "gadgetAppDelegate.h"

@interface AutoSyncPopupViewController : UITableViewController

@property(nonatomic, retain) NSArray *picklistItems;
@property(nonatomic, retain) UITableViewCell *cell;
@property(nonatomic, retain) NSString *value;
@property(nonatomic, retain) UIPopoverController *popover;

- (id)init:(NSString*)value;
- (void)show:(UITableViewCell*)cell parentView:(UIView *)parentView;

@end
