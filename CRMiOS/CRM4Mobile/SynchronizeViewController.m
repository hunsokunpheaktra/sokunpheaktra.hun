//
//  SynchronizeViewController.m
//  CRMiOS
//
//  Created by Sy Pauv on 7/7/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "SynchronizeViewController.h"

@implementation SynchronizeViewController

@synthesize mytableView, listLog, progress, indicSync, btnSync, percentView, status, btnAction;

#pragma mark - View lifecycle

- (id)init {
    self = [super init];
    
    self.title = NSLocalizedString(@"SYNCHRONIZE", @"synchronization label on sync tab");
    return self;
}

- (void)loadView
{
    listLog = [[NSArray alloc] init];
    
    UIView *mainscreen = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 400, 400)];
    mainscreen.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    self.btnAction = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet)];
    [self.navigationItem setRightBarButtonItem:btnAction];
    
    CGRect frame = CGRectMake(50, 50, mainscreen.frame.size.width-100, 30);
    progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progress.frame = frame;
    progress.progress = 0.0;
    progress.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [mainscreen addSubview:progress];
    
    self.status = [[UILabel alloc]initWithFrame:CGRectMake(50, 20, mainscreen.frame.size.width-100, 30)];
    [status setFont:[UIFont boldSystemFontOfSize:16]];
    status.backgroundColor = [UIColor clearColor];
    status.textAlignment = UITextAlignmentLeft;
    status.text = @"";
    status.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [mainscreen addSubview:status];
    
    self.percentView = [[UILabel alloc]initWithFrame:CGRectMake(50, 60, mainscreen.frame.size.width-100, 30)];
    [percentView setFont:[UIFont boldSystemFontOfSize:16]];
    percentView.backgroundColor = [UIColor clearColor];
    percentView.textAlignment = UITextAlignmentRight;
    percentView.text = @"0 %";
    percentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [mainscreen addSubview:percentView];
    
    
    btnSync = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnSync setTitle:NSLocalizedString(@"START", @"Start button title") forState:UIControlStateNormal];
    [btnSync setFrame:CGRectMake(progress.center.x-50, 80, 100, 50)];
    btnSync.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [btnSync addTarget:self action:@selector(syncClick) forControlEvents:UIControlEventTouchDown];
    [mainscreen addSubview:btnSync];
    
    
    self.indicSync = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.indicSync setFrame:CGRectMake(progress.center.x + 100, 80, 50, 50)];
    indicSync.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [mainscreen addSubview:indicSync];
    
    // Create the list
    self.mytableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 150, mainscreen.frame.size.width, 250) style:UITableViewStylePlain];
    self.mytableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.mytableView setDelegate:self];
    [self.mytableView setDataSource:self];
    [mainscreen addSubview:self.mytableView];
    
    [self setView:mainscreen];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // make sure the navigation bar is visible
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    gadgetAppDelegate* appDelegate = (gadgetAppDelegate*)[UIApplication sharedApplication].delegate;
    if (appDelegate.tabBarController.selectedIndex >= 7) {
        UIView *view = appDelegate.tabBarController.moreNavigationController.topViewController.view;
        if ([view isKindOfClass:[UITableView class]]) {
            [((UITableView *)view) reloadData];
        }
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.listLog count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    LogItem *item = [listLog objectAtIndex:indexPath.row];
    
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    if ([item.type isEqualToString:@"SUCCESS"]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.detailTextLabel.text = [SyncProcess getLibSuccess:[item.count intValue]];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = nil;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"HH:mm:ss"];
    
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", [formatter2 stringFromDate:item.date], item.message];
    
    [formatter2 release];
    
    if ([item.type isEqualToString:@"ERROR"]) {
        cell.imageView.image = [UIImage imageNamed:@"log-error.png"];
    } else if ([item.type isEqualToString:@"WARNING"]) {
        cell.imageView.image = [UIImage imageNamed:@"log-warning.png"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"log-info.png"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LogItem *item = [listLog objectAtIndex:indexPath.row];
    
    PopupErrorDetailView *popupError = [[PopupErrorDetailView alloc]initWithLog:item];
    [popupError show:[tableView cellForRowAtIndexPath:indexPath].frame parentView:self.mytableView];
    [popupError release];
}

- (void)dealloc
{
    [mytableView release];
    [listLog release];
    [progress release];
    [indicSync release];
    [btnSync release];
    [percentView release];
    [status release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)refresh {
    //read log from table
    [listLog release];
    listLog = nil;
    listLog = [LogManager list];
    [self.mytableView reloadData];
    
    if ([listLog count] > 0) {
        LogItem *lastInfo = nil;
        for (LogItem *logItem in listLog) {
            if ([logItem.type isEqualToString:@"INFO"]) {
                lastInfo = logItem;
            }
        }
        if (lastInfo != nil) {
            status.text = lastInfo.message;
        }
        
        NSIndexPath* ipath = [NSIndexPath indexPathForRow: [self.listLog count]-1 inSection: 0];
        [self.mytableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
    }
    
    //percentage calculation
    double percent = [[SyncProcess getInstance] computePercent];
    [progress setProgress: percent];
    percentView.text = [NSString stringWithFormat:@"%d %%", (int)(percent*100)];
    
    if ([[SyncProcess getInstance] isRunning]) {
        
        [btnSync setTitle:NSLocalizedString(@"STOP", @"Stop button title") forState:UIControlStateNormal];
        [indicSync startAnimating];
        
    } else {
        
        if ([[SyncProcess getInstance].cancelled boolValue]) {
            status.text = NSLocalizedString(@"SYNC_STOP", @"");//@"Synchonization stopped by user.";
        } else if ([SyncProcess getInstance].error != nil) {
            status.text = NSLocalizedString(@"SYNC_FAILED", @"");//@"Synchonization failed.";
        } else {
            status.text = NSLocalizedString(@"SYNC_SUCCESS", @"");//@"Synchonization succeeded.";
        }
        [btnSync setTitle:NSLocalizedString(@"START", @"start button title") forState:UIControlStateNormal];
        [indicSync stopAnimating];
        
    }
    
}

- (void)syncClick {
    PadSyncController *controller = [PadSyncController getInstance];
    if (![[SyncProcess getInstance] isRunning]) {
        if ([ValidationTools checkCredentials]) {
            [[SyncProcess getInstance] start:controller];
        }
    } else {
        //open alert to confirm 
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"STOP_SYNC_CONFIRM", @"are you sure you want to stop synchronize?") message:nil
                                                       delegate:self cancelButtonTitle:NSLocalizedString(@"STOP", @"stop label") otherButtonTitles:NSLocalizedString(@"CANCEL", @"cancel button"), nil];
        [alert show];
        [alert release];
        
    }
    
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// use "buttonIndex" to decide your action
	//
    if (buttonIndex == 0) {
        [[SyncProcess getInstance] stop];  
	} 
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    CGRect frame = [self.mytableView frame];
    frame.size.height = UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ? 750 : 500;
    [self.mytableView setFrame:frame];
}

- (void)sendErrorLog {
    
    ErrorReport *report = [[ErrorReport alloc] initWithController:self];
    [report sendErrorReport];
    
}

- (void)showActionSheet {

    if ([actionsheet isVisible]) {
        return;
    } else {
        if (actionsheet!=nil) {
            [actionsheet release];
        }
    }
    actionsheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"SEND_SYNC_REPORT", nil), NSLocalizedString(@"START_FULL_SYNC", nil), nil];
    [actionsheet setDelegate:self];
    [actionsheet showFromBarButtonItem:self.btnAction animated:YES];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
   	
    switch (buttonIndex) {
        case 0:
            [self sendErrorLog];
            break;
        case 1:
            //save metadata change
            [PropertyManager save:@"LOVLastUpdated" value:@""];
            [PropertyManager save:@"syncPicklist" value:@"YES"];
            [LastSyncManager clear];
            [self syncClick];
            break;
        default:
            break;
    }
    
}


@end
