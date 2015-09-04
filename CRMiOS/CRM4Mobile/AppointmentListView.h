//
//  AppointmentListView.h
//  CRMiOS
//
//  Created by Sy Pauv on 12/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Configuration.h"
#import "DetailViewController.h"
#import "UpdateListener.h"

@interface AppointmentListView : UIViewController<UITableViewDataSource,UITableViewDelegate,UpdateListener> {
    
    NSArray *listItems;
    UITableView *mytable;
    NSDictionary *criterias;

}
@property (nonatomic ,retain)    NSDictionary *criterias;
@property (nonatomic ,retain)  NSArray *listItems;
@property (nonatomic ,retain) UITableView *mytable;
- (id)initwithCriteria:(NSDictionary *)criteria;
- (void)reloadData;


@end
