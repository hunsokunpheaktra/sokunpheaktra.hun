//
//  SynchronizeViewController.m
//  kba
//
//  Created by Sy Pauv on 10/3/11.
//  Copyright 2011 GAEASYS. All rights reserved.
//

#import "SynchronizeViewController.h"
#import "LogManager.h"
#import "FDCServerSwitchboard.h"
#import "ZKSforce.h"
#import "ZKLoginResult.h"
#import "ZKUserInfo.h"
#import "EntityManager.h"
#import "EntityInfoManager.h"
#import "DirectoryHelper.h"
#import "NotInCriteria.h"



// Fill these in when creating a new Remote Access client on Force.com 
// nefosdev@kba.com.dev hisy1234
//static NSString *const remoteAccessConsumerKey = @"3MVG94DzwlYDSHS5GBR9bax4Tgra5RUXaEZ0mfxqrfHljNmT2OCflh689euLbLn9q78uX8umsfnX7NqD1Ej4w";
//static NSString *loginHost = @"test";
//static NSString *const OAuthRedirectURI = @"sfdc://success";
//static NSString *const OAuthLoginDomain = @"test.salesforce.com.";

// Fill these in when creating a new Remote Access client on Force.com 
// znithchhun@gmail.com Computer1 
static NSString *const remoteAccessConsumerKey = @"3MVG9CVKiXR7Ri5rTXLZxJVepcjPdLuBQoKQDuP8kLZL41dwlSW0n4xQbc0yB9VF.TKvTDdaNmEa9nZ_fW5vc";
//static NSString *loginHost = @"login";
//static NSString *const OAuthRedirectURI = @"sfdc://success";
//static NSString *const OAuthLoginDomain = @"login.salesforce.com.";


// Fill these in when creating a new Remote Access client on Force.com 
// sy@ignity.com hello123 
//static NSString *const remoteAccessConsumerKey = @"3MVG9QDx8IX8nP5RSa4zJFCEYfclddmq8odEBO0KVksLxYqeQ1P2MJ3Djtn..NIg1GriaOspya_En6RlINC1X";
static NSString *loginHost ;// = @"test";
//static NSString *const OAuthRedirectURI = @"sfdc://success";
//static NSString *const OAuthLoginDomain = @"login.salesforce.com.";


@implementation SynchronizeViewController


@synthesize mytableView, listLog, progress, indicSync, btnSync, percentView, status;
@synthesize listrecods,parentView;

#pragma mark - View lifecycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.


- (void)viewDidLoad
{
      
    if ([[PropertyManager read:@"SandBox"] isEqualToString:@"yes"]) loginHost = @"test";
    else loginHost = @"login";
    
    NSString *deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPhone"] || [deviceType isEqualToString:@"iPod"])
        isIphone = NO;
    else 
        isIphone = YES;
    
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:parentView action:@selector(returnToParentView)];
    [self.navigationItem setLeftBarButtonItem:backButton];
    
    listLog = [[NSArray alloc] init];
    
    UIView *mainscreen = [[UIView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    mainscreen.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    self.title = @"Synchronize";//NSLocalizedString(@"SYNCHRONIZE", @"synchronization label on sync tab");
    
    progress = [[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault] autorelease];
    progress.frame = CGRectMake(25, isIphone?45:50, mainscreen.frame.size.width-50, 30);
    progress.progress = 0.0;
    progress.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [mainscreen addSubview:progress];
    
    self.status = [[[UILabel alloc] initWithFrame:CGRectMake(25, isIphone?15:70, mainscreen.frame.size.width-50, 30)] autorelease];
    [status setFont:[UIFont boldSystemFontOfSize:isIphone?15:16]];
    status.backgroundColor = [UIColor clearColor];
    status.textAlignment = UITextAlignmentLeft;
    status.text = @"";
    status.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [mainscreen addSubview:status];
    
    self.percentView = [[[UILabel alloc] initWithFrame:CGRectMake(75, isIphone?50:60, mainscreen.frame.size.width-100, 30)] autorelease];
    [percentView setFont:[UIFont boldSystemFontOfSize:isIphone?15:16]];
    percentView.backgroundColor = [UIColor clearColor];
    percentView.textAlignment = UITextAlignmentRight;
    percentView.text = @"0 %";
    percentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [mainscreen addSubview:percentView];
    
    btnSync = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnSync setTitle:NSLocalizedString(@"START", @"Start button title") forState:UIControlStateNormal];
    btnSync.titleLabel.font = [UIFont boldSystemFontOfSize:isIphone?14:15];
    [btnSync setFrame:CGRectMake(progress.center.x-50, isIphone?75:80, 100,40)];
    btnSync.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [btnSync addTarget:self action:@selector(syncClick:) forControlEvents:UIControlEventTouchDown];
    [mainscreen addSubview:btnSync];
    
    self.indicSync = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    [self.indicSync setFrame:CGRectMake(progress.center.x + 85, 70, 50, 50)];
    indicSync.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [mainscreen addSubview:indicSync];
    
    // Create the list
    self.mytableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 130, mainscreen.frame.size.width, mainscreen.frame.size.height-120) style:UITableViewStylePlain] autorelease];
    self.mytableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mytableView.delegate = self;
    self.mytableView.dataSource = self;
    self.mytableView.rowHeight = isIphone?35:44;
    
    [mainscreen addSubview:self.mytableView];
    
    self.view = mainscreen;
    [mainscreen release];
    
    [super viewDidLoad];
    
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
    cell.textLabel.font = [UIFont boldSystemFontOfSize:isIphone?15:16];
    
    if ([item.type isEqualToString:@"Error"]) {
        cell.imageView.image = [UIImage imageNamed:@"log-error.png"];
    } else if ([item.type isEqualToString:@"Warning"]) {
        cell.imageView.image = [UIImage imageNamed:@"log-warning.png"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"log-info.png"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![[SyncProcess getInstance] isRunning]) {
        LogItem *item = [listLog objectAtIndex:indexPath.row];
        NSString* info = [[NSString alloc] initWithFormat:@"%@",[item message]];
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"DESCRIPTION", Nil) message:info delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}


