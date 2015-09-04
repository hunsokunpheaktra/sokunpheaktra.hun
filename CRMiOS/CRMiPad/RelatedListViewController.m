//
//  RelatedListViewController.m
//  CRMiOS
//
//  Created by Sy Pauv on 5/31/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "RelatedListViewController.h"


@implementation RelatedListViewController
@synthesize relatedList, entity, relatedItems, groups,sType;

- (id) initWithEntity:(NSString *)newEntity subtype:(NSString *)subtype relatedList:(NSArray *)newList{
    
    self=[super initWithStyle:UITableViewStylePlain];
    self.relatedList = newList;
    self.entity = newEntity;
    self.sType = subtype;
    self.relatedItems = [[NSMutableArray alloc]initWithCapacity:1];
    
    for (NSDictionary *tmp in relatedList) {
        
        [self.relatedItems addObject:[EntityManager find:entity column:@"gadget_id" value:[tmp objectForKey:@"gadget_id"]]];
        
    }
    self.groups = [GroupManager getGroups:sType items:(NSArray *)relatedItems];    
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
    [super viewDidLoad];
    self.title=[NSString stringWithFormat:@"Related %@",self.entity];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [self.groups count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    Group *group = [groups objectAtIndex:section];
    return group.items.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    Group *group = [groups objectAtIndex:section];
    return group.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Group *group = [groups objectAtIndex:indexPath.section];
    Item *item = [group.items objectAtIndex:indexPath.row];
    
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	// Configure the cell...
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:sType];
	cell.textLabel.text = [sinfo getDisplayText:item];
    cell.detailTextLabel.text = [sinfo getDetailText:item];
    
    return cell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // TODO
//    // Create a modal view controller
//    Group *group = [groups objectAtIndex:indexPath.section];
//    Item *item = [group.items objectAtIndex:indexPath.row];
//
//    BigDetailViewController *detailController = [[BigDetailViewController alloc] initWithDetail:item updateListener:self];
//    [[self navigationController] pushViewController:detailController animated:YES];
//    // Clean up resources
//    [detailController release];  
    
}

- (void)mustUpdate{
    
    [self.tableView reloadData];
    
}

@end
