//
//  SettingDetailViewController.h
//  Parcel
//
//  Created by Hun Sokunpheaktra on 10/26/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateListener.h"
#import "Item.h"
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD.h"

@interface SettingDetailViewController : UITableViewController<MFMailComposeViewControllerDelegate>{
    NSArray *listItems;
    NSArray *listIcons;
    NSString *selectValue;
    NSString *fieldName;
    NSObject<UpdateListener> *updateListener;
}

-(id)initWithListItems:(NSArray*)items icons:(NSArray*)icons fieldName:(NSString*)fName value:(NSString*)val listener:(NSObject<UpdateListener>*)listener;
-(void)done;

@end
