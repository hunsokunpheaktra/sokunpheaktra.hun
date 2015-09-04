//
//  SearchDataViewController.m
//  Pactrac2me
//
//  Created by Hun Sokunpheaktra on 3/6/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "SearchDataViewController.h"
#import "ProviderManager.h"

@implementation SearchDataViewController

@synthesize listContent;

-(id)initWithListener:(NSObject<UpdateListener>*)update item:(Item*)item
{
    self = [super initWithStyle:UITableViewStylePlain];
    self.listContent = [[NSMutableArray alloc] initWithCapacity:1];
    self.updateListener = update;
    self.item = item;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    searchBar.delegate = self;
    searchBar.placeholder = @"Tracking Number";
    searchBar.showsCancelButton = YES;
    
    for(UIView *view in searchBar.subviews){
        if([view isKindOfClass:[UITextField class]]){
            self.textField = (UITextField*)view;
            self.textField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        }
    }
    
    CGRect frame = [UIScreen mainScreen].bounds;
    UIToolbar *toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 44)] autorelease];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIBarButtonItem *letter = [[[UIBarButtonItem alloc] initWithTitle:@"a,b,c" style:UIBarButtonItemStyleBordered target:self action:@selector(changeLetterKeyboard)] autorelease];
    UIBarButtonItem *number = [[[UIBarButtonItem alloc] initWithTitle:@"1,2,3" style:UIBarButtonItemStyleBordered target:self action:@selector(changeNumberKeyboard)] autorelease];
    UIBarButtonItem *space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil] autorelease];
    UIBarButtonItem *scan = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(scanBarcode)] autorelease];
    scan.style = UIBarButtonItemStyleBordered;
    UIBarButtonItem *done = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)] autorelease];
    
    toolbar.items = [NSArray arrayWithObjects:letter,number,space,scan,done, nil];
    
    self.textField.inputAccessoryView = toolbar;
    self.tableView.tableHeaderView = searchBar;

    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDisplayController.searchBar.showsCancelButton = YES;
    [searchDisplayController.searchBar becomeFirstResponder];
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsTableView.backgroundColor = [UIColor whiteColor];
    searchDisplayController.searchResultsTableView.scrollEnabled = YES;
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchBar.text = [self.item.fields objectForKey:@"trackingNo"];
    
	// Do any additional setup after loading the view.
}

-(void)changeLetterKeyboard{
    self.textField.keyboardType = UIKeyboardTypeDefault;
    [self.textField resignFirstResponder];
    [self.textField becomeFirstResponder];
}
-(void)changeNumberKeyboard{
    self.textField.keyboardType = UIKeyboardTypeNumberPad;
    [self.textField resignFirstResponder];
    [self.textField becomeFirstResponder];
}
-(void)scanBarcode{
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    
    ZBarImageScanner *scanner = reader.scanner;
    [scanner setSymbology: ZBAR_I25 config: ZBAR_CFG_ENABLE to: 0];
    
    // present and release the controller
    [self presentModalViewController:reader animated: YES];
    [reader release];

}
-(void)done{
    
    [self.item.fields setObject:searchDisplayController.searchBar.text forKey:@"trackingNo"];
    [self.updateListener mustUpdate:self.item];
    [self dismissModalViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return listContent.count;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIndentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    cell.textLabel.text = [listContent objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegates

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.item.fields setObject:searchDisplayController.searchBar.text forKey:@"trackingNo"];
    [self.item.fields setObject:[listContent objectAtIndex:indexPath.row] forKey:@"forwarder"];
    [self.updateListener mustUpdate:self.item];
    [self dismissModalViewControllerAnimated:YES];
    
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)_searchBar
{
	[searchDisplayController.searchBar setShowsCancelButton:NO];
}

-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    [self filterContentForSearchText:[NSString stringWithFormat:@"%@%@",searchBar.text,text] scope:@""];
    return YES;
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    searchDisplayController.active = YES;
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar
{
	searchDisplayController.active = NO;
	[self.tableView reloadData];
    [self dismissModalViewControllerAnimated:YES];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
	searchDisplayController.active = NO;
	[self.tableView reloadData];
    [self dismissModalViewControllerAnimated:YES];
    
}

#pragma mark -
#pragma mark UISearchDisplayControllerDelegate

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    
    [self.listContent removeAllObjects];
    self.listContent = [NSMutableArray arrayWithArray:[ProviderManager checkTrackingNumber:searchText]];
    [searchDisplayController.searchResultsTableView reloadData];
    
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
    [[searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
    [[searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    return YES;
}

#pragma UIImagePickerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    if([picker isKindOfClass:[ZBarReaderViewController class]]){
        
        // ADD: get the decode results
        id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
        ZBarSymbol *symbol = nil;
        for(symbol in results)
            break;
        
        [self.item.fields setObject:symbol.data forKey:@"trackingNo"];
        searchDisplayController.searchBar.text = symbol.data;
        
    }
    
    [picker dismissModalViewControllerAnimated:YES];
    
}


@end
