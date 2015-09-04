//
//  CRMiPadAppDelegate.m
//  CRMiPad
//
//  Created by Sy Pauv Phou on 3/29/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "gadgetAppDelegate.h"


@implementation gadgetAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize facebook;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    isbackground = [NSNumber numberWithBool:NO];
    //google tracker
    [GoogleTracker startTrack];
    [TestFlight takeOff:@"571e4b6a-b194-4ec2-810a-962fab30c186"];
    
    Database *db = [Database getInstance];
    [db initDatabase];
    
    if (!db.exists) {
        AlertViewTool *alert = [[[AlertViewTool alloc] initWithDatabase:db parentView:self.window tabLayout:self] autorelease];
        [alert loadEncryptedDatabase];
    } else if(![EncryptedDatabase canQuery:db.database]) {
        AlertViewTool *alert = [[[AlertViewTool alloc] initWithDatabase:db parentView:self.window tabLayout:self] autorelease];
        [alert loadOpenDatabase];
    } else {
        [self initLayout];
    }
    
    facebook = [[Facebook alloc] initWithAppId:FB_appId andDelegate:nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    //apprater
    [Appirater appLaunched];
    [self.window makeKeyAndVisible];
    
    
    //**Push notify**//
    //Init Airship launch options
    NSMutableDictionary *takeOffOptions = [[[NSMutableDictionary alloc] init] autorelease];
    [takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
    
    // Create Airship singleton that's used to talk to Urban Airship servers.
    // Please replace these with your info from http://go.urbanairship.com
    [UAirship takeOff:takeOffOptions];
    
    
    //Init the UI
    //sample UI implementation
    
    [UAInbox useCustomUI:[UAInboxUI class]];
    [UAInboxUI shared].inboxParentController = [self getPrefTab];
    [UAInboxPushHandler handleLaunchOptions:launchOptions];
    if (([[UIApplication sharedApplication] applicationIconBadgeNumber])>0) {
        //reset app icon's badge
        [[UAPush shared] resetBadge];
        if ([[UAInbox shared].pushHandler hasLaunchMessage]) {
            [UAInboxUI loadLaunchMessage];
        }else{
            [self selectFeedTab];
        }
    }
    
    // Register for notifications
    [[UIApplication sharedApplication]registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound |UIRemoteNotificationTypeAlert)];
    

    
    //auto sync background on specifictime set in andvance setting
    [self runScheduleTimer];
    
    return YES;
}

/*
** do synchronize
** created date 21/05/2013
*/
-(void)doSync{
    PadSyncController *controller = [PadSyncController getInstance];
    [[SyncProcess getInstance] start:controller];
}

/*
** schedule run sync background in specific time
** created date 21/05/2013
*/
- (void)runScheduleTimer{
    NSTimeInterval interval = [PropertyManager getAutoSyncTime];
    if(interval != 0){
        _timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(doSync) userInfo:nil repeats:YES];
        [_timer fire]; // fire it right now
    }
}

/*
 ** cancel schedule run sync background
 ** created date 21/05/2013
 */
- (void)abortScheduleTimer{
    if(_timer){
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [UAirship land];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@ & userId =%@", deviceToken,[[CurrentUserManager read] objectForKey:@"UserId"]);
    [[UAPush shared] registerDeviceToken:deviceToken];
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    //reset app icon's badge
    [[UAPush shared] resetBadge];
    [UAInboxPushHandler handleLaunchOptions:userInfo];
    [[UAInboxMessageList shared] retrieveMessageList];
    NSString *uamid=[userInfo objectForKey:@"_uamid"] ;
    
    if (![isbackground boolValue]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:uamid==nil?@"New Feed!":@"New Message!" message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
        [alert release];
        SoundTool *sound=[[SoundTool alloc]initWithPath:@"Voicemail.wav"];
        [sound play];
    }
    isbackground =[NSNumber numberWithBool:NO];
    
    //check if received notify is rich push or simple push
    //if uamid !=nil mean that the notify is rich push message
    if (uamid!=nil) {
        [self getPrefTab].tabBarItem.badgeValue=@"1";
        [UAInboxUI loadLaunchMessage];
    }else{
        [self selectFeedTab];
    }
}

- (UIViewController *)getPrefTab{
    for(UIViewController *con in self.tabBarController.viewControllers){
        if([con isKindOfClass:[UINavigationController class]]){
            UINavigationController *nav = (UINavigationController*)con;
            if([nav.topViewController isKindOfClass:[PadPreferences class]]){
                return nav.topViewController;
            }
        }
    }
    return nil;
}

- (void)selectFeedTab{
    for(UIViewController *con in self.tabBarController.viewControllers){
        if([con isKindOfClass:[UINavigationController class]]){
            UINavigationController *nav = (UINavigationController*)con;
            if([nav.topViewController isKindOfClass:[FeedsViewController class]]){
                [((FeedsViewController *)nav.topViewController) refreshFeed];
                nav.topViewController.tabBarItem.badgeValue=@"1";
                [self.tabBarController setSelectedViewController:nav];
            }
        }
    }
}

- (void)initLayout {
    
    [DBTools initManagers];
    self.tabBarController = [[UITabBarController alloc] init];
    [PadTabTools buildTabs:self.tabBarController];
    self.tabBarController.delegate = self;
    self.window.rootViewController = self.tabBarController;
    //    self.tabBarController.moreNavigationController.navigationBar.tintColor=[UITools readHexColorCode:[Configuration headerColor:@"headerColor"]];
    [PadSyncController getInstance].mainController = self.tabBarController;
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    isbackground=[NSNumber numberWithBool:YES];
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    
    viewController.tabBarItem.badgeValue=nil;
    
}


- (void)tabBarController:(UITabBarController *)tabBarController willEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
    if (changed) {
        // Bug #818
        // We must pop the view controllers, else we are stuck in detail mode
        for (UIViewController *controller in self.tabBarController.viewControllers) {
            if ([controller isKindOfClass:[UINavigationController class]]) {
                NSLog(@"%@",controller);
                [((UINavigationController *)controller) popToRootViewControllerAnimated:NO];
            }
        }
        // save new layout
        NSMutableArray *tabs = [[NSMutableArray alloc] initWithCapacity:1];
        for (NamedNavigationController *controller in tabBarController.viewControllers) {
            [tabs addObject:controller.name];
        }
        [TabManager saveTabs:tabs];
    }
}


- (void)dealloc
{
    [[GANTracker sharedTracker] stopTracker];
    [_window release];
    [_timer invalidate];
    [_timer release];
    [super dealloc];
}


// Pre iOS 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    return [facebook handleOpenURL:url];
    
}


// For iOS 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    return [facebook handleOpenURL:url];
}



@end
