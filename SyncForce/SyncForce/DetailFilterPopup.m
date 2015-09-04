//
//  DetailFilterPopup.m
//  SyncForce
//
//  Created by Gaeasys on 12/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailFilterPopup.h"
#import "PropertyManager.h"
#import "Preference.h"
#import "FilterManager.h"

@implementation DetailFilterPopup

@synthesize dateFilters;
@synthesize popoverController;
@synthesize button;
@synthesize valueSelected;
@synthesize selectPath,row;
@synthesize parentScreen;


- (id)initWithData:(NSArray *)datas {

    dateFilters = datas;
    return self;
    
}

- (void)dealloc
{
    [super dealloc];
}

-(void)viewDidLoad {
    
    [super viewDidLoad];
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
    return [self.dateFilters count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = NSLocalizedString([dateFilters objectAtIndex:indexPath.row], nil);
   
    if([cell.textLabel.text isEqualToString:self.valueSelected]){
        selectPath = [indexPath retain];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [cell.textLabel setTextColor:[UIColor colorWithRed:0.318 green:0.4 blue:0.569 alpha:1.0]];

    }
 
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        
    if (button != nil) {
        NSString* value = [self.dateFilters objectAtIndex:indexPath.row];
        [button setTitle:value forState:UIControlStateNormal];
        Item *item = [parentScreen.arrayData objectAtIndex:row];
        [item.fields setValue:value forKey:@"lastModified"];
        
        [FilterManager update:item modifiedLocally:NO];
        
        [self.popoverController dismissPopoverAnimated:YES];
    }else {
        [self.tableView cellForRowAtIndexPath:selectPath].accessoryType = UITableViewCellAccessoryNone;
        [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];// 
        
        [[[self.tableView cellForRowAtIndexPath:indexPath] textLabel] setTextColor:[UIColor colorWithRed:0.318 green:0.4 blue:0.569 alpha:1.0]];
        [[[self.tableView cellForRowAtIndexPath:selectPath] textLabel] setTextColor:[UIColor darkTextColor]];
        
        [PropertyManager save:[dateFilters objectAtIndex:selectPath.row] value:@"no"];
        [PropertyManager save:[dateFilters objectAtIndex:indexPath.row] value:@"yes"];
        
        selectPath = [indexPath retain];
        [[parentScreen tableView] reloadData];
        [self.popoverController dismissPopoverAnimated:YES];
    }
      
}

- (void) show:(UIButton *)newButton parentView:(UIView *)parentView {
    self.title = @"Last Modified";
    self.button = newButton;
    if([self.popoverController isPopoverVisible])
    {
        //close the popover view if toolbar button was touched
        //again and popover is already visible
        [self.popoverController dismissPopoverAnimated:YES];
        [popoverController release];
        [self release];
        return;
    }
    
    //build our custom popover view
    UINavigationController *popoverContent = [[UINavigationController alloc] initWithRootViewController:self];
    
    int height = [self.dateFilters count];
       
    //resize the popover view shown
    //in the current view to the view's size
    self.contentSizeForViewInPopover = CGSizeMake(200, height * 44);
    
    //create a popover controller
    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
    
    //present the popover view non-modal with a
    //refrence to the toolbar button which was pressed
    CGRect rect = [self.button.superview convertRect:self.button.frame toView:parentView];
    [self.popoverController presentPopoverFromRect:rect inView:parentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    [popoverContent release];

}


-(void)showPopup:(UIView*)content parentView:(UIView *)parentView selectedValue:(NSString*)selectedValue parent:(Preference*)parent{
    
    if([self.popoverController isPopoverVisible])
    {
        //close the popover view if toolbar button was touched
        //again and popover is already visible
        
        [self.popoverController dismissPopoverAnimated:YES];
        [self release];
        return;
    }
    
    parentScreen = parent;
    self.valueSelected = selectedValue;
    
    //build our custom popover view
    UINavigationController *popoverContent = [[UINavigationController alloc] initWithRootViewController:self];
    
    int height = [self.dateFilters count];
    
    //resize the popover view shown
    //in the current view to the view's size
    self.contentSizeForViewInPopover = CGSizeMake(300, height * self.tableView.rowHeight);
    
    //create a popover controller
    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
    
    //present the popover view non-modal with a
    //refrence to the toolbar button which was pressed
    CGRect rect = [content.superview convertRect:content.frame toView:parentView];
    [self.popoverController presentPopoverFromRect:rect inView:parentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    [popoverContent release];
    
}

@end
