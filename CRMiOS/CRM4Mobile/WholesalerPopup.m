//
//  PlaceholderPopup.m
//  CRMiOS
//
//  Created by Arnaud Marguerat on 8/23/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "WholesalerPopup.h"

@implementation WholesalerPopup

@synthesize values;
@synthesize popoverController;
@synthesize subtype;
@synthesize code;
@synthesize value;
@synthesize listener;
@synthesize otherEntity;
@synthesize tableView;
@synthesize stateFilter;
@synthesize catalogFilter;

- (id)initWithField:(NSString *)newCode subtype:(NSString *)newSubtype value:(NSString *)newValue listener:(NSObject<SelectionListener> *)newListener {
    self.code = newCode;
    self.subtype = newSubtype;
    self.listener = newListener;
    self.value = newValue;
    self.otherEntity = [RelationManager getRelatedEntity:self.subtype field:self.code];
    
    [self filterData];
    return self;
}

- (int)getHeight {
    int height = [self.values count];
    if (height > 9) height = 9;
    return height;
}

- (void)viewDidLoad{
    
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 600, ([self getHeight] + 1) * 44)];
    // Create the list
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 600, [self getHeight] * 44) style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [mainView addSubview:self.tableView];
    
    // Create the search bar
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
    searchBar.tag = 1;
    [searchBar setShowsScopeBar:NO];
    [searchBar setPlaceholder:@"Catalog"];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [searchBar setDelegate:self];
    [mainView addSubview:searchBar];
    
    UISearchBar *searchBar2 = [[UISearchBar alloc] initWithFrame:CGRectMake(300, 0, 300, 44)];
    searchBar2.tag = 2;
    [searchBar2 setShowsScopeBar:NO];
    [searchBar2 setPlaceholder:@"State"];
    searchBar2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [searchBar2 setDelegate:self];
    [mainView addSubview:searchBar2];
    
    // sets the view
    [self setView:mainView];
    
}


- (void) show:(CGRect)rect parentView:(UIView *)parentView {
    if([self.popoverController isPopoverVisible])
    {
        //close the popover view if toolbar button was touched
        //again and popover is already visible
        
        [self.popoverController dismissPopoverAnimated:YES];
        [self release];
        return;
    }
    
    
    // [self.view addSubview:search];
    
    
    //build our custom popover view
    UINavigationController *popoverContent = [[UINavigationController alloc]initWithRootViewController:self];
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:self.subtype];
    NSString *tmpField = [FieldsManager read:[sinfo entity] field:self.code].displayName;
    self.title = [EvaluateTools removeIdSuffix:tmpField];
    
    //resize the popover view shown
    //in the current view to the view's size
    self.contentSizeForViewInPopover = CGSizeMake(600, ([self getHeight] + 1) * 44);
    
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
    if (indexPath.row==0) {
        
        [cell.textLabel setTextColor:[UIColor grayColor]];
        cell.textLabel.text = [self.values objectAtIndex:indexPath.row];
        
        if ([self.value isEqualToString:@""]||self.value==nil) {
            cell.accessoryType=UITableViewCellAccessoryCheckmark;
        }
        
    } else {
        
        // Configure the cell...
        Item *data = [self.values objectAtIndex:indexPath.row];
        [cell.textLabel setTextColor:[UIColor darkTextColor]];
        NSString *location = @"";
        if([data.fields objectForKey:@"PrimaryShipToCity"] && ![[data.fields objectForKey:@"PrimaryShipToCity"] isEqualToString:@""] ){
            location = [NSString stringWithFormat:@"(%@)", [data.fields objectForKey:@"PrimaryShipToCity"]];
        }
        NSString *dataSubtype = [Configuration getSubtype:data];
        NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:dataSubtype];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",[sinfo getDisplayText:data], location];
        cell.detailTextLabel.text = [sinfo getDetailText:data];
        NSString *icon = [sinfo getIcon:data];
        
        
        if (icon != Nil) {
            cell.imageView.image = [UIImage imageNamed:icon];
        } else {
            cell.imageView.image = Nil;
        }
        if ([[data.fields objectForKey:@"Id"] isEqualToString:self.value]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *valueId;
    if (indexPath.row==0) {
        valueId = @"";
    } else {
        Item *data = [self.values objectAtIndex:indexPath.row];
        valueId = (NSString*)[data.fields objectForKey:@"Id"];
        
    }   
    [listener didSelect:self.code valueId:(NSString *)valueId display:nil];
    [self.popoverController dismissPopoverAnimated:YES];
    
}

- (void) dealloc
{
    [values release];
    [super dealloc];
}

- (void)filterData {
    
    NSMutableArray *filters = [[NSMutableArray alloc] initWithCapacity:1];
    
    if ([catalogFilter length] > 0) {
        [filters addObject:[[LikeCriteria alloc] initWithColumn:@"CustomPickList8" value:catalogFilter]];
    }
    if ([stateFilter length] > 0) {
        [filters addObject:[[LikeCriteria alloc] initWithColumn:@"PrimaryBillToProvince" value:stateFilter]];
    }
    [filters addObject:[ValuesCriteria criteriaWithColumn:@"AccountType" value:@"Distributor"]];

    NSMutableArray *tmplist = [[NSMutableArray alloc] initWithCapacity:1];
    [tmplist addObject:NSLocalizedString(@"NO_VALUE", @"No Value Picklist")];
    for (Item *tmpitem in [EntityManager list:otherEntity entity:otherEntity criterias:filters additional:[NSArray arrayWithObject:@"PrimaryShipToCity"] limit:0]) {
        [tmplist addObject:tmpitem];
    }
    self.values = (NSArray *)tmplist;
    [tmplist release];
    [filters release];
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchBar.tag == 1) {
        self.catalogFilter = searchText;
    } else {
        self.stateFilter = searchText;
    }
    [self filterData];
    [self.tableView reloadData];
}

@end

