//
//  SublistEditVC.m
//  CRMiOS
//
//  Created by Arnaud Marguerat on 8/27/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "SublistEditVC.h"

@implementation SublistEditVC

@synthesize detail;
@synthesize workDetail;
@synthesize updateListener;
@synthesize isCreate;
@synthesize chooseimage;
@synthesize fields;
@synthesize parentItem;

- (id)initWithDetail:(SublistItem *)newDetail parentItem:(Item *)newParentItem updateListener:(NSObject <UpdateListener, CreationListener> *)newUpdateListener isCreate:(BOOL)newIsCreate
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    self.isCreate = newIsCreate;
    self.parentItem = newParentItem;
    self.detail = newDetail;
    self.updateListener = newUpdateListener;
    self.workDetail = [[SublistItem alloc] init:self.detail.entity sublist:self.detail.sublist fields:newDetail.fields];
    
    NSObject<Subtype> *sinfo = [Configuration getSubtypeInfo:[Configuration getSubtype:self.parentItem]];
    NSObject<Sublist> *slinfo = [sinfo getSublist:self.detail.sublist];
    self.fields = [[NSMutableArray alloc] initWithCapacity:1];
    for (NSString *field in slinfo.fields) {
        if (![field isEqualToString:@"Id"] 
            && (![field isEqualToString:@"IndexedShortText1"] || ![Configuration isYes:@"NestleWholesaleAccount"]) // NESTLE specific
            ) {
            if ([RelationManager isCalculated:[self getSublistCode] field:field]) {
                for (Relation *relation in [Relation getEntityRelations:[self getSublistCode]]) {
                    if ([relation.srcEntity isEqualToString:[self getSublistCode]]) {
                        if ([relation.srcFields containsObject:field] && ![self.fields containsObject:relation.srcKey]) {
                            [self.fields addObject:relation.srcKey];
                        }
                    }
                }
            } else {
                [self.fields addObject:field];
            }
        }
    }
    
    NSString *sublistCode = [NSString stringWithFormat:@"%@_SINGULAR", self.detail.sublist];
    NSString *sublistName = NSLocalizedString(sublistCode, nil);
    if (!self.isCreate) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 72)];
        footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnDelete setBackgroundImage:[[UIImage imageNamed:@"delete_button.png"] stretchableImageWithLeftCapWidth:8.0f topCapHeight:0.0f] forState:UIControlStateNormal];
        [btnDelete setTitle:[NSString stringWithFormat:NSLocalizedString(@"DELETE_ITEM", "Delete button"), sublistName] forState:UIControlStateNormal];
        [btnDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnDelete.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        btnDelete.titleLabel.shadowColor = [UIColor lightGrayColor];
        btnDelete.titleLabel.shadowOffset = CGSizeMake(0, -1);
        btnDelete.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [btnDelete setFrame:CGRectMake(20, 8, 160, 44)];
        btnDelete.center = footerView.center;
        [btnDelete addTarget:self action:@selector(deleteConfirm:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:btnDelete];
        [self.tableView setTableFooterView:footerView];
    }

    if (isCreate) {
        self.title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"NEW", nil), sublistName];
    } else {
        self.title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"EDIT", nil), sublistName];
    }
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    [self.navigationItem setRightBarButtonItem:doneButton];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    [self.navigationItem setHidesBackButton:YES];
    
    
    return self;
}


- (void)dealloc
{
    [chooseimage release];
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
    // Return YES for supported orientations
    return YES;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.fields count];
}




// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[EditCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Configure the cell...
    NSString *fieldName = [self.fields objectAtIndex:indexPath.row];
    
    NSString *value = [self.workDetail.fields objectForKey:fieldName]; 

    int tag = indexPath.row;

    CRMField *crmField = [FieldsManager read:[self getSublistCode] field:fieldName];
    
    [UITools setupEditCell:cell subtype:[self getSublistCode] field:crmField value:value tag:tag delegate:self item:self.detail iphone:NO];
    
    cell.textLabel.text = [EvaluateTools removeIdSuffix:crmField.displayName];
    
    [cell.detailTextLabel setHidden:YES];
    
    return cell;
}

