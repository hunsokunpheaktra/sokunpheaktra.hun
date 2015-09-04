//
//  ListViewController1.m
//  CRM
//
//  Created by MACBOOK on 4/8/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "ListViewController.h"


@implementation ListViewController

@synthesize groups;
@synthesize entity;
@synthesize subtype;
@synthesize syncIndic;
@synthesize addBtn;
@synthesize tableView;


- (id)initWithEntity:(NSString *)newEntity subtype:(NSString *)newSubtype {
    self = [super init];
    self.entity = newEntity;
    self.subtype = newSubtype;
    NSObject<Subtype> *sinfo = [Configuration getSubtypeInfo:self.subtype];

    self.title = [sinfo localizedPluralName];
    return self;
}

- (void)loadView {
       
    self.addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNew:)];
    self.addBtn.enabled = NO;
    self.navigationItem.rightBarButtonItem=self.addBtn;
    
    NSObject <EntityInfo> *info = [Configuration getInfo:self.entity];
    if ([info canCreate] && [[FieldsManager list:self.entity] count]>0) {
        self.addBtn.enabled = YES;
    }

    UIView *mainView = [[UIView alloc] init];
    
    UIInterfaceOrientation deviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    // Create the list
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWidth = screenRect.size.width;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 0, 
                                                                   UIDeviceOrientationIsPortrait(deviceOrientation) ? screenHeight - 156 : screenWidth - 144
                                                                   ) style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    [mainView addSubview:self.tableView];
    NSMutableArray *scopes = [[NSMutableArray alloc]initWithCapacity:1];
    [scopes addObject:@"All"];
    
    NSArray *filters = [[Configuration getSubtypeInfo:self.subtype] getFilters:YES];
    for (ConfigFilter *filter in filters) {
        [scopes addObject:[EvaluateTools translateWithPrefix:filter.name prefix:@"FILTER_"]];
    }
    
    
    // Create the search bar
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
    [searchBar setScopeButtonTitles:[NSArray arrayWithArray:(NSArray *)scopes]];
    [searchBar setShowsScopeBar:NO];
     searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [searchBar setDelegate:self];
    [mainView addSubview:searchBar];
    
    UISearchDisplayController *sdc = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    [sdc setDelegate:self];
    [sdc setSearchResultsDataSource:self];
    [sdc setSearchResultsDelegate:self];

    // sets the view
    [self setView:mainView];
    
    [self refreshList:Nil scope:nil];

   
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

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}


- (void)dealloc {
    [self.groups release];
    [super dealloc];
}


- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	NSString *query = self.searchDisplayController.searchBar.text;
    [self refreshList:query scope:scope];
	
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{

    NSString *scopetext;
    if ([self.searchDisplayController.searchBar selectedScopeButtonIndex] > 0) {
        NSArray *filters = [[Configuration getSubtypeInfo:self.subtype] getFilters:YES];
        int i = 0;
        for (ConfigFilter *filter in filters) {
            if (i == [self.searchDisplayController.searchBar selectedScopeButtonIndex]-1) {
                scopetext = filter.name;
                break;
            }
            i++;
        }
    } else {
        
        scopetext = [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
        
    }
    
	[self filterContentForSearchText:searchString scope:scopetext];
	// Return YES to cause the search result table view to be reloaded.
	return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    
    NSString *scopetext;
    if (searchOption > 0) {
        int i = 0;
        NSArray *filters = [[Configuration getSubtypeInfo:self.subtype] getFilters:YES];
        for (ConfigFilter *filter in filters) {
            if (i == [self.searchDisplayController.searchBar selectedScopeButtonIndex]-1) {
                scopetext = filter.name;
                break;
            }
            i++;
        }
    } else {
        scopetext = [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption];
    }
    
	[self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:scopetext];
	// Return YES to cause the search result table view to be reloaded.
	return YES;
}


- (void)refreshList:(NSString *)search scope:(NSString *)scope {
    
    NSObject <EntityInfo> *info = [Configuration getInfo:entity];  
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:self.subtype];
    NSDictionary *fields = [FieldsManager list:self.entity];
    if ([info canCreate] && [fields count]>0) {
        self.addBtn.enabled = YES;
    }
    [fields release];
    
    NSMutableArray *criterias = [[NSMutableArray alloc] initWithCapacity:1];
    if (search != nil && scope!=nil) {
        NSObject <Criteria> *searchCriteria; 
        NSObject <Criteria> *search2Criteria;
        if ([Configuration isYes:@"wildcardSearch"]) {
            searchCriteria = [[ContainsCriteria alloc] initWithColumn:@"search" value:search];
            search2Criteria = [[ContainsCriteria alloc] initWithColumn:@"search2" value:search];
        } else {
            searchCriteria = [[LikeCriteria alloc] initWithColumn:@"search" value:search];
            search2Criteria = [[LikeCriteria alloc] initWithColumn:@"search2" value:search];
        }
        if ([[Configuration getInfo:self.entity] searchField2]!=nil) {
            OrCriteria *orCriteria = [[OrCriteria alloc] 
                    initWithCriteria1: searchCriteria
                    criteria2: search2Criteria];
            [criterias addObject:orCriteria];
            [orCriteria release];
        } else {
            [criterias addObject:searchCriteria];
        }    
        if (![scope isEqualToString:@"All"]) {
            
            for (ConfigFilter *filter in [sinfo getFilters:YES]) {
                if ([filter.name isEqualToString:scope]) {
                    [criterias addObject:filter.criteria];
                }
            }           
        }
        
    }
    
    NSArray *items = [EntityManager list:self.subtype entity:self.entity criterias:criterias];
    [self.groups release];
    self.groups = [GroupManager getGroups:self.subtype items:items];
    [self.tableView reloadData];  
    [items release];
}

