//
//  AppDelegate.m
//  Parcel
//
//  Created by Davin Pen on 10/2/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "AppDelegate.h"

#import "DBTools.h"
#import "MainViewController.h"
#import "ParcelEntityManager.h"
#import "ParcelItem.h"

#import "UserManager.h"
#import "MainViewController.h"
#import "AppDelegate.h"
#import "NewParcelViewController.h"
#import "MyParcelDetailViewController.h"
#import "ProviderManager.h"
#import "MyParcelViewController.h"
#import "SynchronizedViewController.h"

@implementation AppDelegate

@synthesize facebook,deviceTokenData;

- (void)dealloc
{
    [_window release];
    [login release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [DBTools initManagers];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    
    login = [[LoginViewController alloc] init];
    
    facebook = [[Facebook alloc] initWithAppId:FB_appId andDelegate:login];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:login];
    self.window.rootViewController = nav;
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    const char* data = [deviceToken bytes];
    NSMutableString* token = [NSMutableString string];
    
    for (int i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    self.deviceTokenData = [[token copy] autorelease];
    
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    SoundTool *sound=[[SoundTool alloc]initWithPath:@"Voicemail.wav"] ;
    [sound play];
    [sound release];
    
    [AJNotificationView showNoticeInView:self.window
                                    type:AJNotificationTypeOrange
                                   title:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
                         linedBackground:AJLinedBackgroundTypeAnimated
                               hideAfter:4
                                response:^{
                                    
                                }
     ];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
// Pre iOS 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    return [facebook handleOpenURL:url];
    
}


// For iOS 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if([url.absoluteString rangeOfString:@"parcel://"].length > 0){
    
        if(!self.handleOpenPage){
            self.handleOpenPage = [[NSMutableDictionary alloc] initWithCapacity:1];
        }
        [self.handleOpenPage removeAllObjects];
        
        NSLog(@"Launched with URL: %@", url.absoluteString);
        [self urlPathToDictionary:url.absoluteString];
        
        UIApplicationState state = [UIApplication sharedApplication].applicationState;
        if(state == UIApplicationStateBackground || state == UIApplicationStateInactive){
            [self openURLPage];
        }
    }
    
    return [facebook handleOpenURL:url];
    
}

