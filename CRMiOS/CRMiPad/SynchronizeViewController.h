//
//  SynchronizeViewController.h
//  CRMiOS
//
//  Created by Sy Pauv on 7/7/11.
//  Copyright 2011 Gaeasys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogManager.h"
#import "SyncInterface.h"
#import "SyncProcess.h"
#import "PadSyncController.h"

@interface SynchronizeViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,SyncInterface> {
    
    UILabel *percentView;
    UILabel *status;
    NSArray *listLog;
    UIButton *btnSync;
    UITableView *mytableView;
    UIProgressView *progress;
    UIActivityIndicatorView *indicSync;
    
}
@property(nonatomic , retain) UILabel *status;
@property(nonatomic , retain) UILabel *percentView;
@property(nonatomic , retain) UIButton *btnSync;
@property(nonatomic , retain) UIActivityIndicatorView *indicSync;
@property(nonatomic , retain) UIProgressView *progress;
@property(nonatomic , retain) UITableView *mytableView;
@property(nonatomic , retain) NSArray *listLog;

- (void)syncClick:(id)sender;


@end