- (void)mustUpdate {

    if ([self.searchDisplayController isActive]) {
        NSString *searchText=[self.searchDisplayController.searchBar text];
        [self.searchDisplayController.searchBar setText:searchText];
    }else{
        [self refreshList:nil scope:nil];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [self refreshList:Nil scope:nil];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    Group *group = [groups objectAtIndex:section];
    return group.name;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Group *group = [groups objectAtIndex:indexPath.section];
    Item *item = [group.items objectAtIndex:indexPath.row];
    
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	// Configure the cell...
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:self.subtype];
	cell.textLabel.text = [sinfo getDisplayText:item];
    cell.detailTextLabel.text = [sinfo getDetailText:item];
    NSString *icon = [sinfo getIcon:item];
    
    if (icon != Nil) {
        cell.imageView.image = [UIImage imageNamed:icon];
    } else {
        cell.imageView.image = nil;
    }
    
    while ([cell.contentView.subviews count] > 0) {
        [[cell.contentView.subviews objectAtIndex:0] removeFromSuperview];
    }
    if ([[item.fields objectForKey:@"favorite"]isEqualToString:@"1"]) {
        UIImageView *star = [[UIImageView alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width - 40 ,4, 32, 32)];
        star.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [star setImage:[UIImage imageNamed:@"btn_star_big_on.png"]];
        [cell.contentView addSubview:star];
        [star release];
    }else{
        [cell setAccessoryView:nil];
    }
    
    UIView *bg = [[UIView alloc] initWithFrame:cell.frame];
    
    if ([[item.fields objectForKey:@"modified"] isEqualToString:@"1"] && [item.fields objectForKey:@"Id"] !=nil ) {        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"row_updated.png"]];
        [imageView setFrame:CGRectMake(0, 0, 12, 12)];
        [bg addSubview:imageView];
        [imageView release];
        
    } else if ([[item.fields objectForKey:@"modified"] isEqualToString:@"1"] && [item.fields objectForKey:@"Id"] == nil){
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"row_new.png"]];
        [imageView setFrame:CGRectMake(0, 0, 12, 12)];
        [bg addSubview:imageView];
        [imageView release];
        
    } else if ([item.fields objectForKey:@"error"] != nil) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"row_error.png"]];
        [imageView setFrame:CGRectMake(0, 0, 12, 12)];
        [bg addSubview:imageView];
        [imageView release];
    }
    
    cell.backgroundView = bg;
    [bg release];
    
    return cell;
}

- (IBAction)addNew:(id)sender {
    Item *newItem = [[Item alloc] init:self.entity fields:[[NSMutableDictionary alloc] initWithCapacity:1]];
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:self.subtype];
    [sinfo fillItem:newItem];
    EditingViewController *addViewController = [[EditingViewController alloc] initWithItem:newItem updateListener:self isCreate:YES];
    [self.navigationController pushViewController:addViewController animated:YES];
    [addViewController release];
    [newItem release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    Group *group = [groups objectAtIndex:indexPath.section];
    Item *item = [group.items objectAtIndex:indexPath.row];
    DetailViewController *detailController = [[DetailViewController alloc] initWithItem:item listener:self];
    [self.navigationController pushViewController:detailController animated:YES];

    [detailController release];
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if ([groups count] == 0 || [groups count] > 30) {
        return Nil;
    }
    for (Group *group in self.groups) {
        if ([group.name length] > 1) {
            return Nil;
        }
    }
    
    NSMutableArray *index = [[NSMutableArray alloc] initWithCapacity:1];
    for (Group *group in self.groups) {
        [index addObject:group.name]; 
    }
    return index;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}



@end

