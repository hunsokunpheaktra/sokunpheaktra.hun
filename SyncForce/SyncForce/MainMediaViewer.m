//
//  MainMediaViewer.m
//  Datagrid
//
//  Created by Gaeasys Admin on 10/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainMediaViewer.h"
#import "DirectoryListViewController.h"

@implementation MainMediaViewer

@synthesize directoryListViewController;
@synthesize mediasViewer;


- (id)init:(NSString *)prootPath{
    self = [super init];
    
    self.title =NSLocalizedString(@"MEDIA", Nil);
    self.directoryListViewController = [[DirectoryListViewController alloc] initWithRootPath:prootPath mainmediaviewer:self];
    self.mediasViewer = [[MediasViewer alloc] init];
    self.viewControllers = [NSArray arrayWithObjects:self.directoryListViewController, [[UINavigationController alloc] initWithRootViewController:self.mediasViewer], nil];
    self.delegate = self.mediasViewer;
    return self;
}

- (void)dealloc
{
    [directoryListViewController release];
    [mediasViewer release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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


//-(void) viewDidAppear:(BOOL)animated {
//    
//    float width;
//    
//    UIInterfaceOrientation orient = [[UIApplication sharedApplication] statusBarOrientation];
//    
//    if (UIInterfaceOrientationIsPortrait(orient)) width = 768;
//    else width = 1024;
//    [self.mediasViewer.navigationController.navigationBar setFrame:CGRectMake(0, 50, self.mediasViewer.navigationController.navigationBar.frame.size.width, 44)];
//    [self.navigationController.navigationBar setFrame:CGRectMake(0, 70,width, 44)];
//
//}
//
//-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
//    float width;
//    
//    UIInterfaceOrientation orient = [[UIApplication sharedApplication] statusBarOrientation];
//    
//    if (UIInterfaceOrientationIsPortrait(orient)) width = 768;
//    else width = 1024;
//    
//    [self.navigationController.navigationBar setFrame:CGRectMake(0, 70,width, 44)];
//}

@end
