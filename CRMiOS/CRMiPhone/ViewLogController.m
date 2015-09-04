//
//  ViewLogController.m
//  CRMiOS
//
//  Created by Sy Pauv on 5/17/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "ViewLogController.h"


@implementation ViewLogController

@synthesize myTableView,listLog;

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    self.title=@"sync log";
    // create the table view
    self.myTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.myTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.myTableView setDelegate:self];
    [self.myTableView setDataSource:self];
    [self.myTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.myTableView];
    [super viewDidLoad];
    self.listLog=(NSMutableArray *)[LogManager read];
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (listLog)
	{
		return [listLog count];
	}
	
	return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
    }
    cell.textLabel.font=[UIFont systemFontOfSize:14.0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    // Configure the cell.
    cell.textLabel.text =[[listLog objectAtIndex:indexPath.row] objectAtIndex:1];	
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 20;
}

@end
