//
//  ListViewController1.h
//  CRM
//
//  Created by MACBOOK on 4/8/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntityInfo.h"
#import "Configuration.h"
#import "EntityManager.h"
#import "LikeCriteria.h"
#import "ContainsCriteria.h"
#import "OrCriteria.h"
#import "DetailViewController.h"
#import "SyncProcess.h"
#import "SyncController.h"
#import "DetailViewController.h"
#import "Group.h"
#import "GroupManager.h"
#import "EditingViewController.h"
#import "ValuesCriteria.h"
#import <iAd/iAD.h>

@interface ListViewController : UIViewController<UpdateListener, UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate> {

	NSString *entity;
    NSString *subtype;
	NSArray *groups;
    UINavigationBar *navBar;
    UIBarButtonItem *syncIndic;
    UIBarButtonItem *addBtn;
    UITableView *tableView;
    
}


@property(nonatomic, retain) UIBarButtonItem *syncIndic;
@property(nonatomic, retain) NSArray *groups;
@property(nonatomic, retain) NSString *entity;
@property(nonatomic, retain) NSString *subtype;
@property(nonatomic, retain) UIBarButtonItem *addBtn;
@property(nonatomic, retain) UITableView *tableView;

- (id)initWithEntity:(NSString *)newEntity subtype:(NSString *)subtype;
- (void)refreshList:(NSString *)search scope:(NSString *)scope;
- (IBAction)addNew:(id)sender;

@end
