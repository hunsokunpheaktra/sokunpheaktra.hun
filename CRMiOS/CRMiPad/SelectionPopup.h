//
//  SelectionPopup.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/12/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PicklistManager.h"
#import "Configuration.h"
#import "SelectionListener.h"
#import "IndustryManager.h"
#import "SalesStageManager.h"
#import "FieldsManager.h"
#import "FilterManager.h"
#import "PicklistManager.h"

@interface SelectionPopup : UIViewController<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate> {
    Item *item;
    NSString *entity;
    NSString *code;
    NSString *value;
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
@property (nonatomic, retain) NSString *value;
@property (nonatomic, retain) NSObject <SelectionListener> *listener;

- (id)initWithField:(NSString *)code entity:(NSString *)entity value:(NSString *)value item:(Item *)item listener:(NSObject <SelectionListener> *)listener;
- (void) show:(CGRect)rect parentView:(UIView *)parentView;
- (void) filterData:(NSString *)filterText;

@end
