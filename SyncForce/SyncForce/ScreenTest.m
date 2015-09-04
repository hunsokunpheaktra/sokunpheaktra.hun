//
//  4Test.m
//  SyncForce
//
//  Created by Gaeasys on 11/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScreenTest.h"
#import "FDCServerSwitchboard.h"
#import "GlobalRequest.h"
#import "FilterManager.h"



static NSString *const remoteAccessConsumerKey = @"3MVG9QDx8IX8nP5RSa4zJFCEYfclddmq8odEBO0KVksLxYqeQ1P2MJ3Djtn..NIg1GriaOspya_En6RlINC1X";
static NSString *loginHost = @"login";


@implementation ScreenTest

@synthesize arrayData;
@synthesize btnTest;

-(id) initWithArray:(NSArray *)tArray{
    
    arrayData = tArray;
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

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 200, 200) style:UITableViewStyleGrouped];
    [self.tableView setAllowsSelection:NO];
    [super viewDidLoad];
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
    return 2;
    
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    self.tableView.sectionFooterHeight = 50;
    UIView *footerView = Nil;
    
    if (footerView == nil) {
        footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 100)];
        footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        footerView.backgroundColor = [UIColor clearColor];
        if (section == 0) {
            self.btnTest = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [btnTest setTitle:NSLocalizedString(@"Connect", nil) forState:UIControlStateNormal];
            [btnTest setFrame:CGRectMake(110, 0, 180, 50)];
            btnTest.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            [btnTest addTarget:self action:@selector(testConnection:) forControlEvents:UIControlEventTouchDown];
            [footerView addSubview:btnTest];
            return footerView;
        } 
    }
    return nil;  
}


-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

        if (section == 0) {
            return @"Login";
        } else if (section == 1) {
            return @"Objects";
        }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
   
    if (section == 0) {
        return 0;
    }else
        return [arrayData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...    
    Item *tmp = [arrayData objectAtIndex:indexPath.row];
    UISwitch *tSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(150, 10, 50, 50)];

    if ([[tmp.fields objectForKey:@"value"] isEqualToString:@"true"] || [[tmp.fields objectForKey:@"value"] isEqualToString:@"yes"]){
        tSwitch.on = YES;
    } else {
        tSwitch.on = NO;
    }

    cell.textLabel.text = [tmp.fields objectForKey:@"label"];
    cell.accessoryView = tSwitch;
        
    return cell;
}



#pragma mark - database.com login

- (void)hideLogin 
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
    [oAuthViewController autorelease];
}

-(void)popupActionSheet:(NSError *)err 
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[err userInfo] objectForKey:@"faultcode"]
                                                        message:[[err userInfo] objectForKey:@"faultstring"]
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"OK", Nil), nil];
    [alertView show];
    [alertView autorelease];
}

- (void)testConnection:(id)sender {

    [[SyncProcess getInstance] startNotifier];
    
    connector = [FDCServerSwitchboard switchboard];
    [connector setClientId:remoteAccessConsumerKey];
    [connector setApiUrlFromOAuthInstanceUrl:[PropertyManager read:@"InstanceUrl"]];
    [connector setSessionId:[PropertyManager read:@"AccessToken"]];
    [connector setOAuthRefreshToken:[PropertyManager read:@"RefreshToken"]];
    
    [[FDCServerSwitchboard switchboard] getUserInfoWithTarget:self selector:@selector(getUserInfoResult:error:context:) context:nil];
    
}

- (void)login {
    self.contentSizeForViewInPopover = CGSizeMake(420.0, 800.0);
    oAuthViewController = [[FDCOAuthViewController alloc] initWithTarget:self selector:@selector(loginOAuth:error:) clientId:remoteAccessConsumerKey loginHost:loginHost];
    oAuthViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentModalViewController:oAuthViewController animated:YES];
}

- (void)loginOAuth:(FDCOAuthViewController *)poAuthViewController error:(NSError *)error
{
    oAuthViewController = poAuthViewController;
    if ([oAuthViewController accessToken] && !error){
        
        [self hideLogin];
        
        [PropertyManager save:@"InstanceUrl" value:[oAuthViewController instanceUrl]];
        [PropertyManager save:@"AccessToken" value:[oAuthViewController accessToken]];
        [PropertyManager save:@"RefreshToken" value:[oAuthViewController refreshToken]];
        
        [connector setApiUrlFromOAuthInstanceUrl:[oAuthViewController instanceUrl]];
        [connector setSessionId:[oAuthViewController accessToken]];
        [connector setOAuthRefreshToken:[oAuthViewController refreshToken]];
        
        [connector getUserInfoWithTarget:self selector:@selector(getUserInfoResult:error:context:) context:nil];
     
    }else{
        [self popupActionSheet:error];
    }
    
    
}

- (void) startRequest{
    
    NSArray *array = [FilterManager list:nil]; 
    [self initWithArray:array];    
    [self.tableView reloadData];
    
}

- (void)getUserInfoResult:(id)result error:(NSError *)error context:(id)context
{
    
    if (result && !error){
        ZKUserInfo *userinfo = (ZKUserInfo *)result;
        // save the user id in the property manager
        [PropertyManager save:@"CurrentUserId" value:[userinfo userId]];
        
        [self startRequest];
       
    }else if (error){
        //Check if internet connection reachable
        if(![[SyncProcess getInstance] doAlertInternetFailed]){
            // invoke the login
            [self login];
        }
    }

}

@end
