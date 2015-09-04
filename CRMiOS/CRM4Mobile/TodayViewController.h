//
//  TodayViewController.h
//  CRMiOS
//
//  Created by Sy Pauv on 6/17/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntityInfo.h"
#import "Configuration.h"
#import "DetailViewController.h"


@interface TodayViewController : UITableViewController {
    
    NSMutableArray *listActivity;
    NSMutableArray *listContact;
    
}

@property (nonatomic,retain) NSMutableArray *listActivity;
@property (nonatomic,retain) NSMutableArray *listContact;
- (id)init;
- (void)refreshList;


@end