#pragma mark - database.com login

- (void)hideLogin 
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
    [oAuthViewController autorelease];
}

-(void)popupActionSheet:(NSError *)err 
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[err.userInfo objectForKey:@"faultcode"]
                                                        message:[err.userInfo objectForKey:@"faultstring"]
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"OK", Nil), nil];
    [alertView show];
    [alertView release];
}


- (void)login {
    
    self.contentSizeForViewInPopover = CGSizeMake(420.0, 800.0);
    oAuthViewController = [[FDCOAuthViewController alloc] initWithTarget:self selector:@selector(loginOAuth:error:) clientId:remoteAccessConsumerKey loginHost:loginHost];

    UIViewController *vc = oAuthViewController;
    
    vc.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self  action:@selector(hideLogin)] autorelease];
    
    UINavigationController *aNavController = [[UINavigationController alloc] initWithRootViewController:vc];
    
    aNavController.modalPresentationStyle = UIModalPresentationFormSheet;
    aNavController.navigationBar.tintColor = [UIColor colorWithRed:(23.0/255.0) green:(155.0/255.0) blue:(192.0/255.0) alpha:1];
    
    oAuthViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self.navigationController presentModalViewController:aNavController animated:YES];
    [aNavController release];
    
}
- (void) startSync{

    [[SyncProcess getInstance].syncList removeAllObjects];
    if (![[SyncProcess getInstance] isRunning]) {
        [[SyncProcess getInstance] start:self];
    }
}

- (void)syncClick:(id)sender {
    if ([[SyncProcess getInstance] isRunning]) {
        //open alert to confirm 
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"CONFIRM_TO_STOP_SYNC", Nil)                           
                                                        message:nil
                                                       delegate:self cancelButtonTitle:NSLocalizedString(@"STOP", Nil) 
                                              otherButtonTitles:NSLocalizedString(@"CANCEL", Nil), nil];
        [alert show];
        [alert release];
        return;
    }
    
//    if([[FilterManager list:nil] count] == 0){
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Synchronize Warning" message:@"Synchronize can not start because user and password not detach !" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
//        [alert release];
//    }else{

        [[SyncProcess getInstance] startNotifier];

        connector = [FDCServerSwitchboard switchboard];
        [connector setClientId:remoteAccessConsumerKey];
        [connector setApiUrlFromOAuthInstanceUrl:[PropertyManager read:@"InstanceUrl"]];
        [connector setSessionId:[PropertyManager read:@"AccessToken"]];
        [connector setOAuthRefreshToken:[PropertyManager read:@"RefreshToken"]];
    
        [[FDCServerSwitchboard switchboard] getUserInfoWithTarget:self selector:@selector(getUserInfoResult:error:context:) context:nil];
  //  }
}