- (void) openURLPage{
    
    Item* user = [MainViewController getInstance].user;
    if(!user) return;
    
    if(self.handleOpenPage.count > 0){
        
        [MainViewController getInstance].selectedIndex = 0;
        
        NSString *page = [self.handleOpenPage objectForKey:@"page"];
        NSMutableDictionary *fields = [self.handleOpenPage objectForKey:@"fields"];
        
        if([page isEqualToString:@"addParcel"]){
            
            NSDictionary *attachments = [NSDictionary dictionaryWithDictionary:[fields objectForKey:@"attachments"]];
            
            Item *item = [[[Item alloc] init:@"Parcel" fields:fields] autorelease];
            for (NSString *key in attachments.allKeys) {
                
                Item *att = [[[Item alloc] init:@"Attachment" fields:[attachments objectForKey:key]] autorelease];
                [item.attachments setObject:att forKey:key];
                
            }
            
            NSMutableDictionary* criterias = [[NSMutableDictionary alloc] init];
            [criterias setValue:[[[ValuesCriteria alloc] initWithString:[user.fields valueForKey:@"email"]] autorelease] forKey:@"user_email"];
            [criterias setValue:[[[ValuesCriteria alloc] initWithString:[item.fields objectForKey:@"trackingNo"]] autorelease] forKey:@"trackingNo"];
            [criterias setValue:[[[ValuesCriteria alloc] initWithString:@"0"] autorelease] forKey:@"deleted"];
            
            NSArray *itemsExisted = [ParcelEntityManager list:@"Parcel" criterias:criterias];
            [criterias release];
            
            if(itemsExisted.count > 0){
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:TRACKING_DUPLICATED
                    message:TRACKING_DUPLICATED_MESSAGE delegate:self cancelButtonTitle:MSG_YES otherButtonTitles:MSG_NO,nil];
                alert.tag = 1;
                [alert show];
                [alert release];
                
            }else{
            
                [item.fields setValue:[user.fields valueForKey:@"email"] forKey:@"user_email"];
                [item.fields setValue:@"2" forKey:@"modified"];
                [item.fields setValue:@"0" forKey:@"deleted"];
                [item.fields setValue:@"0" forKey:@"error"];
                [item.fields removeObjectForKey:@"local_id"];
                [item.fields removeObjectForKey:@"attachments"];
                
                NewParcelViewController *new = [[NewParcelViewController alloc] initWithItem:item];
                UINavigationController *nav = (UINavigationController*)[MainViewController getInstance].selectedViewController;
                [nav pushViewController:new animated:NO];
                [new save];
                
                [self.handleOpenPage removeAllObjects];
            }
            
        }
        
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    Item* user = [MainViewController getInstance].user;
    
    NSMutableDictionary *fields = [self.handleOpenPage objectForKey:@"fields"];
    NSDictionary *attachments = [NSDictionary dictionaryWithDictionary:[fields objectForKey:@"attachments"]];
    Item *item = [[[Item alloc] init:@"Parcel" fields:fields] autorelease];
    
    [item.fields setValue:[user.fields valueForKey:@"email"] forKey:@"user_email"];
    [item.fields setValue:@"2" forKey:@"modified"];
    [item.fields setValue:@"0" forKey:@"deleted"];
    [item.fields setValue:@"0" forKey:@"error"];
    [item.fields removeObjectForKey:@"local_id"];
    [item.fields removeObjectForKey:@"attachments"];
    
    for (NSString *key in attachments.allKeys) {
        
        Item *att = [[[Item alloc] init:@"Attachment" fields:[attachments objectForKey:key]] autorelease];
        [item.attachments setObject:att forKey:key];
        
    }
    
    NSMutableDictionary* criterias = [[NSMutableDictionary alloc] init];
    [criterias setValue:[[[ValuesCriteria alloc] initWithString:[user.fields valueForKey:@"email"]] autorelease] forKey:@"user_email"];
    [criterias setValue:[[[ValuesCriteria alloc] initWithString:[item.fields objectForKey:@"trackingNo"]] autorelease] forKey:@"trackingNo"];
    [criterias setValue:[[[ValuesCriteria alloc] initWithString:@"0"] autorelease] forKey:@"deleted"];
    
    NSArray *itemsExisted = [ParcelEntityManager list:@"Parcel" criterias:criterias];
    [criterias release];
    
    if(itemsExisted.count > 0 && buttonIndex == 0){
    
        NewParcelViewController *new = [[NewParcelViewController alloc] initWithItem:item];
        UINavigationController *nav = (UINavigationController*)[MainViewController getInstance].selectedViewController;
        [nav pushViewController:new animated:NO];
        [new save];
        
    }
    
    [self.handleOpenPage removeAllObjects];

}

-(void)urlPathToDictionary:(NSString *)path
{
    path = [path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //Get the string everything after the :// of the URL.
    NSString *stringNoPrefix = [[path componentsSeparatedByString:@"://"] lastObject];
    //Get all the parts of the url
    
    if([stringNoPrefix rangeOfString:@"/"].length > 0){
        
        NSString *page = [stringNoPrefix substringToIndex:[stringNoPrefix rangeOfString:@"/"].location];
        NSString *fieldsData = [stringNoPrefix substringFromIndex:[stringNoPrefix rangeOfString:@"/"].location+1];
        
        [self.handleOpenPage setObject:page forKey:@"page"];
        
        SBJSON *parser = [[SBJSON alloc] init];
        // parse the JSON string into an object - assuming json_string is a NSString of JSON data
        NSMutableDictionary *jsonData = [parser objectWithString:fieldsData error:nil];
        [parser release];
        [self.handleOpenPage setObject:jsonData forKey:@"fields"];
        
    }else{
        
        [self.handleOpenPage setObject:stringNoPrefix forKey:@"page"];
        
    }
    
}



@end
