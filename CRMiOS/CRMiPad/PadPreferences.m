//
//  PadPreferences.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/25/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "PadPreferences.h"

#import "gadgetAppDelegate.h"



@implementation PadPreferences

@synthesize fields;
@synthesize indicSync;
@synthesize urlLabel;
@synthesize displayFields;
@synthesize btnTest, btnSync;
@synthesize footerView;

- (id)init
{
    self = [super init];
    if (self) {
        self.fields = [NSArray arrayWithObjects:@"URL", @"Login", @"Password", nil];
        self.displayFields = [NSArray arrayWithObjects:NSLocalizedString(@"URL", @"URL"), NSLocalizedString(@"LOGIN", @"Login"), NSLocalizedString(@"PASSWORD", @"Password"), nil];
        self.footerView = nil;
    }
    return self;
}


- (void)loadView {
    self.title = NSLocalizedString(@"PREFERENCES", @"Preferences");
    self.tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setScrollEnabled:NO];
    self.tableView.sectionFooterHeight = 100;
    
    
    [self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ADVANCED", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(showAdvancedPreferences)]autorelease]];
    
    self.urlLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 35, 500, 30)];
    self.urlLabel.backgroundColor = [UIColor clearColor];
    self.urlLabel.font = [UIFont systemFontOfSize:16];
  
    
}


- (void)dealloc
{
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return NSLocalizedString(@"CRM_CREDENTIALS", nil);
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // CH : Add Merge Address Book
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [fields count];
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0 && indexPath.row==0) {
        return 70;
    }
    return 45;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (self.footerView == nil) {
        footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 250, self.view.frame.size.width, 150)];
        footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        footerView.backgroundColor = [UIColor clearColor];
        
        UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(30, 20, 700, 100)];
        buttonView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [footerView addSubview:buttonView];
        
        self.btnTest = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.btnTest.frame = CGRectMake(100, 0, 240, 40);
        [self.btnTest setTitle:NSLocalizedString(@"TEST_CONNECTION", nil) forState:UIControlStateNormal];
        [self.btnTest addTarget:self action:@selector(testConnection:) forControlEvents:UIControlEventTouchUpInside];
        [buttonView addSubview:self.btnTest];
        
        self.btnSync = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.btnSync.frame = CGRectMake(360, 0, 240, 40);
        [self.btnSync setTitle:NSLocalizedString(@"SYNCHRONIZE", nil) forState:UIControlStateNormal];
        [self.btnSync addTarget:self action:@selector(startSync) forControlEvents:UIControlEventTouchUpInside];
        [buttonView addSubview:self.btnSync];
        
        self.indicSync = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.indicSync setFrame:CGRectMake(330, 60, 40, 40)];
        self.indicSync.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [buttonView addSubview:self.indicSync];
    }
    
    return self.footerView;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    // empty the cell contents
    while ([cell.contentView.subviews count] > 0) {
        [[cell.contentView.subviews objectAtIndex:0] removeFromSuperview];
    }
    
    // Credentials
    
    NSString *field = [fields objectAtIndex:indexPath.row];
    NSString *value = [PropertyManager read:field];
    UIView *cellView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 500, 60)];
    
    if ([field isEqualToString:@"URL"]) {
        
        self.urlLabel.text=value;
        value = [value substringWithRange:NSMakeRange(15, 9)];
        
    }
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 5,[field isEqualToString:@"URL"]?495:500, 30)];
    [textField setBorderStyle:UITextBorderStyleRoundedRect];
    [textField setText:value];
    [textField addTarget:self action:@selector(textChange:) forControlEvents:UIControlEventEditingChanged];
    [textField setDelegate:self];
    [textField setSecureTextEntry:[field isEqualToString:@"Password"]];
    [textField setTag:indexPath.row];
    [textField setReturnKeyType:UIReturnKeyDone];
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [textField setPlaceholder:[displayFields objectAtIndex:indexPath.row]];
    
    if ([field isEqualToString:@"URL"]) {
        [cellView addSubview:textField];
        [cellView addSubview:self.urlLabel];
        cell.accessoryView = cellView;
    } else {
        cell.accessoryView = textField;
    }
    [cellView release];
    [textField release];
    
    // Configure the cell...
    cell.textLabel.text = [displayFields objectAtIndex:indexPath.row];
    
    return cell;
}


- (void)textChange:(id)sender {
    UITextField *textField = (UITextField *)sender;
    NSString *property = [fields objectAtIndex:textField.tag];
    NSString *value = textField.text;
    if (textField.tag == 0) {
        if ([textField.text length] > 9) {
            [textField setText:[textField.text substringToIndex:9]];
        }
        value = [NSString stringWithFormat:@"https://secure-%@.crmondemand.com", textField.text];
        self.urlLabel.text = value;
    }
    [PropertyManager save:property value:value];
}


- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	[theTextField resignFirstResponder];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

- (void)refresh {
    
    [self.tableView reloadData];
    
}

- (void)testConnection:(id)sender {
    if ([ValidationTools checkCredentials]) {
        LoginRequest *login = [[LoginRequest alloc] init];
        [login doRequest:self];
        [login release];
    }
    
}

- (void)updateSyncButton:(BOOL)running {
    
    [btnTest setEnabled:!running];
    if (running) {
        [indicSync startAnimating];
    } else {
        [indicSync stopAnimating];
    }
    
}

- (void)showAdvancedPreferences {
    
    PadSyncFiltersView *filter = [[PadSyncFiltersView alloc]init];
    [self.navigationController pushViewController:filter animated:YES];
    [filter release];
    
}

- (void)startSync {
    
    if ([ValidationTools checkCredentials]) {
        gadgetAppDelegate *delegate = (gadgetAppDelegate*)[[UIApplication sharedApplication] delegate];
        UITabBarController *tab = (UITabBarController*)delegate.window.rootViewController;
        SynchronizeViewController *syncview = nil;
        
        for (NamedNavigationController *con in tab.viewControllers){
            if ([con isKindOfClass:[UINavigationController class]]){
                UINavigationController *nav = (UINavigationController*)con;
                if ([nav.topViewController isKindOfClass:[SynchronizeViewController class]]){
                    syncview = (SynchronizeViewController *)nav.topViewController;
                    break;
                }
            }
        }
        
        // when tab synchrinize is in invisible tab (moretab)
        for (UIViewController *viewController in [self.tabBarController.moreNavigationController viewControllers]) {
            if ([viewController isKindOfClass:[SynchronizeViewController class]]) {
                syncview = (SynchronizeViewController *)viewController;
                break;
            }
        }

        if (syncview != nil) {
            
            [tab setSelectedViewController:syncview.navigationController];
            [NSTimer scheduledTimerWithTimeInterval:.06 target:syncview selector:@selector(syncClick) userInfo:nil repeats:NO];
            

        }
    }
}



@end
