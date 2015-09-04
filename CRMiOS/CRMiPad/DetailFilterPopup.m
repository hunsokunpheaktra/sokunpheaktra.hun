//
//  DetailFilterPopup.m
//  CRMiOS
//
//  Created by Sy Pauv on 5/25/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "DetailFilterPopup.h"


@implementation DetailFilterPopup

@synthesize dateFilters;
@synthesize ownerFilters;
@synthesize entity;
@synthesize popoverController;
@synthesize isOwner;
@synthesize button;
@synthesize parent;

- (id)initWithEntity:(NSString *)newEntity filterType:(NSString *)newIsOwner parent:(PadSyncFiltersView *)newParent {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.isOwner = newIsOwner;
        self.parent = newParent;
        self.entity = newEntity;
        self.ownerFilters = [NSArray arrayWithObjects:@"Broadest", @"Sales Rep", @"Personal", nil];
        self.dateFilters = [NSArray arrayWithObjects:@"All", @"Last Year", @"Last Month", @"Last Week", nil];
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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.isOwner isEqualToString:@"true"]) {
        return [self.ownerFilters count];
    } else {
        return [self.dateFilters count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    NSString *value, *property;
    
    if ([self.isOwner isEqualToString:@"true"]) {
        value = [self.ownerFilters objectAtIndex:indexPath.row];
        property = [NSString stringWithFormat:@"ownerFilter%@", self.entity];
    } else {
        value = [self.dateFilters objectAtIndex:indexPath.row];
        property = [NSString stringWithFormat:@"dateFilter%@", self.entity];
    }
    
    [cell.textLabel setText:value];
    if ([[PropertyManager read:property] isEqualToString:value]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSString *property, *value;
    if ([self.isOwner isEqualToString:@"true"]) {
        property = [NSString stringWithFormat:@"ownerFilter%@", self.entity];
        value = [self.ownerFilters objectAtIndex:indexPath.row];
    } else {
        property = [NSString stringWithFormat:@"dateFilter%@", self.entity];
        value = [self.dateFilters objectAtIndex:indexPath.row];
    }
    if (![[PropertyManager read:property] isEqualToString:value]) {
        [parent filterChanged];
    }
    [PropertyManager save:property value:value];
    [button setTitle:value forState:UIControlStateNormal];
    [self.popoverController dismissPopoverAnimated:YES];
  //  [self release];
}

- (void) show:(UIButton *)newButton parentView:(UIView *)parentView {
    self.button = newButton;
    
    if([self.popoverController isPopoverVisible])
    {
        //close the popover view if toolbar button was touched
        //again and popover is already visible
        
        [self.popoverController dismissPopoverAnimated:YES];
        [self release];
        return;
    }
    
    //build our custom popover view
    UINavigationController *popoverContent = [[UINavigationController alloc]
                                              initWithRootViewController:self];
    
    int height;
    if ([self.isOwner isEqualToString:@"true"]) {
        height = [self.ownerFilters count];
        self.title = @"Owner Filter";
    } else {
        height = [self.dateFilters count];
        self.title = @"Last Modification Filter";
    }

    
    //resize the popover view shown
    //in the current view to the view's size
    self.contentSizeForViewInPopover =
    CGSizeMake(400, height * 44);
    
    //create a popover controller
    self.popoverController = [[UIPopoverController alloc]
                              initWithContentViewController:popoverContent];
    
    //present the popover view non-modal with a
    //refrence to the toolbar button which was pressed
    CGRect rect = [self.button.superview convertRect:self.button.frame toView:parentView];
    [self.popoverController presentPopoverFromRect:rect inView:parentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    [popoverContent release];

}


@end
