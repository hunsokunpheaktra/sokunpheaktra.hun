//
//  RelatedPopup.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 6/6/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "RelatedPopup.h"

@implementation RelatedPopup

@synthesize values;
@synthesize popoverController;
@synthesize subtype;
@synthesize code;
@synthesize value;
@synthesize listener;
@synthesize otherEntity;
@synthesize tableView;
@synthesize nameFilter;
@synthesize parentItem;
@synthesize seeAll;

- (id)initWithField:(NSString *)newCode subtype:(NSString *)newSubtype value:(NSString *)newValue parentItem:(Item *)newParentItem listener:(NSObject<SelectionListener> *)newListener {
    self.code = newCode;
    self.subtype = newSubtype;
    self.listener = newListener;
    self.value = newValue;
    self.otherEntity = [RelationManager getRelatedEntity:self.subtype field:self.code];
    self.parentItem = newParentItem;
    self.seeAll = [self shouldFilterContact] == nil;
    [self filterData];
    return self;
}

- (void)dealloc {
    self.popoverController = nil;
    self.values = nil;
    self.tableView = nil;
    [super dealloc];
}

// CR #5261
- (NSString *)shouldFilterContact {
    if (([[self getEntity] isEqualToString:@"Account"] || [self.subtype isEqualToString:@"Appointment"])  && [self.code isEqualToString:@"PrimaryContactId"]) {
        NSString *field = [[self getEntity] isEqualToString:@"Account"] ? @"Id" : @"AccountId";
        NSString *accountId = [self.parentItem.fields objectForKey:field];
        if (accountId != nil && accountId.length > 0) return accountId;
    }
    if ([self.subtype isEqualToString:@"Opportunity ContactRole"] && [self.code isEqualToString:@"ContactId"]) {
        NSString *opportunityId = [self.parentItem.fields objectForKey:@"parent_oid"];
        Item *opportunity = [EntityManager find:@"Opportunity" column:@"Id" value:opportunityId];
        if (opportunity != nil && [[opportunity.fields objectForKey:@"AccountId"] length] > 0) {
            return [opportunity.fields objectForKey:@"AccountId"];
        }
    }
    if ([self.subtype isEqualToString:@"Activity Contact"] && [self.code isEqualToString:@"Id"]) {
        NSString *activityId = [self.parentItem.fields objectForKey:@"parent_oid"];
        Item *activity = [EntityManager find:@"Activity" column:@"Id" value:activityId];
        if (activity != nil && [[activity.fields objectForKey:@"AccountId"] length] > 0) {
            return [activity.fields objectForKey:@"AccountId"];
        }
    }
    return nil;
}

- (int)getHeight {
    int height = [self.values count];
    if (height > 9) height = 9;
    return height;
}

- (void)loadView {
    
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 600, ([self getHeight] + 1) * 44)];
    // Create the list
    self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 44, 600, [self getHeight] * 44) style:UITableViewStylePlain] autorelease];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [mainView addSubview:self.tableView];

    // Create the search bar
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 600, 44)];
    [searchBar setShowsScopeBar:NO];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [searchBar setDelegate:self];
    [mainView addSubview:searchBar];
    
    // sets the view
    [self setView:mainView];
    [mainView release];
}




- (NSString *)getEntity {
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:self.subtype];
    if (sinfo == nil) {
        // for sublist of type "Opportunity Partner" or "Account Note"
        return self.subtype;
    } else {
        return [sinfo entity];
    }
}

