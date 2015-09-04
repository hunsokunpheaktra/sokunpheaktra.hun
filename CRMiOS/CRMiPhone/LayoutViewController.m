//
//  LayoutViewController.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/26/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "LayoutViewController.h"


@implementation LayoutViewController

@synthesize subtypes;

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    self.subtypes = [[NSMutableArray alloc] initWithCapacity:1];
    for (NSString *entity in [Configuration getEntities]) {
        for (int i = 0; i < [[[Configuration getInfo:entity] getSubtypes] count]; i++) {
            ConfigSubtype *sinfo = [[[Configuration getInfo:entity] getSubtypes] objectAtIndex:i];
            [self.subtypes addObject:sinfo.name];
        }
    }
    self.title = NSLocalizedString(@"CUSTOM_LAYOUTS", @"custom layout title");
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



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.subtypes count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSString *subtypeCode = [self.subtypes objectAtIndex:indexPath.row];
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:subtypeCode];
    cell.textLabel.text = [sinfo localizedName];
    cell.imageView.image = [UIImage imageNamed:[sinfo iconName]];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *subtypeCode = [self.subtypes objectAtIndex:indexPath.row];
    
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:subtypeCode];
    LayoutDetailViewController *detailController = [[LayoutDetailViewController alloc] initWithEntity:[sinfo entity] subtype:subtypeCode];
    [[self navigationController] pushViewController:detailController animated:YES];
    [detailController release];
}


@end
