//
//  SynViewController.m
//  CRMiOS
//
//  Created by Sy Pauv on 5/16/11.
//  Copyright 2011 Gaeasys. All rights reserved.
//

#import "SynViewController.h"


@implementation SynViewController

@synthesize m_activity;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.title=@"Synchronize";
    }
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

- (void)viewDidLoad
{
    [self updateSynButton:YES];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)updateSynButton:(BOOL)animated{
    if ([[SyncProcess getInstance] isRunning]) {
        m_activity.hidden=animated;
    }else{
        m_activity.hidden=animated;
    }
    
}

-(IBAction)startSyn:(id)sender{
    SyncProcess *sync = [SyncProcess getInstance];
    [sync start:[SyncController getInstance]];
    [m_activity startAnimating];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
