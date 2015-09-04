//
//  4Test.m
//  SyncForce
//
//  Created by Gaeasys on 11/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Preference.h"
#import "FDCServerSwitchboard.h"
#import "GlobalRequest.h"
#import "FilterManager.h"
#import "DetailFilterPopup.h"
#import "ListPopupViewController.h"
#import "DatabaseManager.h"
#import "PropertyManager.h"
#import "FilterObjectViewController.h"
#import "EntityManager.h"
#import "AppDelegate.h"
#import "FilterObjectManager.h"
#import "FilterManager.h"
#import "ValuesCriteria.h"

static NSString *const remoteAccessConsumerKey =@"3MVG9CVKiXR7Ri5rTXLZxJVepcjPdLuBQoKQDuP8kLZL41dwlSW0n4xQbc0yB9VF.TKvTDdaNmEa9nZ_fW5vc";
static NSString *loginHost ;

@implementation Preference

@synthesize arrayData;
@synthesize btnTest;
@synthesize btnReinitDB;


-(id) initWithArray:(NSArray *)tArray{
    self = [super init];
    arrayData = [tArray retain];
    return self;
}

- (void)onSuccess:(int)objectCount request:(NSObject<SFRequest> *)newRequest again:(bool)again{
    
}
- (void)onFailure:(NSString *)errorMessage request:(NSObject<SFRequest> *)newRequest again:(bool)again{
    
}
- (NSObject<SynchronizeViewInterface> *) getSyncController{
    return nil;
}


- (void)dealloc
{
    [super dealloc];
    [btnReinitDB release]; // Latest release
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
    
    
    /*float width;
    UIInterfaceOrientation orient = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(orient)) width = 768;
    else width = 1024;
    [self.navigationController.navigationBar setFrame:CGRectMake(0, 70,width, 50)];*/
    
    
    if ([[PropertyManager read:@"SandBox"] isEqualToString:@"yes"]) {
        loginHost = @"test";
    }else loginHost = @"login";
        
    self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, 200, 200) style:UITableViewStyleGrouped] autorelease];
    
    
    [super viewDidLoad];
}

- (NSString*) getSessionId{
    return nil;
}
- (NSString*) getInstance{
    return nil;
}

- (void)reInitDB {
    // open a alert with an OK and cancel button
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"REINIT_DB_CONFIRM",nil) message:nil
                                                   delegate:self cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:NSLocalizedString(@"CANCEL", nil), nil];
	[alert show];
	[alert release];
    
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
       return 4;
}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {

   if (section == 2) {
        return 80;
    }else if (section == 3) {
        return 200;
    }
    
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
   
        UIView *footerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 100)] autorelease];
        footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        footerView.backgroundColor = [UIColor clearColor];
        
        if (section == 2) {

            self.btnReinitDB = [UIButton buttonWithType:UIButtonTypeCustom];
            
            [btnReinitDB setBackgroundImage:[[UIImage imageNamed:@"delete_button.png"] stretchableImageWithLeftCapWidth:8.0f topCapHeight:0.0f] forState:UIControlStateNormal];
            [btnReinitDB setTitle:NSLocalizedString(@"REINIT_DB", nil) forState:UIControlStateNormal];
            
            [btnReinitDB  setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btnReinitDB.titleLabel.font = [UIFont boldSystemFontOfSize:20];
            btnReinitDB.titleLabel.shadowColor = [UIColor lightGrayColor];
            btnReinitDB.titleLabel.shadowOffset = CGSizeMake(0, -1);
            btnReinitDB.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            [btnReinitDB sizeToFit];
            [btnReinitDB  setFrame:CGRectMake(40, 20, 320, 50)];
            [btnReinitDB  addTarget:self action:@selector(reInitDB) forControlEvents:UIControlEventTouchUpInside];
            
            [footerView addSubview:btnReinitDB];
                        
        }else if(section == 3){
            
            if ([arrayData count]>0) {
                return nil;
            }else {

                footerView.frame = CGRectMake(0, 0, 400, 200);
    
                btnTest = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                [btnTest setTitle:NSLocalizedString(@"RETRIEVE", nil) forState:UIControlStateNormal];
                [btnTest setFrame:CGRectMake(110, 100, 180, 50)];
                btnTest.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                [btnTest addTarget:self action:@selector(testConnection:) forControlEvents:UIControlEventTouchUpInside];
                [footerView addSubview:btnTest];
                
            }   

        }

        return footerView; 
    
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
        
        if (section == 0) {
            return NSLocalizedString(@"ENVIROMENT",nil);
        }
        else if (section == 1) {
            return NSLocalizedString(@"SYNCRONISATION",nil);
        } else if (section == 2) {
            return NSLocalizedString(@"CLIENT_ID",nil);
        }else if(section == 3){
            return [arrayData count] > 0 ? @"Filters" : @"";
        }else if(section == 4){
            return [arrayData count] > 0 ? NSLocalizedString(@"OBJECT_FILTER",@"Object Filter") : @"";
        }
        
        return nil;
   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section >= 3) {
        
         if ([arrayData count]>0) {
             return [arrayData count];
         }else return 0;    
    }else return 1;
}

