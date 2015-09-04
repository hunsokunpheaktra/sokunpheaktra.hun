//
//  TaskSummaryViewController.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 12/14/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PadListViewController.h"
#import "CustomHeader.h"
#import "EntityManager.h"
#import "NotInCriteria.h"

@interface TaskSummaryViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
    PadListViewController *listVC;
    UITableView *myTable;
    NSArray *group;
    NSArray *headerTitle;
    NSObject <Subtype> *sinfo;
    NSDateFormatter *dateFormater;
    NSString *selectedId;
    UITableViewCell *selectedCell;
}

@property (nonatomic, retain) NSDateFormatter *dateFormater;
@property (nonatomic, retain) NSArray *headerTitle;
@property (nonatomic, retain) NSArray *group;
@property (nonatomic, retain) UITableView *myTable;
@property (nonatomic, retain) PadListViewController *listVC;
@property (nonatomic, retain) NSString *selectedId;
@property (nonatomic, retain) UITableViewCell *selectedCell;

- (id)initWithList:(PadListViewController *)newListVC;
- (NSArray *)getGroup;
- (NSArray *)getOverdue;
- (NSArray *)getToday;
- (NSArray *)getThisWeek;
- (NSArray *)getNextWeek;
- (NSArray *)getFuture;
- (void)reloadData;
- (NSObject<Criteria> *)getCriteria:(NSString *)option;
- (void)selectItem:(NSString *)key;

@end
