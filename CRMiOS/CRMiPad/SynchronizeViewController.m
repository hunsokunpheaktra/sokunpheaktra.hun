//
//  SynchronizeViewController.m
//  CRMiOS
//
//  Created by Sy Pauv on 7/7/11.
//  Copyright 2011 Gaeasys. All rights reserved.
//

#import "SynchronizeViewController.h"

@implementation SynchronizeViewController
@synthesize mytableView,listLog,progress,indicSync,btnSync,percentView,status;

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    listLog=[[NSArray alloc]init];
    
    UIView *mainscreen=[[UIView alloc]initWithFrame: [[UIScreen mainScreen] bounds]];
    mainscreen.backgroundColor=[UIColor clearColor];
    
    self.title=@"Synchronize";
    
    CGRect frame = CGRectMake(50, 50, mainscreen.frame.size.width-100, 30);
    progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progress.frame=frame;
    progress.progress = 0.0;
    progress.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [mainscreen addSubview:progress];
    
    self.status=[[UILabel alloc]initWithFrame:CGRectMake(50, 20, mainscreen.frame.size.width-100, 30)];
    [status setFont:[UIFont boldSystemFontOfSize:16]];
    status.backgroundColor=[UIColor clearColor];
    status.textAlignment = UITextAlignmentLeft;
    status.text=@"";
    status.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [mainscreen addSubview:status];
    
    self.percentView=[[UILabel alloc]initWithFrame:CGRectMake(50, 60, mainscreen.frame.size.width-100, 30)];
    [percentView setFont:[UIFont boldSystemFontOfSize:16]];
    percentView.backgroundColor=[UIColor clearColor];
    percentView.textAlignment = UITextAlignmentRight;
    percentView.text=@"0 %";
    percentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [mainscreen addSubview:percentView];
    
    
     btnSync = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnSync setTitle:@"Start" forState:UIControlStateNormal];
    [btnSync setFrame:CGRectMake(progress.center.x-50, 80, 100, 50)];
     btnSync.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [btnSync addTarget:self action:@selector(syncClick:) forControlEvents:UIControlEventTouchDown];
    [mainscreen addSubview:btnSync];
    
    
    self.indicSync = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.indicSync setFrame:CGRectMake(progress.center.x + 100, 80, 50, 50)];
    indicSync.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [mainscreen addSubview:indicSync];
    
    // Create the list
    self.mytableView = [[UITableView alloc] initWithFrame:CGRectMake(0,150,mainscreen.frame.size.width, 500) style:UITableViewStylePlain];
    self.mytableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.mytableView setDelegate:self];
    [self.mytableView setDataSource:self];
    [mainscreen addSubview:self.mytableView];
    
    [self setView:mainscreen];
    
    [super viewDidLoad];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGRect frame = [self.mytableView frame];
    frame.size.height = UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ? 750 : 500;
    [self.mytableView setFrame:frame];
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
    
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *item=[listLog objectAtIndex:indexPath.row];
    
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *fullDate=[formatter1 dateFromString:[item objectForKey:@"date"]];
    
    NSDateFormatter *formatter2=[[NSDateFormatter alloc]init];
    [formatter2 setDateFormat:@"HH:mm:ss"];
    
    
    cell.textLabel.text = [formatter2 stringFromDate:fullDate];
    
    
    cell.detailTextLabel.text = [item objectForKey:@"log"];
  
    if ([[item objectForKey:@"log"]rangeOfString:@"Error"].length > 0) {
        
        cell.imageView.image = [UIImage imageNamed:@"error.png"];
    
    }else{
        cell.imageView.image = [UIImage imageNamed:@"about.png"];
    }
    return cell;
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

- (void) refresh {
    //read log from table
    listLog=[LogManager read];
    [self.mytableView reloadData];
    
    NSString *log=[[listLog objectAtIndex:[listLog count]-1] objectForKey:@"log"];
    if ([log rangeOfString:@"Sending request for"].length>0 ) {
            status.text=log;
    }
    NSIndexPath* ipath = [NSIndexPath indexPathForRow: [self.listLog count]-1 inSection: 0];
    [self.mytableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
    
    //percentage calculation
    double percent=[[SyncProcess getInstance]getPercent];
    [progress setProgress: percent];
    percentView.text=[NSString stringWithFormat:@"%d %%",(int)(progress.progress*100)];
    
    if ([[SyncProcess getInstance] isRunning]) {
        
        [btnSync setTitle:@"Stop" forState:UIControlStateNormal];
        [indicSync startAnimating];
    
    } else {

        status.text=@"Synchonization Finished.";
        [btnSync setTitle:@"Start" forState:UIControlStateNormal];
        [indicSync stopAnimating];
    
    }
   
}
- (void)syncClick:(id)sender {
    UIButton *button=(UIButton *)sender;
    PadSyncController *controller = [PadSyncController getInstance];
    if ([button.titleLabel.text isEqualToString:@"Start"]) {
    
        [[SyncProcess getInstance] start:controller];    

    }else{

        [[SyncProcess getInstance] stop];    
        
    }
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    CGRect frame = [self.mytableView frame];
    frame.size.height = UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ? 750 : 500;
    [self.mytableView setFrame:frame];
}

@end
