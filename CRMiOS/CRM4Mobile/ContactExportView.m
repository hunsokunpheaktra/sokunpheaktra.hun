//
//  ContactExportView.m
//  CRMiOS
//
//  Created by Sy Pauv on 9/16/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "ContactExportView.h"


@implementation ContactExportView

@synthesize popoverController,mytable,listData,nameFilter,selectedContact;

- (void)dealloc
{
    [selectedContact release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    self.title=NSLocalizedString(@"EXPORT_ADDRESS_BOOK", @"export address book");
    self.selectedContact = [[NSMutableDictionary alloc]initWithCapacity:1];
    
    UIView *mainView = [[UIView alloc] init];
    // Create the list
    self.mytable = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 0, 400) style:UITableViewStylePlain];
    self.mytable.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.mytable setDelegate:self];
    [self.mytable setDataSource:self];
    [mainView addSubview:self.mytable];
    
    // Create the search bar
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
    [searchBar setShowsScopeBar:NO];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [searchBar setDelegate:self];
    [mainView addSubview:searchBar];
    // sets the view
    [self setView:mainView];
    
    UIBarButtonItem *export = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"EXPORT", @"button label") style:UIBarButtonItemStyleDone target:self action:@selector(doExportAll:)];
    self.navigationItem.rightBarButtonItem=export;
    [self filterData];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.listData count];
}



// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = [self.mytable dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
        // Configure the cell...
        Item *data=[self.listData objectAtIndex:indexPath.row];
        [cell.textLabel setTextColor:[UIColor darkTextColor]];
        NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:@"Contact"];
        cell.textLabel.text = [sinfo getDisplayText:data];
        cell.detailTextLabel.text = [sinfo getDetailText:data];
        NSString *icon = [sinfo getIcon:data];
        
        if (icon != Nil) {
            cell.imageView.image = [UIImage imageNamed:icon];
        } else {
            cell.imageView.image = Nil;
        }

    Item *selected=[self.selectedContact objectForKey:[data.fields objectForKey:@"Id"]];
    
    if (selected!=nil) {
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType=UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    Item *data=[self.listData objectAtIndex:indexPath.row];
    
    Item *selected=[selectedContact objectForKey:[data.fields objectForKey:@"Id"]];
    if (selected!=nil) {
        
        [selectedContact removeObjectForKey:[data.fields objectForKey:@"Id"]];
        
    }else{
        
        [selectedContact setObject:data forKey:[data.fields objectForKey:@"Id"]];
        
    }
    [self.mytable reloadData];
}

- (void)filterData {

    NSMutableArray *filters = [[NSMutableArray alloc] initWithCapacity:1];
    
    if ([nameFilter length] > 0) {
        [filters addObject:[[LikeCriteria alloc] initWithColumn:@"search" value:nameFilter]];
    }
    
    NSMutableArray *tmplist = [[NSMutableArray alloc]initWithCapacity:1];
    for (Item *tmpitem in [EntityManager list:@"Contact" entity:@"Contact" criterias:filters]) {
        if ([tmpitem.fields objectForKey:@"Id"]!=nil) {
            [tmplist addObject:tmpitem];
        }
    }
    self.listData=(NSArray *)tmplist;
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
    self.nameFilter = searchText;
    [self filterData];
    [self.mytable reloadData];
}

-(void)showpopup:(UIButton *)button parent:(UIView *)parent{
     
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
    //resize the popover view shown
    //in the current view to the view's size
    self.contentSizeForViewInPopover =
    CGSizeMake(600, 450);
    
    //create a popover controller
    self.popoverController = [[UIPopoverController alloc]
                              initWithContentViewController:popoverContent];
    //present the popover view non-modal with a
    //refrence to the toolbar button which was pressed
    CGRect rect = [button.superview convertRect:button.frame toView:parent];
    [self.popoverController presentPopoverFromRect:rect inView:parent permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [popoverContent release];


}

- (void)doExportAll:(id)sender{
    int count=0;
    
    for (NSString *key in [selectedContact keyEnumerator]) {
        
        Item *item=[selectedContact objectForKey:key];
        ABRecordRef person=[[MergeContacts getInstance] checkExistingContact:item];
        if (person==nil) {
            [[MergeContacts getInstance]insertContact:item isUpdate:NO];
        }else{
            [[MergeContacts getInstance]updateContact:item person:person];
        }
        
        if ([[MergeContacts getInstance] checkExistingContact:item]!=nil) {
            count++;
        }
        
    }
    
    NSString *message=@"";
    if (count>0) {
        message=[NSString stringWithFormat:@"%i contacts exported.",count];
    }else{
        message=@"No contacts to export.";
    }
       
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"EXPORT_ADDRESS_BOOK", @"export address book") message:message delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"ok") otherButtonTitles: nil];
    [alert show];
    [alert release];
        
    [selectedContact removeAllObjects];
    [self.mytable reloadData];
    
}
@end
