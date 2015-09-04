//
//  PadSyncFiltersView.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 1/25/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "PadSyncFiltersView.h"
#import "AutoSyncPopupViewController.h"

@implementation PadSyncFiltersView


@synthesize entities;
@synthesize btnReinitDB;
@synthesize mergeContact;
@synthesize mergeBtn;
@synthesize urlLabel;
@synthesize displayFields;
@synthesize footerViews;
@synthesize otherProperty;


- (id)init
{
    self = [super init];
    if (self) {
        self.footerViews = [[NSMutableDictionary alloc] initWithCapacity:1];
        self.title = NSLocalizedString(@"ADVANCED", @"Preferences");
        self.mergeContact = [PropertyManager read: @"mergeContact"];
        mergeBtn = [[UISwitch alloc] init];
        [mergeBtn setOn:[self.mergeContact isEqualToString:@"true"]];
        [mergeBtn addTarget:self action:@selector(switchChangedBtnMerge:) forControlEvents:UIControlEventValueChanged];
        
        self.entities = [[NSMutableArray alloc] initWithCapacity:1];
        for (NSString *entity in [Configuration getEntities]) {
            if (![entity isEqualToString:@"User"]) {
                [self.entities addObject:entity];
            }
        }
        self.tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStyleGrouped];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.tableView setDelegate:self];
        [self.tableView setDataSource:self];
        
               
        self.urlLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 35, 500, 30)];
        self.urlLabel.backgroundColor=[UIColor clearColor];
        self.urlLabel.font=[UIFont systemFontOfSize:16];

        
        [self initOtherProperty];
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];
        [footerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.tableView setTableFooterView:footerView];

        self.btnReinitDB = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnReinitDB setBackgroundImage:[[UIImage imageNamed:@"delete_button.png"] stretchableImageWithLeftCapWidth:8.0f topCapHeight:0.0f] forState:UIControlStateNormal];
        [self.btnReinitDB setTitle:NSLocalizedString(@"REINIT_DATABASE", @"reinit database button's label") forState:UIControlStateNormal];
        [self.btnReinitDB  setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.btnReinitDB.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        self.btnReinitDB.titleLabel.shadowColor = [UIColor lightGrayColor];
        self.btnReinitDB.titleLabel.shadowOffset = CGSizeMake(0, -1);
        [self.btnReinitDB sizeToFit];
        CGRect rect=btnReinitDB.frame;
        rect.origin.x=250;
        rect.size.width+=100;
        rect.size.height=50;
        [self.btnReinitDB  setFrame:rect];
        self.btnReinitDB.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.btnReinitDB  addTarget:self action:@selector(reInitDB) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:btnReinitDB];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
         return NSLocalizedString(@"ENTITIES",nil);
    } else if (section == 1) {
        return NSLocalizedString(@"OTHER", nil);
    } 
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // CH : Add Merge Address Book
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return [entities count];
    }else{
        return [otherProperty count];
    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    // empty the cell contents
    while ([cell.contentView.subviews count] > 0) {
        [[cell.contentView.subviews objectAtIndex:0] removeFromSuperview];
    }
    
    if (indexPath.section == 0) {
        
        // Entity
        NSString *entity = [entities objectAtIndex:indexPath.row];
        UIView *filterButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
        [filterButtonView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [filterButtonView setContentMode:UIViewContentModeCenter];
        
        UIButton *btnOwnerFilter = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        NSString *ownerFilter = [PropertyManager read:[NSString stringWithFormat:@"ownerFilter%@", entity]];
        [btnOwnerFilter setTitle:ownerFilter forState:UIControlStateNormal];
        btnOwnerFilter.tag = indexPath.row;
        [btnOwnerFilter setFrame:CGRectMake(320, 10, 100, 30)];
        [btnOwnerFilter addTarget:self action:@selector(showOwnerFilter:) forControlEvents:UIControlEventTouchDown];
        [filterButtonView addSubview:btnOwnerFilter];
        
        UIButton *btnDateFilter = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        NSString *dateFilter = [PropertyManager read:[NSString stringWithFormat:@"dateFilter%@", entity]];
        [btnDateFilter setTitle:dateFilter forState:UIControlStateNormal];
        btnDateFilter.tag = indexPath.row;
        [btnDateFilter setFrame:CGRectMake(440, 10, 100, 30)];
        [btnDateFilter addTarget:self action:@selector(showDateFilter:) forControlEvents:UIControlEventTouchDown];
        [filterButtonView addSubview:btnDateFilter];
        
        NSMutableString *lblText = [[NSMutableString alloc] initWithCapacity:1];
        for (NSObject <Subtype> *sinfo in [[Configuration getInfo:entity] getSubtypes]) {
            if ([lblText length] > 0) {
                [lblText appendString:@" / "];
            }
            [lblText appendString:[sinfo localizedPluralName]];
        }
        if ([lblText length] == 0) {
            [lblText appendString:entity];
        }
        UILabel *filterLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 300, 22)];
        [filterLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [filterLabel setText:lblText];
        [filterLabel setOpaque:NO];
        [filterLabel setBackgroundColor:[UIColor clearColor]];
        [filterButtonView addSubview:filterLabel];
        
        [cell.contentView addSubview:filterButtonView];
        
        
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        cell.accessoryView = switchView;
        switchView.tag = indexPath.row;
        NSString *value = [PropertyManager read:[NSString stringWithFormat:@"sync%@", entity]];
        
        [switchView setOn:[value isEqualToString:@"true"] animated:NO];
        
        [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        [switchView release];
        
    }  else{
        // Other
        
        NSString *other=[self.otherProperty objectAtIndex:indexPath.row];
        if ([other isEqualToString:@"XMLNAME"]) {
            
            txtRemote = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 235, 30)];
            txtRemote.borderStyle = UITextBorderStyleRoundedRect;
            txtRemote.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            txtRemote.delegate = self;
            txtRemote.text = [PropertyManager read:@"xmlName"];
            txtRemote.autocorrectionType = UITextAutocorrectionTypeNo;
            txtRemote.autocapitalizationType = UITextAutocapitalizationTypeNone;
            
            cell.accessoryView = txtRemote;
            cell.textLabel.text = NSLocalizedString(@"REMOTE_CONFIG_FILE", @"Remote xml file name");
        } else if ([other isEqualToString:@"STARTUP_SYNC"]) {
            // Start up Config
            
            //change from switch to popup picklist
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell.textLabel setText:NSLocalizedString(@"AUTO_SYNC", nil)];
            
            cell.detailTextLabel.text = [SyncTools getDelayDisplayValue:[PropertyManager read:@"SyncAtStartup"]];

             
        } else if ([other isEqualToString:@"SORTING_CONTACT"]) {
            
            [cell.textLabel setText:NSLocalizedString(@"CONTACT_SORTING", nil)];
            UISegmentedControl *option = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"FIRST_NAME", nil), NSLocalizedString(@"LAST_NAME", nil), nil]];
            [option sizeToFit];
            CGRect rect = [option frame];
            rect.size.height = 35;
            option.frame = rect;
            [option setSelectedSegmentIndex:[[PropertyManager read:@"SortingContact"] isEqualToString:@"FirstName"] ? 0 : 1];
            [option addTarget:self action:@selector(optionchange:) forControlEvents:UIControlEventValueChanged];
            [cell setAccessoryView:option];
            [option release];
            
        } else if ([other isEqualToString:@"IMPORT_CONTACT"]) {
            
            UIButton *btnImport = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [btnImport setTitle:NSLocalizedString(@"IMPORT", nil) forState:UIControlStateNormal];
            btnImport.tag = indexPath.row;
            [btnImport sizeToFit];
            [btnImport addTarget:self action:@selector(importContact:) forControlEvents:UIControlEventTouchDown];
            [cell setAccessoryView:btnImport];
            [cell.textLabel setText:NSLocalizedString(@"IMPORT_ADDRESS_BOOK", nil)];
            
        } else if ([other isEqualToString:@"EXPORT_CONTACT"]) {
            // CH : Add Merge Address Book
            UIButton *export = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [export setTitle:NSLocalizedString(@"EXPORT", @"export") forState:UIControlStateNormal];
            export.tag = indexPath.row;
            [export sizeToFit];
            [export addTarget:self action:@selector(exportContact:) forControlEvents:UIControlEventTouchDown];
            [cell setAccessoryView:export];
            [cell.textLabel setText:NSLocalizedString(@"EXPORT_ADDRESS_BOOK", nil)];
            
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //touch on auto sync cell
    if(indexPath.section != 0){
        NSString *other=[self.otherProperty objectAtIndex:indexPath.row];
        if ([other isEqualToString:@"STARTUP_SYNC"]) {
            
            AutoSyncPopupViewController *autoSync = [[AutoSyncPopupViewController alloc] init:[PropertyManager read:@"SyncAtStartup"]];
            [autoSync show:[tableView cellForRowAtIndexPath:indexPath] parentView:self.view];
            [autoSync release];
            
        }
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {	
	[theTextField resignFirstResponder];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == txtRemote) {
        txtRemote.text = [txtRemote.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
        [PropertyManager save:@"xmlName" value:txtRemote.text];
        
    }
}

- (void)switchChanged:(id)sender {
    
    NSString *code = [entities objectAtIndex:((UISwitch *)sender).tag];
    if (((UISwitch *)sender).on == YES) {
        [PropertyManager save:[NSString stringWithFormat:@"sync%@",code] value:@"true"];
    } else {
        //If the user deactive an object all information should be delete
        [[Database getInstance]remove:code criterias:nil];
        [PropertyManager save:[NSString stringWithFormat:@"sync%@",code] value:@"false"];
    }
    
    [PadTabTools buildTabs:self.tabBarController];
}

- (void)importContact:(id)sender {
    [[MergeContacts getInstance]importToContact];
    [[PadSyncController getInstance] syncProgress:@"Contact"];
}

- (void)showOwnerFilter:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSString *entity = [entities objectAtIndex:button.tag];
    DetailFilterPopup *filterPopup = [[DetailFilterPopup alloc] initWithEntity:entity filterType:@"true" parent:self];
    [filterPopup show:button parentView:self.view];
    [filterPopup release];
    
}

- (void)showDateFilter:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSString *entity = [entities objectAtIndex:button.tag];
    DetailFilterPopup *filterPopup = [[DetailFilterPopup alloc]initWithEntity:entity filterType:@"false" parent:self];
    [filterPopup show:button parentView:self.view];
    [filterPopup release];
}