-(void)viewWillAppear:(BOOL)animated{
   /* UIEdgeInsets inset = UIEdgeInsetsMake(50, 0, 0, 0);
      self.tableView.contentInset = inset;*/
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    
    while ([cell.contentView.subviews count] > 0) {
        [[cell.contentView.subviews objectAtIndex:0] removeFromSuperview];
    }
    Item *tmp;
    BOOL isPort = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = NSLocalizedString(@"HOST",nil); //@"Host" ; 
        if ([[PropertyManager read:@"SandBox"] isEqualToString: @"yes"]) {
            cell.detailTextLabel.text = NSLocalizedString(@"SandBox",nil) ;//@"SandBox";
        }else
            cell.detailTextLabel.text = NSLocalizedString(@"Developer/Production",nil); //@"Developer/Production";
        
    }else if (indexPath.section == 1){
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = NSLocalizedString(@"SYNCRONISATION",nil) ;
        if ([[PropertyManager read:@"ForceSync"] isEqualToString:@"yes"]) {
            cell.detailTextLabel.text = NSLocalizedString(@"ForceSync",nil); //@"ForceSync";
        }else
            cell.detailTextLabel.text = NSLocalizedString(@"MergeRecord",nil) ;//@"MergeRecord";
    
    }else if (indexPath.section == 2) {
         
        cell.textLabel.text = NSLocalizedString(@"CONSUMER_KEY",nil) ;//@"ConsumerKey";

        [cell layoutIfNeeded];
        CGSize textSize = [cell.textLabel.text sizeWithFont:cell.textLabel.font constrainedToSize:CGSizeMake(cell.contentView.bounds.size.width, MAXFLOAT) lineBreakMode:cell.textLabel.lineBreakMode];
        UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(textSize.width , 0, self.tableView.frame.size.width - textSize.width - 120, self.tableView.rowHeight)];
     
        textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        textField.adjustsFontSizeToFitWidth = YES;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.text = remoteAccessConsumerKey;
    
        cell.accessoryView = textField;
        [textField release];

    }else if(indexPath.section == 3){
        
        tmp = [arrayData objectAtIndex:indexPath.row];
        
        UISwitch *tSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(isPort?540:800, 10, 50, 50)];
        tSwitch.tag = indexPath.row;
        [tSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    
        if ([[tmp.fields objectForKey:@"value"] isEqualToString:@"true"] || [[tmp.fields objectForKey:@"value"] isEqualToString:@"yes"] ) {
            tSwitch.on = YES;
        } else {
            tSwitch.on = NO;
        }
        
        cell.accessoryType = tSwitch.on?UITableViewCellAccessoryDetailDisclosureButton:UITableViewCellAccessoryNone;
        
        cell.textLabel.text = [tmp.fields objectForKey:@"label"];
        [cell.contentView addSubview:tSwitch];
        [tSwitch release];

    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 3){
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if(cell.accessoryType == UITableViewCellAccessoryDetailDisclosureButton){
            Item *tmp = [arrayData objectAtIndex:indexPath.row];
            
            FilterObjectViewController *filter = [[FilterObjectViewController alloc] initWithEntity:[tmp.fields objectForKey:@"label"]];
            [self.navigationController pushViewController:filter animated:YES];
            [filter release];
        }
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        
        DetailFilterPopup* detail = [[DetailFilterPopup alloc] initWithData:[[NSArray alloc] initWithObjects:@"Developer/Production",@"SandBox", nil]];
        detail.title =NSLocalizedString(@"ENVIROMENT", nil);
        NSString* valueSelected = [[[self.tableView cellForRowAtIndexPath:indexPath] detailTextLabel] text];
        
        [detail showPopup:[self.tableView cellForRowAtIndexPath:indexPath] parentView:self.view selectedValue:valueSelected parent:self];
        [detail release];
                 
    }else if (indexPath.section == 1) {
    
        DetailFilterPopup* detail = [[DetailFilterPopup alloc] initWithData:[[NSArray alloc] initWithObjects:@"ForceSync",@"MergeRecord", nil]];
        detail.title =NSLocalizedString(@"SYNCRONISATION", nil);
        NSString* valueSelected = [[[self.tableView cellForRowAtIndexPath:indexPath] detailTextLabel ] text];

        [detail showPopup:[self.tableView cellForRowAtIndexPath:indexPath] parentView:self.view selectedValue:valueSelected parent:self];
        [detail release];
    }

}


