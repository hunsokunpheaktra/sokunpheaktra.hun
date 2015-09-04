//
//  EditViewController.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/11/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "EditViewController.h"


@implementation EditViewController

@synthesize detail;
@synthesize sections;
@synthesize sectionData;
@synthesize relatedFields;
@synthesize workDetail;
@synthesize updateListener;
@synthesize isCreate;
@synthesize chooseimage;
@synthesize subtype;

- (id)initWithDetail:(Item *)newDetail updateListener:(NSObject <UpdateListener, CreationListener> *)newUpdateListener isCreate:(BOOL)newIsCreate action:(NSString *)action
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    self.isCreate = [NSNumber numberWithBool:newIsCreate];
    self.detail = newDetail;
    self.subtype = [Configuration getSubtype:self.detail];
    NSObject <EntityInfo> *info = [Configuration getInfo:self.detail.entity];
    NSObject<Subtype> *sinfo = [Configuration getSubtypeInfo:self.subtype];
    self.updateListener = newUpdateListener;
    self.workDetail = [[Item alloc] init:self.detail.entity fields:newDetail.fields];

    NSArray *pages = [LayoutPageManager read:subtype];
    self.sections = [[NSMutableArray alloc] initWithCapacity:1];
    for (int i = 0; i < [pages count]; i++) {
        NSArray *tmpSections = [LayoutSectionManager read:subtype page:i];
        for (Section *tmpSection in tmpSections) {
            NSArray *filtered = [UITools filterFields:tmpSection.fields subtype:self.subtype];
            if ([filtered count] > 0) {
                [self.sections addObject:tmpSection];
            }
        }
    }

    [UITools initCheckboxes:self.workDetail sections:self.sections];
    
    self.relatedFields = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *tmp = [[NSMutableArray alloc] initWithCapacity:1]; // to eliminate duplicate display names
    for (Relation *relation in [Relation getEntityRelations:self.detail.entity]) {
        if ([relation.srcEntity isEqualToString:self.detail.entity]) {
            if ([sinfo enabledRelation:relation.srcKey]) {
                CRMField *field = [FieldsManager read:self.detail.entity field:relation.srcKey];
                if (field != nil) {
                    NSString *display = [EvaluateTools removeIdSuffix:field.displayName];
                    if ([tmp indexOfObject:display] == NSNotFound) {
                        [self.relatedFields addObject:relation.srcKey];
                        [tmp addObject:display];
                    }
                }
            }
        }
    }
    
    
    if (![isCreate boolValue] && [info canDelete]) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 72)];
        footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnDelete setBackgroundImage:[[UIImage imageNamed:@"delete_button.png"] stretchableImageWithLeftCapWidth:8.0f topCapHeight:0.0f] forState:UIControlStateNormal];
        [btnDelete setTitle:[NSString stringWithFormat:NSLocalizedString(@"DELETE_ITEM", "Delete button"),[sinfo localizedName]] forState:UIControlStateNormal];
        [btnDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnDelete.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        btnDelete.titleLabel.shadowColor = [UIColor lightGrayColor];
        btnDelete.titleLabel.shadowOffset = CGSizeMake(0, -1);
        btnDelete.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [btnDelete setFrame:CGRectMake(20, 8, 160, 44)];
        btnDelete.center=footerView.center;
        [btnDelete addTarget:self action:@selector(deleteConfirm:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:btnDelete];
        [self.tableView setTableFooterView:footerView];
   }
    
    if ([detail.entity isEqualToString:@"Contact"]) {
    
        self.chooseimage = [UIButton buttonWithType:UIButtonTypeCustom];
        [UITools contactPicture:self.tableView item:detail button:chooseimage];
        [self.chooseimage addTarget:self action:@selector(choosePic:) forControlEvents:UIControlEventTouchUpInside];        
        
    }
    if (action != nil) {
        self.title = [EvaluateTools translateWithPrefix:action prefix:@"ACTION_"];
    } else if ([isCreate boolValue]) {
        self.title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"NEW", nil),[sinfo localizedName]];
    } else {
        self.title = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"EDIT", nil), [sinfo localizedName]];
    }
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    [self.navigationItem setRightBarButtonItem:doneButton];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    [self.navigationItem setHidesBackButton:YES];

    
    return self;
}

