//
//  SynchronizedViewController.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 11/21/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "SynchronizedViewController.h"
#import "SyncProcess.h"
#import "ParcelEntityManager.h"
#import "LogItem.h"
#import "LoginRequest.h"
#import "QueryRequest.h"
#import "CreateRecordRequest.h"
#import "AppDelegate.h"
#import "NSObject+SBJson.h"
#import "MainViewController.h"
#import "AttachmentEntitymanager.h"
#import "Reachability.h"

@implementation SynchronizedViewController

@synthesize listLogs,listItems;
@synthesize myTable;
@synthesize status;



-(id)initWithType:(NSString*)type
{
    self = [super init];
    self.title = SYNCHRONIZE;
    self.type = type;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1.0];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 120)];
    headerView.tag = 1;
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    headerView.backgroundColor = [UIColor clearColor];
    
    status = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, frame.size.width, 30)];
    status.font = [UIFont boldSystemFontOfSize:14];
    status.backgroundColor = [UIColor clearColor];
    [headerView addSubview:status];
    [status release];
    
    progress = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 40, frame.size.width-20, 20)];
    progress.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [headerView addSubview:progress];
    [progress release];
    
    percentView = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width-45, 50, 50, 30)];
    percentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    percentView.font = [UIFont boldSystemFontOfSize:14];
    percentView.backgroundColor = [UIColor clearColor];
    [headerView addSubview:percentView];
    [percentView release];
    
    btnSync = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnSync.frame = CGRectMake((frame.size.width/2)-40, 60, 80, 35);
    btnSync.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [btnSync setTitle:START forState:UIControlStateNormal];
    [btnSync addTarget:self action:@selector(syncClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:btnSync];
    
    activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activity.frame = CGRectMake(frame.size.width-80, 50, 50, 50);
    [headerView addSubview:activity];
    [activity release];
    
    [self.view addSubview:headerView];
    [headerView release];
   
    listLogs = [[NSMutableArray alloc] initWithCapacity:1];
    myTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 120, frame.size.width, frame.size.height-140) style:UITableViewStylePlain];
    myTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    myTable.delegate = self;
    myTable.dataSource = self;

//    CGRect myTableFrame = myTable.frame;
//    myTableFrame.origin.y = 120;
//    myTableFrame.size.height = listLogs.count * myTable.rowHeight - 120;
//    myTable.frame = myTableFrame;
    
    [self.view addSubview:myTable];
    [myTable release];
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    self.hud.labelText = CONNECTING_SERVER;
    [self.view addSubview:self.hud];

    if(![self.type isEqualToString:@"normal"]){
        [self startSync];
    }
    
}


- (void)syncClick:(id)sender {
    
    if ([[SyncProcess getInstance] isRunning]) {
        //open alert to confirm
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:CONFIRM_TO_STOP_SYNC
                                                        message:CONFIRM_TO_STOP_SYNC_MESS
                                                       delegate:self cancelButtonTitle:MSG_STOP
                                              otherButtonTitles:MSG_CANCEL, nil];
        [alert show];
        [alert release];
        return;
    }
    
    if([Reachability isNetWorkReachable:YES]){
        [self startSync];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	
    if (buttonIndex == 0) {
        [[SyncProcess getInstance] stop];
	}
    
}

-(void)startSync{
    
    status.text = @"";
    progress.progress = 0;
    percentView.text = @"";
        
    [self.listLogs removeAllObjects];
    [self.myTable reloadData];
    [self.hud show:YES];
    
    [[SyncProcess getInstance] setSyncCon:self];
    [[SyncProcess getInstance] checkSaleForceLogin];
    
}

-(void)connectFail {
    status.text = @"";
    progress.progress = 0;
    percentView.text = @"";
}

-(void)doSync{
    
    [self.hud hide:YES];
    [activity startAnimating];
    
    LogItem *log = [[LogItem alloc] init];
    log.message = SYNC_START;
    log.date = [NSDate date];
    log.type = @"Info";
    [listLogs addObject:log];
    [log release];
    
    [myTable reloadData];
    
}

-(void)refresh{
    
    [self.myTable reloadData];
    
    if ([listLogs count] > 0) {
        LogItem *lastInfo = [listLogs lastObject];
        if(lastInfo){
            status.text = lastInfo.message;
        }
        
        NSIndexPath *ipath = [NSIndexPath indexPathForRow:[self.listLogs count]-1 inSection:0];
        [myTable scrollToRowAtIndexPath:ipath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }

    //percentage calculation
    double percent = [[SyncProcess getInstance] computePercent];
    progress.progress = percent;
    
    percentView.text = [NSString stringWithFormat:@"%d %%", (int)(percent*100)];
    
    if ([[SyncProcess getInstance] isRunning]) {
        
        [btnSync setTitle:MSG_STOP forState:UIControlStateNormal];
        
    } else {
        
        if ([[SyncProcess getInstance].cancelled boolValue]) {
            status.text = STOP_BY_USER;
        } else if ([SyncProcess getInstance].error != nil) {
            if(![SyncProcess getInstance].internetActive){
                [[SyncProcess getInstance] stop];
            }
            
            NSString* causeFail = SYNC_FAIL_CAUSE;
            status.text = [NSString stringWithFormat:@"%@ %@" , causeFail,[SyncProcess getInstance].error];
        } else {
            status.text = SYNC_SUCCEED;
            
        }
        [btnSync setTitle:START forState:UIControlStateNormal];
        [activity stopAnimating];
        
    }
    [myTable reloadData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma UITableView Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return listLogs.count;
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
//    for(UIView *view in cell.contentView.subviews){
//        [view removeFromSuperview];
//    }
    
    LogItem *item = [listLogs objectAtIndex:indexPath.row];
    
    if ([item.type isEqualToString:@"Success"]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = nil;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc]init];
    [formatter2 setDateFormat:@"HH:mm:ss"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", [formatter2 stringFromDate:item.date], item.message];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    [formatter2 release];

    return cell;
    
}

#pragma UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (![[SyncProcess getInstance] isRunning]) {
        LogItem *item = [listLogs objectAtIndex:indexPath.row];
        NSString* info = [[NSString alloc] initWithFormat:@"%@",[item message]];
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:DESCRIPTION message:info delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}
@end
