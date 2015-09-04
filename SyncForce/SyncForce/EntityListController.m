//
//  EntityListController.m
//  SyncForce
//
//  Created by Hun Sokunpheaktra on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EntityListController.h"
#import "EntityManager.h"
#import "EntityInfoManager.h"
#import "Item.h"

@implementation EntityListController

@synthesize popover,entity;
@synthesize updateListener;

- (id)initWithEntity:(NSString*)newEntity listener:(NSObject<UpdateListener>*)updateLis{
    
    entity = newEntity;
    self.updateListener = updateLis;
    self = [super initWithStyle:UITableViewStylePlain];
    
    listItems = [EntityManager list:entity criterias:nil];
    //UIBarButtonItem *barAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:nil];
    //self.navigationItem.rightBarButtonItem = barAdd;
    
    return self;
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)showPopup:(UIBarButtonItem*)barItem parentView:(UIView*)mainView{
    
    if(self.popover.isPopoverVisible){
        [self.popover dismissPopoverAnimated:YES];
        return;
    }
    
    self.title = [NSString stringWithFormat:@"List %@s",self.entity];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self];
    
    nav.navigationBar.tintColor = [UIColor colorWithRed:(23.0/255.0) green:(155.0/255.0) blue:(192.0/255.0) alpha:1];
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:nav];
    self.contentSizeForViewInPopover = CGSizeMake(500, 500);
    [nav release];
    
    [self.popover presentPopoverFromBarButtonItem:barItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

#pragma mark - View lifecycle

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [listItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    Item *item = [listItems objectAtIndex:indexPath.row];
    cell.textLabel.text = [item.fields objectForKey:@"Name"];
    
    // Configure the cell...
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [updateListener didUpdate:[listItems objectAtIndex:indexPath.row]];
    [self.popover dismissPopoverAnimated:YES];
}

@end
