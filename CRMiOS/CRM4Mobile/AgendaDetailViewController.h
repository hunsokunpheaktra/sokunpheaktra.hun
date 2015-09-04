//
//  AgendaDetailViewController.h
//  CRMiOS
//
//  Created by Sy Pauv on 12/9/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Item.h"
#import "UpdateListener.h"
#import "Section.h"
#import "LayoutPageManager.h"
#import "PictureManager.h"

#import "gadgetAppDelegate.h"

@interface AgendaDetailViewController : UITableViewController<UpdateListener> {

    Item *account;
    Item *contact;
    Item *appointment;
    UIImageView *contactPicture;
    UILabel *contactNameLabel;
    UILabel *phoneNo;
    UILabel *email;
}

@property (nonatomic, retain) Item *appointment;
@property (nonatomic, retain) UILabel *email;
@property (nonatomic, retain) UILabel *phoneNo;
@property (nonatomic, retain) UILabel *contactNameLabel;
@property (nonatomic, retain) UIImageView *contactPicture;
@property (nonatomic, retain) Item *account;
@property (nonatomic, retain) Item *contact;

-(id)initWithItem:(Item *)newItem;
-(Item *)getAccount;
-(Item *)getContact;

@end