- (void)cancel {    
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.view endEditing:YES];
    NSString *sublistCode = [self getSublistCode];
    NSString *field = [self.fields objectAtIndex:indexPath.row];
    CRMField *crmField = [FieldsManager read:sublistCode field:field];
    
    NSString *value = [self.workDetail.fields objectForKey:field];
    
    if ([crmField.type isEqualToString:@"ID"]) {
        RelatedPopup *relatedPopup = [[RelatedPopup alloc] initWithField:field subtype:sublistCode value:value parentItem:self.workDetail listener:self];
        [relatedPopup show:[tableView cellForRowAtIndexPath:indexPath].frame parentView:self.view];
        [relatedPopup release];
        
    } else if ([crmField.type isEqualToString:@"Picklist"]) {
       SelectionPopup *selectionPopup = [[SelectionPopup alloc] initWithField:field entity:sublistCode value:value item:self.workDetail listener:self];
        [selectionPopup show:[tableView cellForRowAtIndexPath:indexPath].frame parentView:self.view];
        
    } else if ([crmField.type isEqualToString:@"Date"] || [crmField.type isEqualToString:@"Date/Time"]) {
        DatePopup *datePopup = [[DatePopup alloc] initWithField:crmField item:self.workDetail listener:self];
            [datePopup show:[tableView cellForRowAtIndexPath:indexPath].frame parentView:self.view];
    }


        
    
}

- (void)didSelect:(NSString *)field valueId:(NSString *)valueId display:(NSString *)display {
    NSString *sublistCode = [self getSublistCode];
    [self.workDetail.fields setValue:valueId forKey:field];
    for (Relation *relation in [Relation getEntityRelations:sublistCode]) {
        if ([relation.srcKey isEqualToString:field]) {
            Item *otherItem = [RelationManager getRelatedItem:sublistCode field:field value:valueId];
            for (int i = 0; i < [relation.srcFields count]; i++) {
                NSString *srcField = [relation.srcFields objectAtIndex:i];
                NSString *destField = [relation.destFields objectAtIndex:i];
                NSString *value = [otherItem.fields objectForKey:destField];
                if (value == nil) value = @"";
                [self.workDetail.fields setObject:value forKey:srcField];
            }
        }
    }
    [self.tableView reloadData];
}


- (void)changeSwitch:(id)sender {
    int tag = ((UISwitch *)sender).tag;
    NSString *code = [self.fields objectAtIndex:tag];
    if (((UISwitch *)sender).on == YES) {
        [self.workDetail.fields setValue:@"true" forKey:code];
    } else {
        [self.workDetail.fields setValue:@"false" forKey:code]; 
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder]; 
	return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [textField resignFirstResponder]; 
	return YES;
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    NSString *code = [self.fields objectAtIndex:textView.tag];
    [workDetail.fields setValue:[textView.text stringByReplacingCharactersInRange:range withString:text] forKey:code];
    
    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    return YES;
}




- (void)done {
    if ([ValidationTools validateSubItem:self.workDetail parent:self.parentItem]) {
        if (self.isCreate) {
            [SublistManager insert:self.workDetail locally:YES];
            [workDetail.fields setObject:[EntityManager getLastGadgetId:[self getSublistCode]] forKey:@"gadget_id"];
            [self.updateListener didCreate:workDetail.entity key:nil];
        } else {
            [SublistManager update:self.workDetail locally:YES];
            [self.updateListener mustUpdate];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)changeText:(id)sender {
    
    UITextField *textField = (UITextField *)sender;
    NSString *code = [self.fields objectAtIndex:textField.tag];
    [workDetail.fields setValue:textField.text forKey:code];
	
}

- (void)deleteConfirm:(id)sender{
    
    // open a alert with an OK and cancel button
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DELETE_CONFIRM", "Config delete") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"DELETE", nil) otherButtonTitles:NSLocalizedString(@"CANCEL", nil), nil];
	[alert show];
	[alert release];
    
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// use "buttonIndex" to decide your action
	//
    if (buttonIndex == 0) {
        [PictureManager deletePicture:[detail.fields objectForKey:@"gadget_id"]];
        [EntityManager remove:self.detail];
        [self.updateListener mustUpdate];
        [self.navigationController popToRootViewControllerAnimated:YES];
        
	} 
}

- (void)checkboxchange:(id)sender{
    
    int tag = ((UISwitch *)sender).tag;
    NSString *code = [self.fields objectAtIndex:tag];
    UIButton *button = (UIButton *)sender;
    
    NSString *value = [self.workDetail.fields objectForKey:code];
    
    UIImage *img;
    if (value == nil || [value isEqualToString:@"false"]) {
        img = [UIImage imageNamed:@"checkbox_full.png"];
        [self.workDetail.fields setValue:@"true" forKey:code];
        
    } else {
        img = [UIImage imageNamed:@"checkbox_empty"];
        [self.workDetail.fields setValue:@"false" forKey:code]; 
    }
    [button setImage:img forState:UIControlStateNormal];
    
}


- (NSString *)getSublistCode {
    return [NSString stringWithFormat:@"%@ %@", self.workDetail.entity, self.workDetail.sublist];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sublistCode = [self getSublistCode];
    NSString *field = [self.fields objectAtIndex:indexPath.row];
    CRMField *crmField = [FieldsManager read:sublistCode field:field];
    if ([crmField.type isEqualToString:@"Text (Long)"]) {
        return 120;
    }
    return 44;
}

@end
