//
//  SublistEditVC.h
//  CRMiOS
//
//  Created by Arnaud Marguerat on 8/27/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "Configuration.h"
#import "UITools.h"
#import "EditCell.h"
#import "SelectionPopup.h"
#import "CreationListener.h"
#import "RelatedPopup.h"

#import "DatePopup.h"
#import "EntityManager.h"
#import "UpdateListener.h"
#import "ValidationTools.h"

#import <Foundation/Foundation.h>

@interface SublistEditVC : UITableViewController <SelectionListener, UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate> {

    SublistItem *workDetail;
    SublistItem *detail;
    NSObject <UpdateListener, CreationListener> *updateListener;
    BOOL isCreate;
    NSMutableArray *fields;
    Item *parentItem;
    
}

@property (nonatomic, retain) UIButton  *chooseimage;
@property (nonatomic, retain) SublistItem *detail;
@property (nonatomic, retain) SublistItem *workDetail;
@property (nonatomic, retain) NSObject <UpdateListener, CreationListener> *updateListener;
@property (readwrite) BOOL isCreate;
@property (nonatomic, retain) NSMutableArray *fields;
@property (nonatomic, retain) Item *parentItem;

- (id)initWithDetail:(SublistItem *)newDetail parentItem:(Item *)parentItem updateListener:(NSObject <UpdateListener, CreationListener> *)newUpdateListener isCreate:(BOOL)newIsCreate;
- (void)cancel;
- (void)changeText:(id)sender;
- (void)deleteConfirm:(id)sender;
- (void)checkboxchange:(id)sender;
- (NSString *)getSublistCode;

@end

