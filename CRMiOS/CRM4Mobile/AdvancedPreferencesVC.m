//
//  SyncFiltersViewController.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/25/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "AdvancedPreferencesVC.h"

@implementation AdvancedPreferencesVC

@synthesize entities;
@synthesize mergePhone;
@synthesize btnReinitDB;
@synthesize preferences,otherProperty;


- (id)initWithPreference:(NSObject<UpdateListener> *)newupdate
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.preferences = newupdate;
        self.entities = [[NSMutableArray alloc] initWithCapacity:1];
        for (NSString *entity in  [Configuration getEntities]) {
            if ([[[Configuration getInfo:entity] getSubtypes] count] > 0) {
                [self.entities addObject:entity];
            }
        }
        self.title = NSLocalizedString(@"ADVANCED", @"advance screen's label");
        self.mergePhone = [PropertyManager read: @"mergeContact"];
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 70)];
        btnReinitDB = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnReinitDB setBackgroundImage:[[UIImage imageNamed:@"delete_button.png"] stretchableImageWithLeftCapWidth:8.0f topCapHeight:0.0f] forState:UIControlStateNormal];
        [btnReinitDB setTitle:NSLocalizedString(@"REINIT_DATABASE", @"reinit database button's label") forState:UIControlStateNormal];
        [btnReinitDB setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnReinitDB.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        btnReinitDB.titleLabel.shadowColor = [UIColor lightGrayColor];
        btnReinitDB.titleLabel.shadowOffset = CGSizeMake(0, -1);
        [btnReinitDB setFrame:CGRectMake(0,0, self.view.frame.size.width - 20, 44)];
        btnReinitDB.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [btnReinitDB addTarget:self action:@selector(reInitDB) forControlEvents:UIControlEventTouchDown];
        btnReinitDB.center=footerView.center;
        [footerView addSubview:btnReinitDB];
        [self.tableView setTableFooterView:footerView];
        
        [self initOtherProperty];
        
        
        
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

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [entities count];
    } else{
        return [otherProperty  count];
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"FILTERS", @"section header filter");
    } else {
        return NSLocalizedString(@"OTHER", @"section header other");
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1&&[[self.otherProperty objectAtIndex:indexPath.row] isEqualToString:@"XMLNAME"])return 70.0;
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.imageView.image=nil;
    
    if (indexPath.section == 0) {
        [cell setAccessoryView:nil];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        NSString *entity = [entities objectAtIndex:indexPath.row];
        NSMutableString *lblText = [[NSMutableString alloc] initWithCapacity:1];
        for (NSObject <Subtype> *sinfo in [[Configuration getInfo:entity] getSubtypes]) {
            if ([lblText length] > 0) {
                [lblText appendString:@" / "];
            }
            [lblText appendString:[sinfo localizedPluralName]];
        }
        
        if ([[PropertyManager read:[NSString stringWithFormat:@"sync%@", entity]] isEqualToString:@"true"]) {
            cell.imageView.image = [UIImage imageNamed:@"checkmark.png"];
        }else{
            cell.imageView.image = [UIImage imageNamed:@"null.png"];
        }
        cell.textLabel.text = lblText;
    } else{
        //cell.imageView.image = nil;
        
        [[cell imageView] setImage:nil];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        NSString *other=[self.otherProperty objectAtIndex:indexPath.row];
        
        if ([other isEqualToString:@"EXPORT_CONTACT"]) {
            
            UIButton *export = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [export setTitle:@"EXPORT" forState:UIControlStateNormal];
            export.tag = indexPath.row;
            [export setHidden:[PropertyManager read:@"PreviousSyncStart"] == nil];
            [export setFrame:CGRectMake(0,0, 95, 30)];
            [export addTarget:self action:@selector(exportContact:) forControlEvents:UIControlEventTouchDown];
            [cell setAccessoryView:export];
            [cell.textLabel setText:NSLocalizedString(@"EXPORT_ADDRESS_BOOK",@"export address book")];
        } else if([other isEqualToString:@"IMPORT_CONTACT"]) {
            
            UIButton *btnImport = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [btnImport setTitle:NSLocalizedString(@"IMPORT", @"import button's label") forState:UIControlStateNormal];
            btnImport.tag = indexPath.row;
            [btnImport setHidden:[PropertyManager read:@"PreviousSyncStart"] == nil];
            [btnImport setFrame:CGRectMake(0,0, 95, 30)];
            [cell setAccessoryView:btnImport];
            [cell.textLabel setText:NSLocalizedString(@"IMPORT_ADDRESS_BOOK", @"import address book")];
            [btnImport addTarget:self action:@selector(importContact:) forControlEvents:UIControlEventTouchDown];
            
        } else if([other isEqualToString:@"XMLNAME"]) {
            
            UITextField *txtRemote = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
            txtRemote.borderStyle = UITextBorderStyleRoundedRect;
            txtRemote.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            txtRemote.delegate = self;
            txtRemote.text = [PropertyManager read:@"xmlName"];
            txtRemote.autocorrectionType = UITextAutocorrectionTypeNo;
            txtRemote.autocapitalizationType = UITextAutocapitalizationTypeNone;
            cell.accessoryView = txtRemote;
            cell.textLabel.numberOfLines = 3;
            cell.textLabel.text = NSLocalizedString(@"REMOTE_CONFIG_FILE", @"Remote xml file name");
            
        } else if ([other isEqualToString:@"STARTUP_SYNC"]){
            
            // Start up Config
            [cell.textLabel setText:NSLocalizedString(@"AUTO_SYNC", nil)];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if ([other isEqualToString:@"SORTING_CONTACT"]) {
            
            [cell.textLabel setText:NSLocalizedString(@"CONTACT_SORTING", nil)];
            cell.textLabel.numberOfLines=3;
            UISegmentedControl *option = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"FIRST_NAME", nil), NSLocalizedString(@"LAST_NAME", nil), nil]];
            [option sizeToFit];
            CGRect rect = [option frame];
            rect.size.height=30;
            rect.size.width-=20;
            option.frame = rect;
            
            [option setSelectedSegmentIndex:[[PropertyManager read:@"SortingContact"] isEqualToString:@"FirstName"] ? 0 : 1];
            [option addTarget:self action:@selector(optionchange:) forControlEvents:UIControlEventValueChanged];
            [cell setAccessoryView:option];
            [option release];
            
        } else if ([other isEqualToString:@"SUBSCRIPT"]) {
            
            
            [cell.textLabel setText:NSLocalizedString(@"Subscription", nil)];
            UIButton *subscript = [UIButton buttonWithType:UIButtonTypeCustom];
            [subscript setBackgroundImage:[[UIImage imageNamed:@"button.png"] stretchableImageWithLeftCapWidth:8.0f topCapHeight:0.0f] forState:UIControlStateNormal];
            [subscript setTitle:@"Subscript Now" forState:UIControlStateNormal];
            [subscript  setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            subscript.titleLabel.font = [UIFont boldSystemFontOfSize:20];
            subscript.titleLabel.shadowColor = [UIColor lightGrayColor];
            subscript.titleLabel.shadowOffset = CGSizeMake(0, -1);
            [subscript sizeToFit];
            
            CGRect rect=subscript.frame;
            rect.size.width+=20;
            rect.size.height=40;
            subscript.frame=rect;
            
            [subscript addTarget:self action:@selector(buyNow:) forControlEvents:UIControlEventTouchUpInside];
            [cell setAccessoryView:subscript];
            
            
        }
    }
    return cell;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    
    [PropertyManager save:@"xmlName" value:textField.text];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        DetailFilterViewController *detailViewController = [[DetailFilterViewController alloc] initWithEntity:[self.entities objectAtIndex:indexPath.row] parent:self];
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];
    } else {
        NSString *other = [self.otherProperty objectAtIndex:indexPath.row];
        if ([other isEqualToString:@"STARTUP_SYNC"]) {
            AutoSyncDelayVC *autoSyncVC = [[AutoSyncDelayVC alloc] init];
            [self.navigationController pushViewController:autoSyncVC animated:YES];
            [autoSyncVC release];
        }
    }
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// use "buttonIndex" to decide your action
	//
    if (buttonIndex == 0) {
        
        Database *db = [Database getInstance];
        [db deleteDatabase];
        [db initDatabase];
        
        AlertViewTool *alert = [[AlertViewTool alloc] initWithDatabase:db parentView:nil tabLayout:(CRMAppDelegate *)[[UIApplication sharedApplication] delegate]];
        [alert loadEncryptedDatabase];
        [self presentModalViewController:alert animated:YES];
        
        
	} 
}

