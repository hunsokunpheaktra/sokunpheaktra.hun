//
//  SettingViewController.h
//  Parcel
//
//  Created by Davin Pen on 10/2/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateListener.h"
#import "SettingManager.h"
#import "ReminderListener.h"
#import "DefaultRemindersettingsView.h"
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>

@interface SettingsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UpdateListener,ReminderListener,MFMailComposeViewControllerDelegate>{
    
    NSMutableDictionary *sections;
    UITableView *tableView;
    NSDictionary *languages;
    
    NSArray *headerTitle;
    
    Item *settingItem;
    Item* userLogin;
}

@property(nonatomic,retain)NSDictionary *languages;
@property(nonatomic,retain)UITableView *tableView;
@property(nonatomic,retain)NSString *defaultRemindersetting;
@property(nonatomic,retain)Item* userLogin;

- (void)updateUser:(Item*)item;
- (void)switchChange:(UISwitch*)newSwitch;
- (id)initWithUser:(Item*)item;

@end
