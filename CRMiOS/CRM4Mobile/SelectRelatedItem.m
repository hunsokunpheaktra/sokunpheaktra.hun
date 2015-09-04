//
//  SelectRelatedItem.m
//  CRMiOS
//
//  Created by Sy Pauv on 7/18/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "SelectRelatedItem.h"


@implementation SelectRelatedItem

@synthesize updateListener, code, item, entity;
@synthesize myTableView;
@synthesize listObject;
@synthesize filter;

- (id)init:(NSString *)newField item:(Item *)newItem updateListener:(NSObject<UpdateListener> *)newListener {
    self.item = newItem;
    self.updateListener = newListener;
    self.code = newField;
    NSString *subtype = [Configuration getSubtype:self.item];
    self.entity = [RelationManager getRelatedEntity:subtype field:self.code];
    [self searchItems];
    return [super init];
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

- (void)loadView
{
   
    self.title = [EvaluateTools removeIdSuffix:[FieldsManager read:self.item.entity field:self.code].displayName];
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    // Create the list
    self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 200, 156) style:UITableViewStylePlain];
    self.myTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.myTableView setDelegate:self];
    [self.myTableView setDataSource:self];
    
    [mainView addSubview:self.myTableView];
  
    // Create the search bar
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
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

    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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
    return [listObject count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
  
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.row==0) {
        
        [cell.textLabel setTextColor:[UIColor grayColor]];
        cell.textLabel.text = [self.listObject objectAtIndex:indexPath.row];
        
        if ([[self.item.fields objectForKey:code] isEqualToString:@""]||[self.item.fields objectForKey:code]==nil) {
             cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } 
        
    }else{
        
        // Configure the cell...
        Item *data=[self.listObject objectAtIndex:indexPath.row];
        [cell.textLabel setTextColor:[UIColor darkTextColor]];
        NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:self.entity];
        cell.textLabel.text = [sinfo getDisplayText:data];
        cell.detailTextLabel.text = [sinfo getDetailText:data];

        if ([[data.fields objectForKey:@"Id"] isEqualToString:[self.item.fields objectForKey:code]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *value = @"";
    if (indexPath.row==0) {
        value = @"";
    } else {
        Item *data=[self.listObject objectAtIndex:indexPath.row];   
        value=[data.fields objectForKey:@"Id"];

    }

    [item.fields setValue:value forKey:code];    
    [self.updateListener mustUpdate];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)searchItems {
    
    NSMutableArray *filters = [[NSMutableArray alloc] initWithCapacity:1];
    
    if ([filter length] > 0) {
        [filters addObject:[[LikeCriteria alloc] initWithColumn:@"search" value:filter]];
    }
    NSMutableArray *tmplist = [[NSMutableArray alloc]initWithCapacity:1];
    [tmplist addObject:@"No Value"];
    for (Item *tmpitem in [EntityManager list:self.entity entity:self.entity criterias:filters]) {
        [tmplist addObject:tmpitem];
    }
    self.listObject = (NSArray *)tmplist;
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
    self.filter = searchText;
    [self searchItems];
    [self.myTableView reloadData];
}


@end
