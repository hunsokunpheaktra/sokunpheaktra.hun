

#import "EditingViewController.h"

@implementation EditingViewController

@synthesize item, detail, subtype;
@synthesize currentListener;
@synthesize allEditableField;
@synthesize sections, sectionData, relatedFields;
@synthesize imagePicker, chooseimage, selectedimage;

- (id)initWithItem:(Item *)newItem updateListener:(NSObject <UpdateListener> *)newUpdateListener isCreate:(BOOL)newIsCreate
{
    isCreate = newIsCreate;
	self = [super initWithStyle:UITableViewStyleGrouped];
    self.currentListener = newUpdateListener;
    self.item = newItem;
    self.detail = [[Item alloc]init:self.item.entity fields:self.item.fields];
    self.subtype = [Configuration getSubtype:self.detail];
	return self;
}

- (void)viewDidLoad {  
   
    
    NSObject <EntityInfo> *info = [Configuration getInfo:self.detail.entity];
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:subtype];
    
    self.relatedFields = [[NSMutableArray alloc] initWithCapacity:1];
    for (Relation *relation in [Relation getEntityRelations:self.detail.entity]) {
        if ([relation.srcEntity isEqualToString:self.detail.entity]) {
            if ([sinfo enabledRelation:relation.srcKey]) {
                [self.relatedFields addObject:relation.srcKey];
            }
        }
    }
    
	// Configure the save and cancel buttons.
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];

    
    if (isCreate) {
        self.title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"NEW", nil), [sinfo localizedName]];
    } else {
        self.title = [NSString stringWithFormat:@"%@ %@", [sinfo localizedName], NSLocalizedString(@"EDIT", nil)];
    }
    
    if (!isCreate && [info canDelete]) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 70)];
        UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnDelete setBackgroundImage:[[UIImage imageNamed:@"delete_button.png"] stretchableImageWithLeftCapWidth:8.0f topCapHeight:0.0f] forState:UIControlStateNormal];
        [btnDelete setTitle:[NSString stringWithFormat:NSLocalizedString(@"DELETE_ITEM", @"delete button's label"),[sinfo localizedName]] forState:UIControlStateNormal];
        [btnDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnDelete.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        btnDelete.titleLabel.shadowColor = [UIColor lightGrayColor];
        btnDelete.titleLabel.shadowOffset = CGSizeMake(0, -1);
        [btnDelete setFrame:CGRectMake(0,0, 300, 44)];
        btnDelete.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [btnDelete addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchDown];
        btnDelete.center=footerView.center;
        [footerView addSubview:btnDelete];
        [self.tableView setTableFooterView:footerView];
    }
    
    self.sections = [LayoutSectionManager read:subtype page:0];
    NSMutableArray *tmpData = [[NSMutableArray alloc] initWithCapacity:1];
    for (int i = 0; i <[sections count] ;i++) {
        [tmpData addObject:[self fillSectionData:i]];
    }
    self.sectionData = tmpData;
    
    // init empty checkboxes to disabled
    [UITools initCheckboxes:self.detail sections:self.sections];
    
    //Image picker 
    self.imagePicker = [[UIImagePickerController alloc] init]; 
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; 
	self.imagePicker.allowsEditing = YES;
	self.imagePicker.delegate = self;	
    
    //Button choose image for Contact object
    if ([detail.entity isEqualToString:@"Contact"]) {
        
        self.chooseimage = [UIButton buttonWithType:UIButtonTypeCustom];
        [UITools contactPicture:self.tableView item:detail button:chooseimage];
        [self.chooseimage addTarget:self action:@selector(choosePic:) forControlEvents:UIControlEventTouchUpInside];
        selectedimage = chooseimage.imageView.image;
    }
}


#pragma mark -
#pragma mark Save and cancel operations

