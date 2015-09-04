//
//  CRMAppDelegate.m
//  CRM
//
//  Created by MACBOOK on 3/28/11.
//  Copyright 2011 __Fellow Consulting AG__. All rights reserved.


#import "CRMAppDelegate.h"
#import "UAirship.h"
#import "UAPush.h"
#import "UAInboxPushHandler.h"
#import "UAInboxUI.h"
#import "UAInbox.h"
#import "UAInboxMessageList.h"


@implementation CRMAppDelegate

@synthesize tabBarController;
@synthesize window,facebook;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    isbackground=[NSNumber numberWithBool:NO];
    
    //google tracker
    [GoogleTracker startTrack];
    [TestFlight takeOff:@"571e4b6a-b194-4ec2-810a-962fab30c186"];
    
    Database *db = [Database getInstance];
    [db initDatabase];
    
    if (!db.exists) {
        AlertViewTool *alert = [[AlertViewTool alloc] initWithDatabase:db parentView:self.window tabLayout:self];
        [alert loadEncryptedDatabase];
    } else if (![EncryptedDatabase canQuery:db.database]) {
        AlertViewTool *alert = [[AlertViewTool alloc] initWithDatabase:db parentView:self.window tabLayout:self];
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
    

    //**Push notify**//
    //Init Airship launch options
    NSMutableDictionary *takeOffOptions = [[[NSMutableDictionary alloc] init] autorelease];
    [takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
    
    // Create Airship singleton that's used to talk to Urban Airship servers.
    // Please replace these with your info from http://go.urbanairship.com
    [UAirship takeOff:takeOffOptions];
    
    
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

    //apprater
    [Appirater appLaunched];
    [self.window makeKeyAndVisible];
    
    //auto sync background on specifictime set in andvance setting
    [self runScheduleTimer];
    
    return YES;
}

 
- (void)initLayout{
    
    [DBTools initManagers];
    
    UIApplication* myApp = [UIApplication sharedApplication];
    myApp.idleTimerDisabled = YES;
    
    self.tabBarController = [[UITabBarController alloc] init];
    [TabTools buildTabs:self.tabBarController];

    self.tabBarController.delegate = self;
    window.rootViewController = self.tabBarController;
    [SyncController getInstance].mainController = self.tabBarController;
    
}

- (void)tabBarController:(UITabBarController *)tabBarController willEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
    if (changed) {
        // Bug #818
        // We must pop the view controllers, else we are stuck in detail mode
        for (UIViewController *controller in self.tabBarController.viewControllers) {
            if ([controller isKindOfClass:[UINavigationController class]]) {
                [((UINavigationController *)controller) popToRootViewControllerAnimated:NO];
            }
        }
        // save new layout
        NSMutableArray *tabs = [[NSMutableArray alloc] initWithCapacity:1];
        for (NamedNavigationController *controller in self.tabBarController.viewControllers) {
            [tabs addObject:[controller name]];
        }
        [TabManager saveTabs:tabs];
        [tabs release];
    }
}

-(void)dealloc {
    
    [[GANTracker sharedTracker] stopTracker];
    [window release];
    [super dealloc];
    
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

- (void)applicationDidEnterBackground:(UIApplication *)application{
    isbackground=[NSNumber numberWithBool:YES];
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

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{

    //when select on tab item clear badge
    viewController.tabBarItem.badgeValue=nil;
    
}

- (UIViewController *)getPrefTab {
    for(UIViewController *con in self.tabBarController.viewControllers){
        if([con isKindOfClass:[UINavigationController class]]){
            UINavigationController *nav = (UINavigationController*)con;
            if([nav.topViewController isKindOfClass:[PreferencesViewController class]]){
                return nav.topViewController;
            }
        }
    }
    return nil;
}

- (void)selectFeedTab {
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

// Pre iOS 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [facebook handleOpenURL:url];
}


// For iOS 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [facebook handleOpenURL:url];
}


/*
 ** do synchronize
 ** created date 21/05/2013
 */
-(void)doSync{
    SyncController *controller = [SyncController getInstance];
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

@end

