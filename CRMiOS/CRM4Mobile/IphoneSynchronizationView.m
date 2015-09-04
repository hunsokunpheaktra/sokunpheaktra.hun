//
//  IphoneSynchronizationView.m
//  CRMiOS
//
//  Created by Sy Pauv on 7/12/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "IphoneSynchronizationView.h"


@implementation IphoneSynchronizationView

@synthesize listLog,mytableView,status,percentView,btnSync,indicSync,progress;

#pragma mark - View lifecycle


- (id)init {
    self = [super init];
    listLog = [[NSArray alloc]init];
    UIBarButtonItem *actionBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(syncAction:)];
    [self.navigationItem setRightBarButtonItem:actionBtn];
    
    self.title = NSLocalizedString(@"SYNCHRONIZE", @"synchronize label on iphone synchronize screen.");
    
    return self;
}

- (void)loadView {
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    

    
    UIView *upperView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    [upperView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    upperView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    [mainView addSubview:upperView];
    
    //progress bar
    CGRect frame = CGRectMake(25, 25, 150, 30);
    progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progress.frame = frame;
    progress.progress = 0.0;
    progress.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [upperView addSubview:progress];
    
    //sync status
    self.status = [[UILabel alloc]initWithFrame:CGRectMake(25, 0, 150, 30)];
    [status setFont:[UIFont boldSystemFontOfSize:14]];
    status.backgroundColor = [UIColor clearColor];
    status.textAlignment = UITextAlignmentLeft;
    status.text = @"";
    status.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [upperView addSubview:status];
    
    //percent view
    self.percentView = [[UILabel alloc]initWithFrame:CGRectMake(130, 30, 50, 30)];
    [percentView setFont:[UIFont boldSystemFontOfSize:14]];
    percentView.backgroundColor = [UIColor clearColor];
    percentView.textAlignment = UITextAlignmentRight;
    percentView.text = @"0 %";
    percentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [upperView addSubview:percentView];
    
    //sync button
    btnSync = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnSync setTitle:@"Start" forState:UIControlStateNormal];
    [btnSync setFrame:CGRectMake(65, 50, 70, 40)];
    btnSync.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [btnSync addTarget:self action:@selector(syncClick:) forControlEvents:UIControlEventTouchDown];
    [upperView addSubview:btnSync];
    
    //activity view
    self.indicSync = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.indicSync setFrame:CGRectMake(140, 54, 32, 32)];
    indicSync.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [upperView addSubview:indicSync];
    
    // Create the list
    self.mytableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, 200, 100) style:UITableViewStylePlain];
    self.mytableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.mytableView setDelegate:self];
    [self.mytableView setDataSource:self];

    [mainView addSubview:self.mytableView];
    [self setView:mainView];
    
}


- (void) viewWillAppear:(BOOL)animated {
    [self refresh];
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
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    if ([item.type isEqualToString:@"SUCCESS"]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.detailTextLabel.text = [SyncProcess getLibSuccess:[item.count intValue]];
       
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = nil;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc]init];
    [formatter2 setDateFormat:@"HH:mm:ss"];
    
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", [formatter2 stringFromDate:item.date], item.message];
    
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
        
    ErrorDetailView *viewError=[[ErrorDetailView alloc]initWithLog:item];
    [self.navigationController pushViewController:viewError animated:YES];
    [viewError release];
    
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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

- (void)refresh {
    //read log from table
    listLog = [LogManager list];
    [self.mytableView reloadData];
    
    if ([listLog count] > 0) {
        LogItem *log = [listLog objectAtIndex:[listLog count]-1];
    
        //if ([log.message rangeOfString:@"Succeeded"].length==0 && [log.message rangeOfString:@"Reading"].length>0 ) {
            status.text = log.message;
        //}
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

- (void)syncClick:(id)sender {
    SyncController *controller = [SyncController getInstance];
    if (![[SyncProcess getInstance] isRunning]) {
        if ([ValidationTools checkCredentials]) {
            [[SyncProcess getInstance] start:controller];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"STOP_SYNC_CONFIRM", @"are you sure you want to stop synchronize?") message:nil
                                                       delegate:self cancelButtonTitle:NSLocalizedString(@"STOP", @"stop label") otherButtonTitles:NSLocalizedString(@"CANCEL", @"cancel button"), nil];
        [alert show];
        [alert release];    }

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
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWidth = screenRect.size.width;
    CGRect frame = [self.mytableView frame];
    frame.size.height = UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ? screenHeight - 212 : screenWidth - 200;
    [self.mytableView setFrame:frame];
}

- (void)syncAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"SEND_SYNC_REPORT", @"send sync report")];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"START_FULL_SYNC", @"start full sync")];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"CANCEL", @"Cancel")];
    [actionSheet setCancelButtonIndex:2];
    [actionSheet showInView:self.view.superview]; 
    [actionSheet release];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        ErrorReport *report = [[ErrorReport alloc] initWithController:self];
        [report sendErrorReport];
	} else if (buttonIndex == 1) {
        //save metadata change
        [PropertyManager save:@"LOVLastUpdated" value:@""];
        [PropertyManager save:@"syncPicklist" value:@"YES"];
        [LastSyncManager clear];
        [self syncClick:self];
    }

    
    
}

@end