- (void)refresh {

    [self.tableView reloadData];
    
}

- (void)filterChanged {
    
    isFilterChange = YES;
    [self showModifiedMSG];
    [self.footerViews removeAllObjects];
    [self.tableView reloadData];
    
}

- (void)switchChangedBtnMerge:(id)sender {
    self.mergeContact = [mergeBtn isOn] ? @"true" : @"false";
    [PropertyManager save: @"mergeContact" value:self.mergeContact];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// use "buttonIndex" to decide your action
	//
    if (buttonIndex == 0) {
        Database *db = [Database getInstance];
        [db deleteDatabase];
        [db initDatabase];
        
        AlertViewTool *alertTool = [[[AlertViewTool alloc] initWithDatabase:db parentView:self.view.window tabLayout:(gadgetAppDelegate *)[[UIApplication sharedApplication] delegate]] autorelease];
        [alertTool loadEncryptedDatabase];
        
	} 
}

- (void)reInitDB {
    // open a alert with an OK and cancel button
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DELETE_DB_CONFIRM",nil) message:nil
                                                   delegate:self cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:NSLocalizedString(@"CANCEL", nil), nil];
	[alert show];
	[alert release];
    
}


- (void)exportContact:(id)sender {
    
    ContactExportView *export=[[ContactExportView alloc]init];
    [export showpopup:(UIButton *)sender parent:self.view];
    [export release];
    
}