- (void)switchChanged:(id)sender {
    
    UISwitch *tSwitch = (UISwitch*)sender;
    
    Item *item = [arrayData objectAtIndex:tSwitch.tag];

    if (tSwitch.on) {
        [item.fields setValue:@"yes" forKey:@"value"];  
    }else{
        Item* tmp = [arrayData objectAtIndex:tSwitch.tag];
        if ([[FilterObjectManager list:[tmp.fields objectForKey:@"label"]] count] >0) {
            [FilterObjectManager remove:[tmp.fields objectForKey:@"label"]];
        }
        [item.fields setValue:@"no" forKey:@"value"];  
    }
    [FilterManager update:item modifiedLocally:NO];
    [self.tableView reloadData];
}

- (void)showDateFilter:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    
    DetailFilterPopup* pop = [[DetailFilterPopup alloc] initWithData:[[NSArray alloc] initWithObjects:@"All",@"Last Year",@"Last Month",@"Last Week", nil]];
    
    pop.parentScreen = self;
    pop.valueSelected = [button titleForState:UIControlStateNormal];
    pop.row = button.tag;
    
    [pop show:button parentView:self.view];
    [pop release];
    
}

#pragma mark - database.com login

- (void)hideLogin 
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
    [oAuthViewController release];
}

-(void)popupActionSheet:(NSError *)err 
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[err userInfo] objectForKey:@"faultcode"]
                                                        message:[[err userInfo] objectForKey:@"faultstring"]
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"OK", Nil), nil];
    [alertView show];
    [alertView release]; 
}


- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// use "buttonIndex" to decide your action
	//
    if (buttonIndex == 0) {
        DatabaseManager *db = [DatabaseManager getInstance];
        [db reInitDB];
        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [delegate refreshTabs];
        
	} 
    
    //[self.tableView reloadData];
    [self refresh];
}

- (void)cancelClick{
    btnTest.hidden = NO;
    [self hideLogin];
}

- (void)testConnection:(id)sender {
    
    [[SyncProcess getInstance] startNotifier];
    if(connector) [connector release];
    connector = [FDCServerSwitchboard switchboard];
    [connector setClientId:remoteAccessConsumerKey];
    [connector setApiUrlFromOAuthInstanceUrl:[PropertyManager read:@"InstanceUrl"]];
    [connector setSessionId:[PropertyManager read:@"AccessToken"]];
    [connector setOAuthRefreshToken:[PropertyManager read:@"RefreshToken"]];
    
    [[FDCServerSwitchboard switchboard] getUserInfoWithTarget:self selector:@selector(getUserInfoResult:error:context:) context:nil];
    
}

- (void)login {
    
    if ([[PropertyManager read:@"SandBox"] isEqualToString:@"yes"]) {
        loginHost = @"test";
    }else loginHost = @"login";
    
    self.contentSizeForViewInPopover = CGSizeMake(420.0, 800.0);
    oAuthViewController = [[FDCOAuthViewController alloc] initWithTarget:self selector:@selector(loginOAuth:error:) clientId:remoteAccessConsumerKey loginHost:loginHost];
    
    UIViewController *vc = oAuthViewController;
    
    vc.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                         target:self
                                                                                         action:@selector(cancelClick)] autorelease];
    
    UINavigationController *aNavController = [[UINavigationController alloc] initWithRootViewController:vc];
    
    aNavController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    aNavController.navigationBar.tintColor = [UIColor colorWithRed:(23.0/255.0) green:(155.0/255.0) blue:(192.0/255.0) alpha:1];
    
    oAuthViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self.navigationController presentModalViewController:aNavController animated:YES];
    [aNavController release];
    btnTest.hidden = YES;
}

- (void)loginOAuth:(FDCOAuthViewController *)poAuthViewController error:(NSError *)error
{
    oAuthViewController = poAuthViewController;
    if ([oAuthViewController accessToken] && !error)
    {
        
        [self hideLogin];
        
        NSLog(@"InstanceUrl: %@",[oAuthViewController instanceUrl]);
        NSLog(@"AccessToken: %@",[oAuthViewController accessToken]);
        NSLog(@"RefreshToken: %@",[oAuthViewController refreshToken]);
        
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
   
    NSObject<SFRequest> *globalRequest = [[GlobalRequest alloc] initWithEntity:nil listener:self];
    [globalRequest doRequest];
     
}


- (void)getUserInfoResult:(id)result error:(NSError *)error context:(id)context
{
    
    if (result && !error)
    {
        ZKUserInfo *userinfo = (ZKUserInfo *)result;
        // save the user id in the property manager
        [PropertyManager save:@"CurrentUserId" value:[userinfo userId]];
        
        btnTest.enabled = NO;
        [self startRequest];
       
    }
    else if (error)
    {
        //Check if internet connection reachable
        if(![[SyncProcess getInstance] doAlertInternetFailed]){
            // invoke the login
            [self login];
        }
    }

}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
   // [self.navigationController.navigationBar setFrame:CGRectMake(0, 70,self.view.frame.size.width, 50)];
    [self.tableView reloadData];
}


- (void) syncClick:(id)sender{
    
}
- (void) sendErrorLog{
    
}

- (void) refresh {
    NSArray *array = [FilterManager list:nil]; 
    [self initWithArray:array];
    [self.tableView reloadData];
}



@end
