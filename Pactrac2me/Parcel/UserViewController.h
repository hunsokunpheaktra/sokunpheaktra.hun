//
//  UserViewController.h
//  Parcel
//
//  Created by Hun Sokunpheaktra on 11/6/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserManager.h"
#import "SettingsViewController.h"
#import "SyncListener.h"

@interface UserViewController : UITableViewController<UIAlertViewDelegate,UITextFieldDelegate,SyncListener>{
    
    Item *user;
    SettingsViewController *parentVC;
    
    NSMutableArray *fieldLabels;
    NSMutableArray *fieldNames;
    
    BOOL isEditing;
    
}

@property (nonatomic, retain) NSDictionary *fields;
@property (nonatomic, retain) Item *user;

- (id)initWithParent:(id)parent;

- (void)updateView;

@end
