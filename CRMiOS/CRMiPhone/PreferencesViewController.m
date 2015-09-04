//
//  PreferencesController.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/22/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "PreferencesViewController.h"

//#import "UAirship.h"
//#import "UAInbox.h"
//#import "UAInboxMessageListController.h"
//#import "UAInboxMessageViewController.h"
//#import "UAInboxNavUI.h"
//#import "UAInboxUI.h"

@implementation PreferencesViewController

@synthesize urlLabel;
@synthesize btnTest;
@synthesize fields;
@synthesize indicSync;
@synthesize displayFields;
@synthesize btnSync;

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
        UIView *mainfooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 300, 40)];
        self.btnTest = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.btnTest setTitle:NSLocalizedString(@"TEST_BUTTON", nil) forState:UIControlStateNormal];
        self.btnTest.titleLabel.shadowOffset = CGSizeMake(0, -1);
        [self.btnTest setFrame:CGRectMake(0,0, 100, 40)];
        //
        [self.btnTest addTarget:self action:@selector(testConnection) forControlEvents:UIControlEventTouchDown];
        
        self.btnSync = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnSync.frame = CGRectMake(105, 0, 150, 40);
        [btnSync setTitle:NSLocalizedString(@"SYNCHRONIZE", nil) forState:UIControlStateNormal];
        btnSync.titleLabel.shadowOffset = CGSizeMake(0, -1);
        [btnSync addTarget:self action:@selector(startSync) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:btnSync];
        
        [footerView addSubview:self.btnTest];
        footerView.center=mainfooter.center;
        footerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        indicSync = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [indicSync setFrame:CGRectMake(260, 0, 40, 40)];
        [footerView addSubview:indicSync];
        [mainfooter addSubview:footerView];
        
        [self.tableView setTableFooterView:mainfooter];
        [self.tableView setSectionHeaderHeight:8];
        [self.tableView setSectionFooterHeight:8];
        
        
        UIBarButtonItem *filterBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ADVANCED", @"advance button label") style:UIBarButtonItemStyleBordered target:self action:@selector(goFilters)];
        [self.navigationItem setRightBarButtonItem:filterBtn animated:NO];
        
        self.title = NSLocalizedString(@"PREFERENCES", "preferences label");
        self.fields = [NSArray arrayWithObjects:@"URL", @"Login", @"Password", Nil];
        self.displayFields = [NSArray arrayWithObjects:NSLocalizedString(@"URL", @"URL"), NSLocalizedString(@"LOGIN", @"Login"), NSLocalizedString(@"PASSWORD", @"Password"), nil];

        
        
        //self.navigationItem.leftBarButtonItem 
        //= [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"18-envelope-white.png"] style:UIBarButtonItemStylePlain target:self action:@selector(viewinbox)] autorelease];
        
        // For UINavigationController UI
        // [UAInboxNavUI shared].popoverButton = self.navigationItem.leftBarButtonItem;

        
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (IBAction)viewLog:(id)sender{
    
    ViewLogController *logView = [[ViewLogController alloc]init];
    [self.navigationController pushViewController:logView animated:YES];
    [logView release];
    
}

- (void)updateSyncButton:(BOOL)running {
 
    btnTest.enabled = !running;
    self.btnSync.enabled=!running;
    if (running) {
        [indicSync startAnimating];
    } else {
        [indicSync stopAnimating];
    }

}


- (void)testConnection {
    if ([ValidationTools checkCredentials]) {
        LoginRequest *login = [[LoginRequest alloc]init];
        [login doRequest:self];
        [login release];
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {	
	[theTextField resignFirstResponder];
	return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [fields count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [displayFields objectAtIndex:section];
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        if (self.urlLabel == Nil) {
            self.urlLabel = [[UILabel alloc] init];
            [self.urlLabel setBackgroundColor:[UIColor clearColor]];
            [self.urlLabel setTextAlignment:UITextAlignmentCenter];
            [self.urlLabel setFont:[UIFont systemFontOfSize:14]];
            [self.urlLabel setText:[PropertyManager read:@"URL"]];
        }
        return self.urlLabel;
    } else {
        return Nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 30;
    } else {
        return 0;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier1 = @"Cell1";
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier1] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    // empty the cell contents
    while ([cell.contentView.subviews count] > 0) {
        [[cell.contentView.subviews objectAtIndex:0] removeFromSuperview];
    }
    
    NSString *field = [fields objectAtIndex:indexPath.section];
    NSString *value = [PropertyManager read:field];
    CGRect bounds = [cell.contentView bounds];
    CGRect rect = CGRectInset(bounds, 9.0, 9.0);
    UITextField *textField = [[UITextField alloc] initWithFrame:rect];
    textField.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    //  Set the keyboard's return key label to 'Next'.
    //
    [textField setSecureTextEntry:[field isEqualToString:@"Password"]];
    [textField setReturnKeyType:UIReturnKeyDone];
    [textField setDelegate:self];
    [textField addTarget:self action:@selector(changeText:) forControlEvents:UIControlEventEditingChanged];
    
    //  Make the clear button appear automatically.
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    
    [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [textField setPlaceholder:[displayFields objectAtIndex:indexPath.section]];
    [textField setTag:indexPath.section];
    if (indexPath.section == 0) {
        value = [value substringWithRange:NSMakeRange(15, 9)];
    }
    [textField setText:value];
    
    [cell.contentView addSubview:textField];
    [textField release];
    return cell;
}

- (void)changeText:(id)sender {
    UITextField *textField = (UITextField *)sender;
    NSString *value = textField.text;
    if (textField.tag == 0) {
        if ([textField.text length] > 9) {
            [textField setText:[textField.text substringToIndex:9]];
        }
        value = [NSString stringWithFormat:@"https://secure-%@.crmondemand.com", value];
        [self.urlLabel setText:value];
    }
    [PropertyManager save:[fields objectAtIndex:textField.tag] value:value];
}

- (void)goFilters {
    AdvancedPreferencesVC *filtersController = [[AdvancedPreferencesVC alloc] initWithPreference:self];
    [[self navigationController] pushViewController:filtersController animated:YES];
    [filtersController release];
}

- (void)mustUpdate{
    [self.tableView reloadData];
}


//- (void)viewinbox{
//    [UAInbox displayInbox:self.navigationController animated:YES];  
//}

- (void)startSync {
    if ([ValidationTools checkCredentials]) {
        CRMAppDelegate *delegate = (CRMAppDelegate *)[[UIApplication sharedApplication] delegate];
        UITabBarController *tab = (UITabBarController*)delegate.window.rootViewController;
        IphoneSynchronizationView *syncview;
        
        for(UIViewController *con in tab.viewControllers){
            if([con isKindOfClass:[UINavigationController class]]){
                UINavigationController *nav = (UINavigationController*)con;
                if([nav.topViewController isKindOfClass:[IphoneSynchronizationView class]]){
                    syncview = (IphoneSynchronizationView*)nav.topViewController;
                    break;
                }
            }
        }
        [tab setSelectedViewController:syncview.navigationController];
        [NSTimer scheduledTimerWithTimeInterval:.06 target:syncview selector:@selector(syncClick:) userInfo:nil repeats:NO];
    }
    
}

@end
