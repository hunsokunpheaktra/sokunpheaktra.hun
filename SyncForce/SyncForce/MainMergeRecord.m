//
//  MainMergeScreen.m
//  SyncForce
//
//  Created by Gaeasys on 12/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainMergeRecord.h"
#import "MergeRecordDetail.h"
#import "MergeRecordPopover.h"
#import "SfMergeRecords.h"
#import "EntityManager.h"

@implementation MainMergeRecord

@synthesize listRecordsMerge;
@synthesize mergeView;
@synthesize entityName;
@synthesize listrecods;
@synthesize sfRecords;


- (id)initWithEntity:(NSString*)entity listlocalrecords:(NSArray*)local listSfRecords:(NSArray*)sf merge:(id)mergeController{
  
    self = [super init];
    self.listrecods = [local copy];
    self.sfRecords = [sf copy];
    self.entityName = entity;
    process = (SfMergeRecords*)mergeController;
    self.title =NSLocalizedString(@"MERGE_SCREEN", nil);
    self.listRecordsMerge = [[MergeRecordPopover alloc] initWithRootPath:entityName mainmediaviewer:self localRecord:listrecods sfRecords:sfRecords];
    self.mergeView = [[MergeRecordDetail alloc] initWithEntity:entityName];
    
    UIBarButtonItem *saveButton = [[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"SAVE", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(saveRecordMerged:)] autorelease];
    [mergeView.navigationItem setRightBarButtonItem:saveButton];
    
    self.viewControllers = [NSArray arrayWithObjects:self.listRecordsMerge, [[UINavigationController alloc] initWithRootViewController:self.mergeView], nil];
    self.delegate = self.mergeView;
    
    return self;
    
}

-(void)dealloc{
    [super dealloc];
    [mergeView release];
}

-(void)saveRecordMerged:(id)sender {    
    [self.listRecordsMerge afterSaveRecordsMerged];
    [process continueProcess];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
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

@end