- (void)save {
    [ValidationTools setCalculated:self.detail];
    if ([ValidationTools check:self.detail]) {
        if (isCreate) {
            [EntityManager insert:self.detail modifiedLocally:YES];
        } else {
            [EntityManager update:self.detail modifiedLocally:YES];
        }
        
        //handle image saving
        if ([self.detail.entity isEqualToString:@"Contact"]) {
            NSString *gadget_id = isCreate ? [EntityManager getLastGadgetId:@"Contact"] : [detail.fields objectForKey:@"gadget_id"];
            if (selectedimage == nil) {
                [PictureManager deletePicture:gadget_id];
            } else {
                [PictureManager save:gadget_id data:UIImagePNGRepresentation(selectedimage)];
            }
        }
        
        [[SyncController getInstance] syncProgress:detail.entity];
        item = detail;
        [self.currentListener mustUpdate];
        [self.navigationController popViewControllerAnimated:YES]; 
    }
}

- (void)cancel {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [sections count]+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section < [self.sections count]) {
        Section *sect = [self.sections objectAtIndex:section];
        NSArray *filtered = [UITools filterFields:sect.fields subtype:self.subtype];
        return [filtered count];
    } else {
        return [self.relatedFields count];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section < [self.sections count]) {
        Section *sect = [self.sections objectAtIndex:section];
        return [EvaluateTools translateWithPrefix:sect.name prefix:@"HEADER_"];
    }
    return NSLocalizedString(@"RELATED_ITEMS", @"Related Items");
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section < [sections count]) {
        Section *sect = [self.sections objectAtIndex:indexPath.section];
        NSArray *filtered = [UITools filterFields:sect.fields subtype:self.subtype];
        NSString *code = [filtered objectAtIndex:indexPath.row]; 
        CRMField *field = [FieldsManager read:self.detail.entity field:code];
        if ([field.type isEqualToString:@"Text (Long)"]) return 120;
    }
    return 44;
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
 		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier]autorelease];
    }
    
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:self.subtype];
    
    NSString *code; 
    int tag = indexPath.row;
    for (int i = 0; i < indexPath.section; i++) {
        Section *tmpSection = [self.sections objectAtIndex:i];
        NSArray *filtered = [UITools filterFields:tmpSection.fields subtype:self.subtype];
        tag += [filtered count];
    }
    if (indexPath.section < [sections count]) {
        Section *sect = [self.sections objectAtIndex:indexPath.section];
        NSArray *filtered = [UITools filterFields:sect.fields subtype:self.subtype];
        code = [filtered objectAtIndex:indexPath.row]; 
    } else {
        code = [self.relatedFields objectAtIndex:indexPath.row];
    }
       
    CRMField *field = [FieldsManager read:self.detail.entity field:code];
    NSString *customName = [sinfo customName:code];
    cell.textLabel.text = customName != nil ? customName : [EvaluateTools removeIdSuffix:field.displayName];
    cell.textLabel.numberOfLines = 2;
    

    [UITools setupEditCell:cell subtype:subtype field:field value:[self.detail.fields objectForKey:field.code] tag:tag delegate:self item:self.detail iphone:YES];


  
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
  
    NSString *code;
    
    if (indexPath.section < [sections count]) {
        Section *sect = [self.sections objectAtIndex:indexPath.section];
        NSArray *filter = [UITools filterFields:sect.fields subtype:self.subtype];
        code = [filter objectAtIndex:indexPath.row];
        CRMField *field = [FieldsManager read:self.detail.entity field:code];
        if ([field.type isEqualToString:@"Picklist"]) {
            PickListSelectController *picklistSelect = [[PickListSelectController alloc] init:code item:self.detail updateListener:self];
            [self.navigationController pushViewController:picklistSelect animated:YES];
            [picklistSelect release];
        } else if ([field.type isEqualToString:@"Date/Time"] || [field.type isEqualToString:@"Date"]) {
            DateSelectController *dateSelect = [[DateSelectController alloc] init:code item:self.detail updateListener:self];
            [self.navigationController pushViewController:dateSelect animated:YES];
            [dateSelect release];
        }
    } else {
        code = [relatedFields objectAtIndex:indexPath.row];
        SelectRelatedItem *select = [[SelectRelatedItem alloc] init:code item:self.detail updateListener:self];
        [self.navigationController pushViewController:select animated:YES];
        [select release];
        
    }
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[super dealloc];
}

#pragma mark-
#pragma mark TextField handle editing

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {	
    
    NSString *fieldcode = [self getCodeFromTag:theTextField.tag];
    [detail.fields setValue:theTextField.text forKey:fieldcode];
    
	[theTextField resignFirstResponder];
    
	return YES;
    
}


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    NSString *fieldcode = [self getCodeFromTag:textField.tag];
    [detail.fields setValue:textField.text forKey:fieldcode];
	[textField resignFirstResponder];
	return YES;
    
}

