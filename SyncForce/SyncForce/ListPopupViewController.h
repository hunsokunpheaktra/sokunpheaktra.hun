//
//  ListPopupViewController.h
//  SyncForce
//
//  Created by Gaeasys Admin on 11/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditViewController.h"

@class EditViewController;

@interface ListPopupViewController : UIViewController<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>{
    
    UIPopoverController *listPopup;
    NSArray *listItems;
    NSString *fieldName;
    
    EditViewController *editController;
    UITableView *tableView;
    NSIndexPath *editPath;
    NSString *selectValue;
    NSString *fType;
    UIViewController *containerViewController;
    NSIndexPath *selectPath;
    
    NSArray *listItemsBackUp;
    
}

@property (nonatomic,retain) UITableView *tableView;
@property (nonatomic,retain) NSIndexPath *selectPath;
@property (nonatomic,retain) NSString *fType;
@property (nonatomic,retain) NSString *selectValue;
@property (nonatomic,retain) NSString *fieldName;
@property (nonatomic,retain) NSIndexPath *editPath;
@property (nonatomic,retain) EditViewController *editController;
@property (nonatomic,retain) UIPopoverController *listPopup;
@property (nonatomic,retain) NSArray *listItems;
@property (nonatomic,retain) NSArray *listItemsBackUp;
@property (nonatomic,retain)  UIViewController *containerViewController;


- (id)initWithController:(NSString*)newEntity fieldName:(NSString*)newField listData:(NSArray*)listData recordType:(NSString*)type parentController:(EditViewController*)parent selectValue:(NSString*)value fieldType:(NSString*)fieldType;
- (void)showPopup:(UIView*)content parentView:(UIView*)parent;

@end
