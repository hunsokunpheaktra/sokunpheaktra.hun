//
//  IphoneSynchronizationView.h
//  CRMiOS
//
//  Created by Sy Pauv on 7/12/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SyncController.h"
#import "LogItem.h"
#import "ErrorDetailView.h"

@interface IphoneSynchronizationView : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UIActionSheetDelegate> {
    
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
- (void)refresh;
- (void)syncAction:(id)sender;

@end
