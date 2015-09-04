//
//  SelectionPopup.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/12/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "SelectionPopup.h"

@implementation SelectionPopup

@synthesize item;
@synthesize values;
@synthesize popoverController;
@synthesize entity;
@synthesize code;
@synthesize value;
@synthesize listener;
@synthesize tableView;


- (id)initWithField:(NSString *)pCode entity:(NSString *)pEntity value:(NSString *)pValue item:(Item *)pItem listener:(NSObject<SelectionListener> *)pListener {
    //self = [super initWithStyle:UITableViewStylePlain];
    self.item = pItem;
    self.code = pCode;
    self.entity = pEntity;
    self.listener = pListener;
    self.value = pValue;
    self.values = [PicklistManager getPicklist:self.entity field:code item:item];
    return self;
}

- (int)getHeight {
    int height = [self.values count];
    if (height > 9) height = 9;
    return height;
}


- (void)viewDidLoad{
    
    BOOL hasSearch = [self.values count] > 20;
    
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 480, ([self getHeight] + (hasSearch ? 1 : 0)) * 44)];
    // Create the list
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, (hasSearch ? 44 : 0), 480, [self getHeight] * 44) style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [mainView addSubview:self.tableView];
    
    if (hasSearch) {
        // Create the search bar
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 480, 44)];
        [searchBar setShowsScopeBar:NO];
        searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [searchBar setDelegate:self];
        [mainView addSubview:searchBar];
    }
    // sets the view
    [self setView:mainView];
    
}


- (void) show:(CGRect)rect parentView:(UIView *)parentView {
    if ([self.popoverController isPopoverVisible]) {
        //close the popover view if toolbar button was touched
        //again and popover is already visible
        
        [self.popoverController dismissPopoverAnimated:YES];
        [self release];
        return;
    }
    if ([self.values count] == 1) {
        return;
    }
    



    self.title = [FieldsManager read:self.entity field:self.code].displayName;
    
    BOOL hasSearch = [self.values count] > 20;
    
    //resize the popover view shown
    //in the current view to the view's size
    self.contentSizeForViewInPopover =
        CGSizeMake(480, ([self getHeight] + (hasSearch ? 1 : 0)) * 44);
    
    
    //build our custom popover view
    UINavigationController *popoverContent = [[UINavigationController alloc]
                                              initWithRootViewController:self];
    //create a popover controller
    self.popoverController = [[UIPopoverController alloc]
                              initWithContentViewController:popoverContent];
    
    //present the popover view non-modal with a
    //refrence to the toolbar button which was pressed
    [self.popoverController presentPopoverFromRect:rect inView:parentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [popoverContent release];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.values count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    // Configure the cell...
    NSDictionary *picklistValue = [self.values objectAtIndex:indexPath.row];
    NSString *tmpValue = [picklistValue objectForKey:@"Value"];
    if ([tmpValue length] == 0) {
        [cell.textLabel setTextColor:[UIColor grayColor]];
        cell.textLabel.text = NSLocalizedString(@"NO_VALUE", @"No Value Picklist");
    } else {
        [cell.textLabel setTextColor:[UIColor darkTextColor]];
        cell.textLabel.text = tmpValue;
    }
    if ([[picklistValue objectForKey:@"ValueId"] isEqualToString:self.value]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *valueId = [[self.values objectAtIndex:indexPath.row] objectForKey:@"ValueId"];
    NSString *display = [[self.values objectAtIndex:indexPath.row] objectForKey:@"Value"];

    // Opportunity SalesStage 
    if ([entity isEqualToString:@"Opportunity"] && [code isEqualToString:@"SalesStage"] ) {
        [listener didSelect:@"Probability" valueId:[[self.values objectAtIndex:indexPath.row] objectForKey:@"Probability"] display:nil];
    }
    
    [listener didSelect:self.code valueId:(NSString *)valueId display:display];
    [self.popoverController dismissPopoverAnimated:YES];
    [self release];
        
}

- (void) filterData:(NSString *)filterText {
    
    if ([filterText isEqualToString:@""]) {
        self.values = [PicklistManager getPicklist:self.entity field:code item:item];
        [self.tableView reloadData];
    } else {
        NSMutableDictionary *filters = [[NSMutableDictionary alloc] initWithCapacity:1];
        
        self.values = [PicklistManager getPicklist:self.entity field:self.code item:item filterText:filterText];
        
        [filters release];
    }
    
}

#pragma searchbar delegate method

- (void)searchBarTextDidBeginEditing:(UISearchBar *)sb {
    [sb setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)sb {
    sb.text = @"";
    [sb setShowsCancelButton:NO animated:YES];
    [sb resignFirstResponder];
    self.values = [PicklistManager getPicklist:self.entity field:code item:item];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)sb {
    [sb resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)sb textDidChange:(NSString *)searchText {
    
    [self filterData:searchText];
    [self.tableView reloadData];
    
}

- (void) dealloc
{
    [values release];
    [super dealloc];
}

@end