- (void)choosePic:(id)sender {

    ChoosePicturePopup *pic = [[ChoosePicturePopup alloc] initWithItem:detail];
    [pic showPopup:sender parent:self.view];

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
    return [sections count] + 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section < [sections count]) {
        Section *tmpSection = [sections objectAtIndex:section];
        NSArray *filtered = [UITools filterFields:tmpSection.fields subtype:self.subtype];
        int count = [filtered count];
        [filtered release];
        return count;   
    } else {
        return [self.relatedFields count];
    }
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section < [self.sections count]) {
        Section *tmpSection = [self.sections objectAtIndex:section];
        return [EvaluateTools translateWithPrefix:tmpSection.name prefix:@"HEADER_"];
    } else {
        return NSLocalizedString(@"RELATED_ITEMS", @"Related Items");
    }
 
        
   
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section < [self.sections count]) {
        Section *tmpSection = [self.sections objectAtIndex:indexPath.section];
        NSArray *filtered = [UITools filterFields:tmpSection.fields subtype:self.subtype];
        NSString *fieldName = [filtered objectAtIndex:indexPath.row];
        [filtered release];
        CRMField *crmField = [FieldsManager read:self.workDetail.entity field:fieldName];
        if ([crmField.type isEqualToString:@"Text (Long)"]) {
            return 120;
        }
        
    }
    
    return 44;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[EditCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:self.subtype];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Configure the cell...
    NSString *customName = nil;
    NSString *fieldName;
    if (indexPath.section < [self.sections count]) {
        Section *tmpSection = [self.sections objectAtIndex:indexPath.section];
        NSArray *filtered = [UITools filterFields:tmpSection.fields subtype:self.subtype];
        fieldName = [filtered objectAtIndex:indexPath.row];
        [filtered release];
        customName = [sinfo customName:fieldName];
    } else {
        fieldName = [self.relatedFields objectAtIndex:indexPath.row];
    }

    NSString *value = [self.workDetail.fields objectForKey:fieldName]; 

    int tag = indexPath.row;
    for (int i = 0; i < indexPath.section; i++) {
        Section *tmpSection = [self.sections objectAtIndex:i];
        NSArray *filtered = [UITools filterFields:tmpSection.fields subtype:self.subtype];
        tag += [filtered count];
    }

    CRMField *crmField = [FieldsManager read:self.workDetail.entity field:fieldName];

    [UITools setupEditCell:cell subtype:subtype field:crmField value:value tag:tag delegate:self item:self.detail iphone:NO];
    

    cell.textLabel.text = [EvaluateTools removeIdSuffix:customName != nil ? customName : crmField.displayName];
    
    [cell.detailTextLabel setHidden:YES];
    
    return cell;
}

- (void)cancel {    
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    // Configure the cell...
    NSString *fieldName;
    [self.view endEditing:YES];
    if (indexPath.section < [self.sections count]) {
        Section *tmpSection = [self.sections objectAtIndex:indexPath.section];
        NSArray *filtered = [UITools filterFields:tmpSection.fields subtype:self.subtype];
        fieldName = [filtered objectAtIndex:indexPath.row];
        [filtered release];
    } else {
        fieldName = [self.relatedFields objectAtIndex:indexPath.row];
    }

    NSString *value = [self.workDetail.fields objectForKey:fieldName];
    if (indexPath.section < [self.sections count]) {
        CRMField *crmField = [FieldsManager read:self.workDetail.entity field:fieldName];
        if ([crmField.type isEqualToString:@"Picklist"]) {
            
            SelectionPopup *selectionPopup = [[SelectionPopup alloc] initWithField:fieldName entity:self.workDetail.entity value:value item:self.workDetail listener:self];
            [selectionPopup show:[tableView cellForRowAtIndexPath:indexPath].frame parentView:self.view];

            
        } else if ([crmField.type isEqualToString:@"Multi-Select Picklist"]) {
            MultiSelectPopup *selectionPopup = [[MultiSelectPopup alloc] initWithField:fieldName entity:self.workDetail.entity value:value item:self.workDetail listener:self];
            [selectionPopup show:[tableView cellForRowAtIndexPath:indexPath].frame parentView:self.view];
                
        } else if ([crmField.type isEqualToString:@"Date"] || [crmField.type isEqualToString:@"Date/Time"]) {
            DatePopup *datePopup = [[DatePopup alloc] initWithField:crmField item:self.workDetail listener:self];
            [datePopup show:[tableView cellForRowAtIndexPath:indexPath].frame parentView:self.view];
        }
    } else {
        if ([Configuration isYes:@"NestleWholesaleAccount"] && [self.detail.entity isEqualToString:@"Opportunity"] && [fieldName isEqualToString:@"CustomText33"]) {
            WholesalerPopup *phPopup = [[WholesalerPopup alloc] initWithField:fieldName subtype:self.subtype value:value listener:self];
            [phPopup show:[tableView cellForRowAtIndexPath:indexPath].frame parentView:self.view];
            [phPopup release];
        } else {
            RelatedPopup *relatedPopup = [[RelatedPopup alloc] initWithField:fieldName subtype:subtype value:value parentItem:self.workDetail listener:self];
            [relatedPopup show:[tableView cellForRowAtIndexPath:indexPath].frame parentView:self.view];
            [relatedPopup release];
        }

        
    }
    
}

