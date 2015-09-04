//
//  MyParcelDetailViewController.h
//  Parcel
//
//  Created by Hun Sokunpheaktra on 10/5/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import <MessageUI/MessageUI.h>
#import <QuartzCore/QuartzCore.h>
#import "UpdateListener.h"
#import <QuickLook/QuickLook.h>
#import "BasicPreviewItem.h"

@interface MyParcelDetailViewController : UIViewController<MFMailComposeViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,UpdateListener,UIActionSheetDelegate,QLPreviewControllerDataSource,QLPreviewControllerDelegate>{
    
    Item *currentItem;
    NSArray *sections;
    UITableView *tableView;
}

@property(nonatomic,retain)NSObject<UpdateListener> *updateListener;
@property(nonatomic,retain)Item *currentItem;
@property(nonatomic,retain)UITableView *tableView;
@property(nonatomic,retain)NSString *imageFilePath;

-(id)initWithItem:(Item*)item;
-(void)editItem;

@end
