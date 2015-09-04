//
//  MultiSelectPopup.h
//  CRMiOS
//
//  Created by Arnaud Marguerat on 9/28/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PicklistManager.h"
#import "SelectionListener.h"

@interface MultiSelectPopup : UIViewController<UITableViewDataSource,UITableViewDelegate> {
    Item *item;
    NSString *entity;
    NSString *code;
    BOOL *checked;
    UIPopoverController *popoverController;
    NSArray *values; 
    NSObject <SelectionListener> *listener;
}

@property (nonatomic, retain) Item *item;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) NSArray *values;
@property (nonatomic, retain) NSString *entity;
@property (nonatomic, retain) NSString *code;
@property (readwrite) BOOL *checked;
@property (nonatomic, retain) NSObject <SelectionListener> *listener;

- (id)initWithField:(NSString *)pCode entity:(NSString *)pEntity value:(NSString *)pValue item:(Item *)pItem listener:(NSObject<SelectionListener> *)pListener;
- (void) show:(CGRect)rect parentView:(UIView *)parentView;

@end