- (void)cleanUpCascading:(NSString *)field {
    
    NSDictionary *children = [CascadingPicklistManager getChildren:self.workDetail.entity field:field value:nil];
    for (NSString *relatedField in [children keyEnumerator]) {
        if ([self.workDetail.fields objectForKey:relatedField] != nil) {
            [self.workDetail.fields setObject:@"" forKey:relatedField];
        }
        [self cleanUpCascading:relatedField];
    }
}

- (void)didSelect:(NSString *)field valueId:(NSString *)valueId display:(NSString *)display {
    [self.workDetail.fields setValue:valueId forKey:field];

    // set depending cascading picklists to empty
    NSDictionary *children = [CascadingPicklistManager getChildren:self.workDetail.entity field:field value:display]; // bugged oracle use display value in cascading picklist
    for (NSString *relatedField in [children keyEnumerator]) {
        // trick for handling bugged field names, we call the fixCode method
        NSString *relatedValue = [self.workDetail.fields objectForKey:relatedField];
        BOOL ok = NO;
        for (NSString *tmp in [children objectForKey:relatedField]) {
            if ([tmp isEqualToString:relatedValue]) {
                ok = YES;
                break;
            }
        }
        if (!ok) {
            if ([self.workDetail.fields objectForKey:relatedField] != nil) {
                [self.workDetail.fields setObject:@"" forKey:relatedField];
            }
            [self cleanUpCascading:relatedField];
        }
    }
    [self.tableView reloadData];
}

- (NSString *)getCodeFromTag:(int)tag {
    NSString *code;
    for (int i = 0; i < [self.sections count]; i++) {
        Section *tmpSection = [self.sections objectAtIndex:i];
        NSArray *filtered = [UITools filterFields:tmpSection.fields subtype:self.subtype];
        if (tag >= [filtered count]) {
            tag -= [filtered count];
        } else {
            code = [filtered objectAtIndex:tag];
            break;
        }
    }
    return code;
}

- (void)changeSwitch:(id)sender {
    int tag = ((UISwitch *)sender).tag;
    NSString *code = [self getCodeFromTag:tag];
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

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [textField resignFirstResponder]; 
	return YES;
    
}



- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *code = [self getCodeFromTag:textView.tag];
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    if (newLength <= 16350) {
        [workDetail.fields setValue:[textView.text stringByReplacingCharactersInRange:range withString:text] forKey:code];
        return YES;
    } else {
        return NO;
    }
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    return YES;
}

- (void)done {
    [ValidationTools setCalculated:workDetail];
    if ([ValidationTools check:workDetail]) {
        if ([isCreate boolValue]) {
            [EntityManager insert:workDetail modifiedLocally:YES];
            [workDetail.fields setObject:[EntityManager getLastGadgetId:self.detail.entity] forKey:@"gadget_id"];
        } else {
            [self.workDetail.fields setValue:[NSNull null] forKey:@"error"];
            [EntityManager update:workDetail modifiedLocally:YES];
            for (NSString *key in [self.workDetail.fields keyEnumerator]) {
                NSString *value = [self.workDetail.fields objectForKey:key];
                [self.detail.fields setValue:value forKey:key];
            }
        } 
        if (chooseimage.tag == 0) {
            UIImage *image = self.chooseimage.imageView.image;
            [PictureManager save:[workDetail.fields objectForKey:@"gadget_id"] data:UIImagePNGRepresentation(image)];
        } else {
            [PictureManager deletePicture:[workDetail.fields objectForKey:@"gadget_id"]];
        }
        [self.updateListener mustUpdate];
        if ([isCreate boolValue]) {
            NSString *str = [EntityManager getLastGadgetId:self.detail.entity];
            [self.updateListener didCreate:self.detail.entity key:str];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}

- (void)changeText:(id)sender {
    UITextField *textfield = (UITextField *)sender;
    NSString *code = [self getCodeFromTag:textfield.tag];
    [workDetail.fields setValue:textfield.text forKey:code];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if (newLength <= 50) {
        return YES;
    } else {
        return NO;
    }
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
    NSString *code = [self getCodeFromTag:tag];
    UIButton *button = (UIButton *)sender;
    
    NSString *value = [self.workDetail.fields objectForKey:code];
    
    UIImage *img;
    if (value==nil || [value isEqualToString:@"false"]) {
        img = [UIImage imageNamed:@"checkbox_full.png"];
        [self.workDetail.fields setValue:@"true" forKey:code];

    } else {
        img = [UIImage imageNamed:@"checkbox_empty"];
        [self.workDetail.fields setValue:@"false" forKey:code]; 
    }
    [button setImage:img forState:UIControlStateNormal];
    
}

@end
