//
//  SyncForceAppDelegate.m
//  SyncForce
//
//  Created by Gaeasys Admin on 10/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "DatabaseManager.h"
#import "EntityManager.h"
#import "PropertyManager.h"
#import "LogManager.h"
#import "DirectoryHelper.h"
#import "FieldInfoManager.h"
#import "EntityInfoManager.h"
#import "TransactionInfoManager.h"
#import "SynchronizeViewInterface.h"
#import "SynchronizeViewController.h"
#import "EditLayoutSectionsInfoManager.h"
#import "DetailLayoutSectionsInfoManager.h"
#import "PicklistInfoManager.h"
#import "RecordTypeMappingInfoManager.h"
#import "PicklistForRecordTypeInfoManager.h"
#import "RelatedListsInfoManager.h"
#import "RelatedListColumnInfoManager.h"
#import "RelatedListSortInfoManager.h"
#import "ChildRelationshipInfoManager.h"
#import "FilterManager.h"
#import "MainMediaViewer.h"
#import "Datagrid.h"
#import "CustomDataGrid.h"
#import "DirectoryHelper.h"
#import "AccountGrid.h"
#import "AccountNativeGrid.h"
#import "Preference.h"
#import "FilterObjectManager.h"
#import "EntityDataGrid.h"
#import "InfoFactory.h"
#import "FilterFieldManager.h"
#import "KeyFieldInfoManager.h"

@implementation AppDelegate


@synthesize window=_window;
@synthesize theNavController;
@synthesize tabController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Important to call the 2 methods below
    // 1 - create the db
    // 2 - create all tables    
    [[DatabaseManager getInstance] initDatabase];
    [FieldInfoManager initTable];
    [FilterManager initTable];
    [FilterObjectManager initTable];
    [PicklistInfoManager initTable];
    [EntityInfoManager initTable];
    [EditLayoutSectionsInfoManager initTable];
    [DetailLayoutSectionsInfoManager initTable];
    [RecordTypeMappingInfoManager initTable];
    [PicklistForRecordTypeInfoManager initTable];
    [RelatedListsInfoManager initTable];
    [RelatedListColumnInfoManager initTable];
    [RelatedListSortInfoManager initTable];
    [ChildRelationshipInfoManager initTable];
    [PropertyManager initTable];
    [PropertyManager initDatas];
    [LogManager initTable];
    [TransactionInfoManager initTable];
    [FilterFieldManager initTable];
    [KeyFieldInfoManager initTable];
    [DirectoryHelper initLibraryDirectory];
    
    // UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0,768, 60)];
    // [v setBackgroundColor: [UIColor blackColor]];//[UIColor colorWithRed:(78/255.0) green:(140.0/255.0) blue:(159.0/255.0) alpha:1]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    tabController = [[UITabBarController alloc] init];
    isPortrait = YES;
    isFirstLoad = NO;
    
    self.tabController.delegate = self;
    
    [self refreshTabs];
    
    self.window.rootViewController = tabController;
    [self.window makeKeyAndVisible];
    //[v release];
    
    return YES;
}

