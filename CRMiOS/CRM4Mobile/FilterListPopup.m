//
//  FilterListPopup.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 10/6/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "FilterListPopup.h"


@implementation FilterListPopup

@synthesize filters;
@synthesize subtype;
@synthesize listener;
@synthesize tableView;


UIPopoverController *popoverController;

- (id)initPopup:(NSString *)newSubtype listener:(NSObject<UpdateListener> *)newListener {
    self = [super init];
    self.listener = newListener;
    self.subtype = newSubtype;
    self.filters = [[NSMutableArray alloc] initWithCapacity:1];
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:self.subtype];
    [self.filters addObject:[NSNull null]];
    ConfigFilter *favFilter = [[ConfigFilter alloc] initWithName:@"%FAVORITE%"];
    [self.filters addObject:favFilter];
    ConfigFilter *importantFilter = [[ConfigFilter alloc] initWithName:@"%IMPORTANT%"];
    [self.filters addObject:importantFilter];
    [self.filters addObjectsFromArray:[sinfo getFilters:NO]];
    self.title = [NSString stringWithFormat:NSLocalizedString(@"OBJECT_FILTER", @"Object Filter"), [sinfo localizedName]] ;
    return self;
}

- (void)viewDidLoad {
    
    UIView *mainView = [[UIView alloc] init];
    // Create the list
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 400) style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tableView.scrollEnabled = NO;
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [mainView addSubview:self.tableView];
    

    // sets the view
    [self setView:mainView];
    
}

- (void) showList:(id)sender {
    if([popoverController isPopoverVisible])
    {
        //close the popover view if toolbar button was touched
        //again and popover is already visible
        
        [popoverController dismissPopoverAnimated:YES];
        [self release];
        return;
    }
    
    //build our custom popover view
    UINavigationController *popoverContent = [[UINavigationController alloc]
                                              initWithRootViewController:self];

    
    //resize the popover view shown
    //in the current view to the view's size
    self.contentSizeForViewInPopover =
        CGSizeMake(480, [self.filters count] * 44);
    
    //create a popover controller
    popoverController = [[UIPopoverController alloc]
                         initWithContentViewController:popoverContent];
    
    //present the popover view non-modal with a
    //refrence to the toolbar button which was pressed
    [popoverController presentPopoverFromBarButtonItem:sender
                              permittedArrowDirections:UIPopoverArrowDirectionUp
                                              animated:YES];
    
    [popoverContent release];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.filters count];
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
    ConfigFilter *filter = [self.filters objectAtIndex:indexPath.row];
    if (filter == (id)[NSNull null]) {
        [cell.textLabel setTextColor:[UIColor grayColor]];
        cell.textLabel.text = NSLocalizedString(@"NO_FILTER", @"No Filter");
        if ([[FilterManager getFilter:self.subtype] length] == 0) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else {
        
        [cell.textLabel setTextColor:[UIColor darkTextColor]];
        cell.textLabel.text = [EvaluateTools translateWithPrefix:filter.name prefix:@"FILTER_"];
        if ([[FilterManager getFilter:self.subtype] isEqualToString:filter.name]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ConfigFilter *filter = [self.filters objectAtIndex:indexPath.row];
    if (filter == (id)[NSNull null]) {
        [FilterManager setFilter:self.subtype code:@""];
    } else {
        [FilterManager setFilter:self.subtype code:filter.name];
    }

    [listener mustUpdate];
    [popoverController dismissPopoverAnimated:YES];
    [self release];
    
}



- (void) dealloc
{
    [self.filters release];
    [super dealloc];
}


@end
