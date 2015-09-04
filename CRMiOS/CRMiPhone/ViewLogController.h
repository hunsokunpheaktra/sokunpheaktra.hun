//
//  ViewLogController.h
//  CRMiOS
//
//  Created by Sy Pauv on 5/17/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogManager.h"


@interface ViewLogController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
    
    UITableView *myTableView;
    NSMutableArray *listLog;
    
}
@property (nonatomic,retain) NSMutableArray *listLog;
@property (nonatomic,retain) UITableView *myTableView;

@end