- (void)optionchange:(id)sender{
    
    UISegmentedControl *option = (UISegmentedControl *)sender;
    switch (option.selectedSegmentIndex) {
        case 0:
            [PropertyManager save:@"SortingContact" value:@"FirstName"];
            break;
        case 1:
            [PropertyManager save:@"SortingContact" value:@"LastName"];
            break;
    }
}

- (void)initOtherProperty{
    
    self.otherProperty=[[NSMutableArray alloc]initWithCapacity:1];
    [otherProperty addObject:@"XMLNAME"];
    [otherProperty addObject:@"STARTUP_SYNC"];
    //if(![[NSUserDefaults standardUserDefaults] boolForKey:@"isCRM4MobielPurchased"])[otherProperty addObject:@"SUBSCRIPT"];
    [otherProperty addObject:@"SORTING_CONTACT"];
    if([Configuration isYes:@"mergeAddressBookEnabled"] && [PropertyManager read:@"PreviousSyncStart"]){
        [otherProperty addObject:@"EXPORT_CONTACT"];
        [otherProperty addObject:@"IMPORT_CONTACT"];    
    }
    
}

- (void)showModifiedMSG {

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, isFilterChange?50:0)];
    [headerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];

    if (isFilterChange) {
        
        UITextView *textInfo = [[UITextView alloc] initWithFrame:CGRectMake(48, 10, headerView.frame.size.width, 50)];
        textInfo.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        textInfo.editable = NO;
        textInfo.font = [UIFont boldSystemFontOfSize:18];
        textInfo.textColor = [UIColor redColor];
        textInfo.text = NSLocalizedString(@"CONFIRM_SYNC", @"Confirm");
        textInfo.backgroundColor = [UIColor clearColor];
        [headerView addSubview:textInfo];
    }
    
    [self.tableView setTableHeaderView:headerView];

}


- (void)buyNow:(id)sender{
    
    AppPurchaseManager *purchase=[[AppPurchaseManager alloc]initwithView:self];
    [purchase loadStore];
    
}

@end