- (void)mustUpdate {
    [self.tableView reloadData];
}

- (void)importContact:(id)sender {
    [[MergeContacts getInstance]importToContact];
    [[SyncController getInstance] syncProgress:@"Contact"];
}

- (void)exportContact:(id)sender {
    
    ContactExportView *contactExport=[[ContactExportView alloc]init];
    [self.navigationController pushViewController:contactExport animated:YES];
    [contactExport release];
    
}

- (void)reInitDB{
    // open a alert with an OK and cancel button
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DELETE_DB_CONFIRM",nil) message:nil
                                                   delegate:self cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:NSLocalizedString(@"CANCEL", nil), nil];
	[alert show];
	[alert release];
}


- (void)optionchange:(id)sender {
    
    UISegmentedControl *option = (UISegmentedControl *)sender;
    switch (option.selectedSegmentIndex) {
        case 0:
            [PropertyManager save:@"SortingContact" value:@"FirstName"];
            break;
        case 1:
            [PropertyManager save:@"SortingContact" value:@"LastName"];
            break;
    }
    // refresh contact list
    CRMAppDelegate *appDelegate = (CRMAppDelegate *)[UIApplication sharedApplication].delegate;
    for (NamedNavigationController *navController in appDelegate.tabBarController.viewControllers) {
        if ([[navController name] isEqualToString:@"Contact"]) {
            if ([[navController viewControllers] count] > 0) {
                ListViewController *listVC = [[navController viewControllers] objectAtIndex:0];
                [listVC refreshList:nil scope:nil];
            }
        }
    }    
    // refresh contact list when it is in More...
    for (UIViewController *viewController in appDelegate.tabBarController.moreNavigationController.viewControllers) {
        if ([viewController isKindOfClass:[ListViewController class]]) {
            ListViewController *listVC = (ListViewController *)viewController;
            if ([listVC.entity isEqualToString:@"Contact"]) {
                [listVC refreshList:nil scope:nil];
            }
        }
    }
    
}

- (void)initOtherProperty {
    
    self.otherProperty=[[NSMutableArray alloc]initWithCapacity:1];
    [otherProperty addObject:@"XMLNAME"];
    [otherProperty addObject:@"STARTUP_SYNC"];
    //if(![[NSUserDefaults standardUserDefaults] boolForKey:@"isCRM4MobilePurchased"])[otherProperty addObject:@"SUBSCRIPT"];
    [otherProperty addObject:@"SORTING_CONTACT"];
    if([Configuration isYes:@"mergeAddressBookEnabled"] && [PropertyManager read:@"PreviousSyncStart"]){
        [otherProperty addObject:@"EXPORT_CONTACT"];
        [otherProperty addObject:@"IMPORT_CONTACT"];    
    }
}

- (void)buyNow:(id)sender{
    
    AppPurchaseManager *purchase=[[AppPurchaseManager alloc]initwithView:self];
    [purchase loadStore];
    
}


@end
