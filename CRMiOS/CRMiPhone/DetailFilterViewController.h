//
//  DetailFilterViewController.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/25/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PropertyManager.h"
#import "UpdateListener.h"
#import "TabTools.h"

@interface DetailFilterViewController : UITableViewController {
    NSArray *ownerFilters;
    NSArray *dateFilters;
    NSString *entity;
    NSString *ownerFilter;
    NSString *dateFilter;
    NSString *enabled;
    UISwitch *switchBtn;
    BOOL isChange;
    NSObject <UpdateListener> *parent;
}

@property (nonatomic, retain) NSArray *ownerFilters;
@property (nonatomic, retain) NSArray *dateFilters;
@property (nonatomic, retain) NSString *entity;
@property (nonatomic, retain) NSString *ownerFilter;
@property (nonatomic, retain) NSString *dateFilter;
@property (nonatomic, retain) NSString *enabled;
@property (nonatomic, retain) UISwitch *switchBtn;
@property (nonatomic, retain) NSObject <UpdateListener> *parent;

- (id)initWithEntity:(NSString *)newEntity parent:(NSObject <UpdateListener> *)pParent;

@end