- (void)show:(CGRect)rect parentView:(UIView *)parentView {
    if ([self.popoverController isPopoverVisible]) {
        // close the popover view if toolbar button was touched
        // again and popover is already visible
        
        [self.popoverController dismissPopoverAnimated:YES];
        [self release];
        return;
    }
    

    //build our custom popover view
    UINavigationController *popoverContent = [[UINavigationController alloc] initWithRootViewController:self];
    NSString *entity = [self getEntity];

    
    CRMField *tmpField = [FieldsManager read:entity field:self.code];
    self.title = [EvaluateTools removeIdSuffix:tmpField.displayName];
    
    // resize the popover view shown
    // in the current view to the view's size
    self.contentSizeForViewInPopover = CGSizeMake(600, ([self getHeight] + 1) * 44);
    
    //create a popover controller
    self.popoverController = [[[UIPopoverController alloc]
                              initWithContentViewController:popoverContent] autorelease];
    
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.row==0) {
        
        [cell.textLabel setTextColor:[UIColor grayColor]];
        cell.textLabel.text = [self.values objectAtIndex:indexPath.row];
        
        if ([self.value isEqualToString:@""] || self.value==nil) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        
    } else {
    
        // Configure the cell...
        Item *data = [self.values objectAtIndex:indexPath.row];
        NSString *dataSubtype = [Configuration getSubtype:data];
        NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:dataSubtype];

        [cell.textLabel setTextColor:[UIColor darkTextColor]];
        
        cell.textLabel.text = [sinfo getDisplayText:data];
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

- (void)filterData {
    if (self.otherEntity == nil) return;
    
    NSMutableArray *filters = [[NSMutableArray alloc] initWithCapacity:1];
    
    if ([nameFilter length] > 0) {
        NSObject <Criteria> *searchCriteria;
        NSObject <Criteria> *search2Criteria;
        if ([Configuration isYes:@"wildcardSearch"]) {
            searchCriteria = [[ContainsCriteria alloc] initWithColumn:@"search" value:nameFilter];
            search2Criteria = [[ContainsCriteria alloc] initWithColumn:@"search2" value:nameFilter];
        } else {
            searchCriteria = [[LikeCriteria alloc] initWithColumn:@"search" value:nameFilter];
            search2Criteria = [[LikeCriteria alloc] initWithColumn:@"search2" value:nameFilter];
        }
        if ([[Configuration getInfo:self.otherEntity] searchField2] != nil) {
            OrCriteria *orCriteria = [[OrCriteria alloc]
                                      initWithCriteria1: searchCriteria
                                      criteria2: search2Criteria];
            [filters addObject:orCriteria];
            [orCriteria release];
        } else {
            [filters addObject:searchCriteria];
        }
        [searchCriteria release];
        [search2Criteria release];
    }

    // CR #4950 and CR #5261

    if (!self.seeAll) {
        NSString *accountId = [self shouldFilterContact];
        if (accountId != nil) {
            [filters addObject:[ValuesCriteria criteriaWithColumn:@"AccountId" value:accountId]];
        }
    }
    
    // additional fields : when the list contains several subtypes
    NSMutableArray *additional = [[NSMutableArray alloc] initWithCapacity:1];
    NSObject <EntityInfo> *info = [Configuration getInfo:self.otherEntity];
    for (NSObject<Subtype> *oinfo in [info getSubtypes]) {
        if (![oinfo.name isEqualToString:self.otherEntity]) {
            [additional addObjectsFromArray:[oinfo listFields]];
        }
    }
    
    NSMutableArray *tmplist = [[NSMutableArray alloc] initWithCapacity:1];
    [tmplist addObject:NSLocalizedString(@"NO_VALUE", @"No Value Picklist")];
    for (Item *tmpitem in [EntityManager list:self.otherEntity entity:self.otherEntity criterias:filters additional:additional limit:0]) {
        [tmplist addObject:tmpitem];
    }
    self.values = tmplist;
    [additional release];
    [tmplist release];
    [filters release];
    
    if (self.seeAll) {
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    } else {
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"RELATED_SEE_ALL", @"See all") style:UIBarButtonItemStylePlain target:self action:@selector(showAll)] animated:YES];
    }

}

- (void)showAll {
    self.seeAll = YES;
    [self filterData];
    [self.tableView reloadData];
    
    self.view.frame = CGRectMake(0, 44, 600, ([self getHeight] + 1) * 44);
    self.tableView.frame = CGRectMake(0, 44, 600, [self getHeight] * 44);
    self.contentSizeForViewInPopover = CGSizeMake(600, ([self getHeight] + 1) * 44);
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
    self.nameFilter = searchText;
    [self filterData];
    [self.tableView reloadData];
}

@end