- (void)initTabs{
    
    UINavigationController *navController = nil;
    NSMutableArray *allControllers = [[NSMutableArray alloc] init];
    
    if([tabController.viewControllers count] > 0 ){
        [allControllers addObject:[tabController.viewControllers objectAtIndex:0]];
        [allControllers addObject:[tabController.viewControllers objectAtIndex:1]];
        [allControllers addObject:[tabController.viewControllers objectAtIndex:2]];
    }
    
    for(Item *item in viewControllers){
        NSString *title = item.entity;
        if([title isEqualToString:@"Preference"]){
            NSArray *array = [[FilterManager list:nil] autorelease]; 
            
            Preference * filterObject = [[Preference alloc] initWithArray:array];
            filterObject.title = NSLocalizedString(@"PREFERENCR", @"Preference");
            filterObject.tabBarItem = [[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"PREFERENCR", @"Preference") image:[UIImage imageNamed:@"20-gear2.png"] tag:0] autorelease]; // Latest release
            
            navController = [[UINavigationController alloc] initWithRootViewController:filterObject];
            [filterObject release];
            
        }else if([title isEqualToString:@"Synchronize"]){
            
            UIViewController *syncView = [[SynchronizeViewController alloc]init];
            syncView.title = NSLocalizedString(@"SYNCHRONIZE", @"Syncronize") ;
            syncView.tabBarItem = [[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"SYNCHRONIZE", @"Syncronize")  image:[UIImage imageNamed:@"02-redo.png"] tag:1] autorelease]; // Latest release
            
            navController = [[UINavigationController alloc] initWithRootViewController:syncView];
            [syncView release];
            
        }else if([title isEqualToString:@"Media"]){
            
            MainMediaViewer *mediaviewer = [[MainMediaViewer alloc] init:[DirectoryHelper getLibrariesPath]];
            mediaviewer.title = NSLocalizedString(@"MEDIA", @"Media");
            
            mediaviewer.tabBarItem = [[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"MEDIA", @"Media") image:[UIImage imageNamed:@"190-bank.png"] tag:2] autorelease];
            
            navController = [[UINavigationController alloc] initWithRootViewController:mediaviewer];
            [mediaviewer release];
            
        }else{
            
            CustomDataGrid *dataGrid = [[CustomDataGrid alloc] init];//initWithPopulate:listenerWithModel listener:listenerWithModel rowNumber:10];
            dataGrid.title = [item.fields valueForKey:@"label"];
            dataGrid.tabBarItem = [[[UITabBarItem alloc] initWithTitle:[item.fields valueForKey:@"label"] image:[UIImage imageNamed:@"imgOpportunity.png"] tag:3] autorelease]; // Latest release
            
            navController = [[UINavigationController alloc] initWithRootViewController:dataGrid];
            [dataGrid release];
            
        }
        
        navController.navigationBar.tintColor = [UIColor colorWithRed:(23.0/255.0) green:(155.0/255.0) blue:(192.0/255.0) alpha:1];
        // [navController.navigationBar setFrame:CGRectMake(0, 100, 780, 50)];
        
        [allControllers addObject:navController];
        // [navController release]; // Latest release
        
    }
    
    tabController.viewControllers = allControllers;
    tabController.moreNavigationController.navigationBar.tintColor = [UIColor colorWithRed:(23.0/255.0) green:(155.0/255.0) blue:(192.0/255.0) alpha:1];
    
    
    [allControllers release]; // Latest release
    
    if ([viewControllers count] < [tabController.viewControllers count]) {
        [viewControllers insertObject:[[Item alloc] init:@"Preference" fields:nil] atIndex:0];
        [viewControllers insertObject:[[Item alloc] init:@"Synchronize" fields:nil] atIndex:1];
        [viewControllers insertObject:[[Item alloc] init:@"Media" fields:nil] atIndex:2];
    }    
    //
    //    self.tabController.delegate = self;
    //    //self.window.rootViewController = tabController;
    //    [self.window addSubview:tabController.view];
    
}



- (void)refreshTabs{
    
    NSMutableArray *controllers;
    
    if([tabController.viewControllers count] == 0){
        controllers = [[NSMutableArray alloc] initWithObjects:[[Item alloc] init:@"Preference" fields:nil],[[Item alloc] init:@"Synchronize" fields:nil],[[Item alloc] init:@"Media" fields:nil],nil];
    }else{
        controllers = [[NSMutableArray alloc] init];
    }
    
    NSMutableDictionary *criteria = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
    [criteria setValue:[[[ValuesCriteria alloc] initWithString:@"yes"] autorelease] forKey:@"value"];
    
    NSArray *listFilter = [FilterManager list:criteria]; //Latest release
    if([listFilter count] > 0){
        Item *item = [listFilter objectAtIndex:0];
        NSObject <EntityInfo> *info = [InfoFactory getInfo:[item.fields valueForKey:@"objectName"]]; // Latest release
        if([[info.getAllFields autorelease] count] > 0){ //Latest release
            [controllers addObjectsFromArray:listFilter];
        }
        
    }
    
    
    [listFilter release]; // Latest release
    
    viewControllers = controllers;
    //[controllers release]; // Latest release
    [self initTabs];        
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

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}