// hadle event change on UISwitch on/off

- (void)changeSwitch:(id)sender {
    
    NSString *code =[self getCodeFromTag:((UISwitch *)sender).tag]; 
    if (((UISwitch *)sender).on==YES) {
        [detail.fields setValue:@"true" forKey:code];
    }else{
        [detail.fields setValue:@"false" forKey:code]; 
    }
    
}

- (void)checkboxchange:(id)sender {
    
    int tag = ((UISwitch *)sender).tag;
    NSString *code = [self getCodeFromTag:tag];
    UIButton *buttom=(UIButton *)sender;
    NSString *value=[detail.fields objectForKey:code];
    
    UIImage *img;
    if (value==nil || [value isEqualToString:@"false"]) {
        img = [UIImage imageNamed:@"checkbox_full.png"];
        [detail.fields setValue:@"true" forKey:code];
        
    } else {
        img = [UIImage imageNamed:@"checkbox_empty"];
        [detail.fields setValue:@"false" forKey:code]; 
    }
    [buttom setImage:img forState:UIControlStateNormal];
    
}



- (void)changeText:(id)sender {
    UITextField *textfield = (UITextField *)sender;
    NSString *code = [self getCodeFromTag:textfield.tag];
    [detail.fields setValue:textfield.text forKey:code]; 
}



-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    NSString *code = [self getCodeFromTag:textView.tag];
    [detail.fields setValue:[textView.text stringByReplacingCharactersInRange:range withString:text] forKey:code];
    
    return YES;
}


-(BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    return YES;
}


- (void)mustUpdate{
    
    [self.tableView reloadData];
    
}

- (IBAction)deleteItem:(id)sender{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"DELETE_CONFIRM", nil)  delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) destructiveButtonTitle:NSLocalizedString(@"DELETE", nil) otherButtonTitles:nil];
    actionSheet.tag = 0;
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view.superview]; 
	[actionSheet release];
    
}

- (NSArray *)fillSectionData:(int)section {
    
    NSMutableArray *tmpData = [[NSMutableArray alloc] initWithCapacity:1];
    
    Section *tmpSection = [self.sections objectAtIndex:section];
    NSString *tmpString = @"";
    for (NSString *field in tmpSection.fields) {
        NSString *value = [self.item.fields objectForKey:field];
        if (tmpSection.isGrouping) {
            if (value != nil) {
                if ([tmpString length] > 0) tmpString = [tmpString stringByAppendingString:@", "];
                tmpString = [tmpString stringByAppendingString:value];
            }
        } else {
            if (value == nil) {
                [tmpData addObject:[NSNull null]];
            } else {
                [tmpData addObject:value];
            }
        }
    }
    if (tmpSection.isGrouping) {
        [tmpData addObject:tmpString];
    }
    
    return tmpData;
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


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 0) {
        if (buttonIndex == 0) {
            [PictureManager deletePicture:[self.detail.fields objectForKey:@"gadget_id"]];
            [EntityManager remove:self.detail];
            [self.currentListener mustUpdate];
            [self.navigationController popToRootViewControllerAnimated:YES];
        } 
	} else {
        switch (buttonIndex) {
            case 0:
                imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentModalViewController:imagePicker animated:YES];
                break;
            case  1:
                
                [chooseimage setImage:nil forState:UIControlStateNormal];
                selectedimage=nil;
                break;
            
            default:
                break;
        }
    
    }
}

#pragma mark-
#pragma mark ImagePicker handle editing

- (void)choosePic:(id)sender{
    
    if (selectedimage !=nil) {
        UIActionSheet *actionsheet=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose Photo", @"Delete Photo",nil];
        actionsheet.tag = 1;
        [actionsheet setDestructiveButtonIndex:1];
        [actionsheet showInView:self.view.superview];
        [actionsheet release];
        
    }else{
        [self presentModalViewController:imagePicker animated:YES];
    }

}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    selectedimage = image;
    [self.chooseimage setImage:image forState:UIControlStateNormal];
    [self dismissModalViewControllerAnimated:YES];
}


@end

