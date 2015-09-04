//
//  ViewController.m
//  Parcel
//
//  Created by Davin Pen on 10/2/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "MainViewController.h"
#import "MyParcelViewController.h"
#import "SettingsViewController.h"
#import "Item.h"
#import "LoginViewController.h"
#import "ParcelItem.h"
#import "Reachability.h"
#import "AppDelegate.h"

static MainViewController *mainViewController;

@implementation MainViewController

@synthesize user;

+ (MainViewController *)getInstance
{
	@synchronized([mainViewController class])
	{
		if (!mainViewController) {
            mainViewController = [[MainViewController alloc] init];
        }
		return mainViewController;
	}
	return nil;
}

+ (MainViewController *)getInstance : (Item*)user
{
	@synchronized([mainViewController class])
	{
		if (!mainViewController) {
            
            mainViewController = [[MainViewController alloc] init];
            
        }
        
		return mainViewController;
	}
	return nil;
}

+ (void)clearInstance{
    
    @synchronized([mainViewController class])
	{
		if (mainViewController) {
            [mainViewController release];
            mainViewController = [[MainViewController alloc] init];
        }
	}
}

- (void)logout{
    
    LoginViewController *login = (LoginViewController*)((UINavigationController*)self.presentingViewController).topViewController;
    [login.view setHidden:NO];
    [login logout];
    [self.user.fields setValue:@"0" forKey:@"lastLogin"];
    [UserManager update:self.user];
    
    login.currentUser = [[Item alloc] init:@"User" fields:[[NSDictionary alloc] init]];
    [login.tableView reloadData];
   
    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self dismissModalViewControllerAnimated:YES];
}

-(void)reloadTabs{
    
    [self.user.fields setValue:@"1" forKey:@"lastLogin"];
    [UserManager update:self.user];
    self.tabBar.backgroundImage = [UIImage imageNamed:@"tabbar-bg.png"];
    
    NSArray *tabs = [NSArray arrayWithObjects:MY_PARCELS,NEW_PARCEL,SETTINGS, nil];
    NSMutableArray *viewControllers = [NSMutableArray array];
    
    for(int i=0; i<tabs.count; i++){
        NSString *title=[tabs objectAtIndex:i];
        UIViewController *controller;
        
        if (i==0) {
            
            controller = [[MyParcelViewController alloc] init];
            controller.tabBarItem.image=[UIImage imageNamed:@"MyParcel.png"];
            
        }else if (i==1){
            
            Item *item = [[[Item alloc] init:@"Parcel" fields:[ParcelItem newItem]] autorelease];
            controller = [[NewParcelViewController alloc] initWithItem:item];
            controller.tabBarItem.image=[UIImage imageNamed:@"add-parcel.png"];
            
        }else{
            
            NSString *userId = [user.fields objectForKey:@"id"];
            userId = userId==nil ? @"" : userId;
            userId = [userId isEqualToString:@""] ? [user.fields objectForKey:@"local_id"] : userId;
            
            Item *settingItem = [SettingManager find:@"Setting" column:@"user_email" value:userId];
            if(!settingItem){
                settingItem = [SettingManager newSettingItem];
                [settingItem.fields setObject:userId forKey:@"user_email"];
                [SettingManager insert:settingItem];
            }
            [settingItem release];
            
            controller = [[SettingsViewController alloc] initWithUser:user];
            controller.tabBarItem.image=[UIImage imageNamed:@"setting.png"];
            
        }
        
        controller.title = title;
        controller.tabBarItem.title = title;
        controller.tabBarItem.tag = i;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
        //nav.navigationBar.tintColor = [UIColor colorWithRed:(65./255.) green:(92./255.) blue:(151./255.) alpha:1];
        [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation-bg.png"] forBarMetrics:UIBarMetricsDefault];
        
        [controller release];
        [viewControllers addObject:nav];
        [nav release];
        
    }
    self.viewControllers = viewControllers;
    
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.view.tag = 2;
    imagePicker.allowsEditing = YES;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [imagePicker release];
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
    if(self.viewControllers == nil){
        [self reloadTabs];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == 2) [[self getNewParcelController] showInputTrackingNumber];
    
    imagePicker.sourceType = buttonIndex == 0 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        [self presentModalViewController:imagePicker animated:YES];
    }else{
        [popover presentPopoverFromRect:self.selectedViewController.view.frame inView:self.selectedViewController.view permittedArrowDirections:0 animated:NO];
    }
    
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    
    if(item.tag == 1){
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
        actionSheet.delegate = self;
        actionSheet.title = TAKE_PICTURE;
        
        [actionSheet addButtonWithTitle:CAMERA];
        [actionSheet addButtonWithTitle:LIBRARY];
        [actionSheet addButtonWithTitle:MSG_CANCEL];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            [actionSheet addButtonWithTitle:MSG_CANCEL];
        }
        
        actionSheet.cancelButtonIndex = 2;
        
        [actionSheet showFromTabBar:self.tabBar];
        [actionSheet release];
        
    }
    
}

-(NewParcelViewController*)getNewParcelController{
    UINavigationController *nav = (UINavigationController*)self.selectedViewController;
    NewParcelViewController *newCon = (NewParcelViewController*)nav.topViewController;
    return newCon;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [[self getNewParcelController] imagePickerController:picker didFinishPickingMediaWithInfo:info];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [popover dismissPopoverAnimated:YES];
    }
    
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [popover dismissPopoverAnimated:YES];
    }else{
        [picker dismissViewControllerAnimated:YES completion:^void(){
            [[self getNewParcelController] showInputTrackingNumber];
        }];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}


@end
