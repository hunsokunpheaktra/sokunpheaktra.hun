//
//  SynchronizedViewController.h
//  Parcel
//
//  Created by Hun Sokunpheaktra on 11/21/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SyncListener.h"
#import "SalesforceAPIRequest.h"
#import "MBProgressHUD.h"
#import "SalesforceAPIRequest.h"
#import "GetAttachmentBody.h"

@interface SynchronizedViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>{
    
    UITableView *myTable;
    UIActivityIndicatorView *activity;
    NSMutableArray *listLogs;
    NSMutableArray *listItems;
    
    UILabel *status;
    UILabel *percentView;
    UIButton *btnSync;
    UIProgressView *progress;
    
}

@property (nonatomic,retain) MBProgressHUD *hud;
@property (nonatomic,retain) UILabel *status;
@property (nonatomic,retain) UITableView *myTable;
@property (nonatomic,retain) NSMutableArray *listLogs;
@property (nonatomic,retain) NSMutableArray *listItems;
@property (nonatomic,retain) NSString *type;

-(id)initWithType:(NSString*)type;

-(void)startSync;
-(void)connectFail;
-(void)doSync;
//-(void)registerUser;
//-(void)registerDeviceToken;
//-(void)checkDeviceToken;
-(void)refresh;

@end