-(void) tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    int indexOfTab = [tabBarController.viewControllers indexOfObject:viewController];
    NSLog(@"Tab index = %u ", indexOfTab);
    
    int nbOfTabVisible = [tabBarController.tabBar.items count];
    
    if (indexOfTab >= 3 && indexOfTab < nbOfTabVisible) {
        
        Item*item = [viewControllers objectAtIndex:indexOfTab];
        
        NSObject <DatagridListener,DataModel> * listenerWithModel = [[EntityDataGrid alloc] initWithEntity:[item.fields valueForKey:@"objectName"]];
        
        CustomDataGrid *dataGrid = [[CustomDataGrid alloc] initWithPopulate:listenerWithModel listener:listenerWithModel rowNumber:10];
        dataGrid.title = [item.fields valueForKey:@"label"];
        dataGrid.tabBarItem = [[UITabBarItem alloc] initWithTitle:[item.fields valueForKey:@"label"] image:[UIImage imageNamed:@"imgOpportunity.png"] tag:3];
        
        UINavigationController *navController = nil;
        navController = [[UINavigationController alloc] initWithRootViewController:dataGrid];
        navController.navigationBar.tintColor = [UIColor colorWithRed:(23.0/255.0) green:(155.0/255.0) blue:(192.0/255.0) alpha:1];
        
        NSMutableArray *allControllers =  [[NSMutableArray alloc] initWithArray:tabBarController.viewControllers] ;
        [allControllers removeObjectAtIndex:indexOfTab];
        [allControllers insertObject:navController atIndex:indexOfTab];
        
        [tabBarController setViewControllers:allControllers];
        [dataGrid release]; // Latest release
        [allControllers release]; // Latest release
        
    } else if (indexOfTab >= nbOfTabVisible){
        
        for (int x = nbOfTabVisible-1; x< [viewControllers count];x++) {
            
            Item*item = [viewControllers objectAtIndex:x];
            
            NSObject <DatagridListener,DataModel> * listenerWithModel = [[EntityDataGrid alloc] initWithEntity:[item.fields valueForKey:@"objectName"]];
            
            CustomDataGrid *dataGrid = [[CustomDataGrid alloc] initWithPopulate:listenerWithModel listener:listenerWithModel rowNumber:10];
            dataGrid.title = [item.fields valueForKey:@"label"];
            dataGrid.tabBarItem = [[UITabBarItem alloc] initWithTitle:[item.fields valueForKey:@"label"] image:[UIImage imageNamed:@"imgOpportunity.png"] tag:3];
            
            UINavigationController *navController = nil;
            navController = [[UINavigationController alloc] initWithRootViewController:dataGrid];
            navController.navigationBar.tintColor = [UIColor colorWithRed:(23.0/255.0) green:(155.0/255.0) blue:(192.0/255.0) alpha:1];
            
            NSMutableArray *allControllers =  [[NSMutableArray alloc] initWithArray:tabBarController.viewControllers] ;
            [allControllers removeObjectAtIndex:x];
            [allControllers insertObject:navController atIndex:x];
            
            [tabBarController setViewControllers:allControllers];
            [dataGrid release]; // Latest release
            [allControllers release]; // Latest release
            
        }
    }
    
}



- (void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration {
    
    float width;
    if (UIInterfaceOrientationIsPortrait(newStatusBarOrientation)) {
        if (isFirstLoad) {
            isPortrait = YES;
            width = 768.f;                
            tabController.tabBar.frame = CGRectMake(0, -246,width + 266, 60); 
            
            CGRect rect = [[tabController.view.subviews objectAtIndex:0] frame];
            rect.origin.y = 50;
            [[tabController.view.subviews objectAtIndex:0] setFrame:rect];
        }else isFirstLoad = YES;
    }    
    else {  
        isPortrait = NO;
        isFirstLoad = YES;
        width = 1024.f;
        tabController.tabBar.frame = CGRectMake(0, 265,width - 250, 62);
        
        CGRect rect = [[tabController.view.subviews objectAtIndex:0] frame];
        rect.origin.y = 50;
        [[tabController.view.subviews objectAtIndex:0] setFrame:rect];
    }  
    
}


- (void)dealloc
{
    [_window release];
    [theNavController release];
    [super dealloc];
}

@end