- (void)loginOAuth:(FDCOAuthViewController *)poAuthViewController error:(NSError *)error
{
    oAuthViewController = poAuthViewController;
    if ([oAuthViewController accessToken] && !error)
    {
        
        [self hideLogin];
        
        [PropertyManager save:@"InstanceUrl" value:[oAuthViewController instanceUrl]];
        [PropertyManager save:@"AccessToken" value:[oAuthViewController accessToken]];
        [PropertyManager save:@"RefreshToken" value:[oAuthViewController refreshToken]];
        
        [connector setApiUrlFromOAuthInstanceUrl:[oAuthViewController instanceUrl]];
        [connector setSessionId:[oAuthViewController accessToken]];
        [connector setOAuthRefreshToken:[oAuthViewController refreshToken]];
        
        [connector getUserInfoWithTarget:self selector:@selector(getUserInfoResult:error:context:) context:nil];
        NSLog(@"SessionId << %@ >>", [oAuthViewController accessToken]);
        NSLog(@"InstanceUrl << %@ >>", [oAuthViewController instanceUrl]);
    }else{
        NSLog(@"loginOAuth: %@ error: %@", oAuthViewController, error);
        [self popupActionSheet:error];
    }
    
}

-(void)receivedErrorFromAPICall:(NSError *)err 
{
	[self popupActionSheet:err];
}

- (void)getUserInfoResult:(id)result error:(NSError *)error context:(id)context
{
    NSLog(@"getUserInfoResult: %@ error: %@ context: %@", result, error, context);
   
    if (result && !error)
    {
        ZKUserInfo *userinfo = (ZKUserInfo *)result;
        // save the user id in the property manager
        [PropertyManager save:@"CurrentUserId" value:[userinfo userId]];
        [self startSync];
        NSLog(@"UserId << %@ >>", [userinfo userId]);
    }else if (error){
        
        //Check if internet connection reachable
        if(![[SyncProcess getInstance] doAlertInternetFailed]){
            // invoke the login
            [self login];
        }
    }
    
}

- (void)dealloc
{
    [toolbarButtons release];
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
    listLog = [LogManager list];
    [self.mytableView reloadData];
    
    NSLog(@"Size log : %d", [listLog count]);
    if ([listLog count] > 0) {
        LogItem *lastInfo = nil;
        for (LogItem *logItem in listLog) {
            if ([logItem.type isEqualToString:@"Info"]) {
                lastInfo = logItem;
            }
        }
        if (lastInfo != nil) {
            status.text = lastInfo.message;
        }
        
        NSIndexPath* ipath = [NSIndexPath indexPathForRow: [self.listLog count]-1 inSection: 0];
        [self.mytableView scrollToRowAtIndexPath:ipath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    //percentage calculation
    double percent = [[SyncProcess getInstance] computePercent];
    [progress setProgress: percent];
    percentView.text = [NSString stringWithFormat:@"%d %%", (int)(percent*100)];
    
    if ([[SyncProcess getInstance] isRunning]) {
        
        [btnSync setTitle:NSLocalizedString(@"STOP", Nil) forState:UIControlStateNormal];
        [indicSync startAnimating];
        
    } else {
        
        if ([[SyncProcess getInstance].cancelled boolValue]) {
            status.text = @"Synchonization stopped by user.";
        } else if ([SyncProcess getInstance].error != nil) {
            if(![SyncProcess getInstance].internetActive){
                [[SyncProcess getInstance] stop];
            }
            status.text = [NSString stringWithFormat:@"Synchonization failed caused by %@" , [SyncProcess getInstance].error];
        } else {
            status.text = @"Synchonization succeeded.";;
        }
        [btnSync setTitle:NSLocalizedString(@"START", Nil) forState:UIControlStateNormal];
        [indicSync stopAnimating];
        
    }
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        [[SyncProcess getInstance] stop];  
	} 
}

- (NSString*) getSessionId{
    return [oAuthViewController accessToken];
}

- (NSString*) getInstance{
    return [NSString stringWithFormat:@"%@", [oAuthViewController instanceUrl]];
}

- (void)sendErrorLog{}



- (void) mergeViewOpen :(MainMergeRecord*)screen{
    //[self.navigationController pushViewController:screen animated:YES];
}


@end
