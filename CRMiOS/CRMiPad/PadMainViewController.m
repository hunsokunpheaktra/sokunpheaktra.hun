//
//  MainView.m
//  Orientation
//
//  Created by Sy Pauv Phou on 3/25/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "PadMainViewController.h"


@implementation PadMainViewController

@synthesize listViewController;
@synthesize itemViewController;
@synthesize isLandscape;
@synthesize tabBarController;
@synthesize subtype;

- (id)initWithSubtype:(NSString *)newSubtype tabBarController:(UITabBarController *)newTabBarController {
    self = [super init];
    self.showsMasterInPortrait = YES;
    self.subtype = newSubtype;
    self.tabBarController = newTabBarController;
    
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:self.subtype];    
    self.title = [sinfo localizedPluralName];
    self.itemViewController = [[BigDetailViewController alloc] initDetail:self.subtype parent:self];
    itemViewController.splitController = self;
    self.listViewController = [[PadListViewController alloc] initWithSubtype:self.subtype parent:self];
    self.viewControllers = [NSArray arrayWithObjects:self.listViewController, [[UINavigationController alloc] initWithRootViewController:self.itemViewController], nil];
    self.delegate = self.itemViewController;
    
    return self;
}


- (void)viewWillAppear:(BOOL)animated {
    // adjust height which sometimes bugs, so the Z is always at the bottom in A-Z list.
    CGRect rect = self.view.frame;
    if (rect.size.height == 655 || rect.size.height == 911) {
        rect.size.height += 44;
    }
    [self.view setFrame:rect];
    // call parent
    [super viewWillAppear:animated];
    // hide navigation bar when coming from "MORE" screen
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.detailViewController.view layoutIfNeeded];
    
    [self.listViewController mustUpdate];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}






- (void)dealloc
{
    [self.listViewController release];
    [self.itemViewController release];
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

- (void)didCreate:(NSString *)entityCreate key:(NSString *)key {
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:self.subtype];
    if ([[sinfo entity] isEqualToString:entityCreate]) {
        [self.listViewController selectItem:key];
    }
}

//- (void)navigate:(NSString *)newEntity subtype:(NSString *)newSubtype key:(NSString *)key {
//    
//    //[self.tabBarController.moreNavigationController popToRootViewControllerAnimated:NO];
//    
//    NSMutableArray *tabBarControllers = [[NSMutableArray alloc] initWithCapacity:1];
//    for (UINavigationController *controller in [self.tabBarController viewControllers]) {
//        if ([controller.viewControllers count] > 0) {
//            UIViewController *viewController = [controller.viewControllers objectAtIndex:0];
//            if ([viewController isKindOfClass:[UIViewController class]]) {
//                [tabBarControllers addObject:viewController];
//            }
//        }
//    }
//    for (UIViewController *viewController in [self.tabBarController.moreNavigationController viewControllers]) {
//        if ([viewController isKindOfClass:[UIViewController class]]) {
//            [tabBarControllers addObject:viewController];
//        }
//    }
//    
//    int i = 0;
//    for (UIViewController *viewController in tabBarControllers) {
//        if ([viewController isKindOfClass:[PadMainViewController class]]) {
//            PadListViewController *listController = ((PadMainViewController *)viewController).listViewController;
//            if ([listController.subtype isEqualToString:newSubtype]
//                || ([listController.sinfo.entity isEqualToString:newEntity] && ![newEntity isEqualToString:@"Activity"])) {
//
//                if (i >= 7) {
//                    // to highlight the "more" button
//                    [self.tabBarController setSelectedViewController:self.tabBarController.moreNavigationController];
//                } 
//                [self.tabBarController setSelectedViewController:viewController.navigationController];
//                listController.nameFilter = nil;
//                [listController filterData];
//                [listController.listView reloadData];
//                [listController selectItem:key];
//                break;
//            }
//        }
//        i++;
//    }
//    
//    [tabBarControllers release];
//}


- (void)mustUpdate {
    [self.listViewController mustUpdate]; 
}

- (void)refresh {
    [self.listViewController mustUpdate]; 
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    // to fix bug with alternate view : sometimes, buttons do no respond after a rotation
    if (self.listViewController.alternateVC != nil) {
        [self.listViewController buildView];
    }
}




- (void)setCurrentDetail:(Item *)item {
    NSString *itemSubtype = [Configuration getSubtype:item];
    if (![self.itemViewController.subtype isEqualToString:itemSubtype]) {
        [self.itemViewController release];
        self.itemViewController = nil;
        self.itemViewController = [[BigDetailViewController alloc] initDetail:itemSubtype parent:self];
        self.viewControllers = [NSArray arrayWithObjects:self.listViewController, [[UINavigationController alloc] initWithRootViewController:self.itemViewController], nil];
    }
    [self.itemViewController setCurrentDetail:item];
    
    
}

@end
