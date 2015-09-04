//
//  EditViewController.m
//  SyncForce
//
//  Created by Gaeasys Admin on 11/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EditViewController.h"
#import "Section.h"
#import "CustomCell.h"
#import "EditLayoutSectionsInfoManager.h"
#import "EntityManager.h"
#import "Entity.h"
#import "InfoFactory.h"
#import "ValuesCriteria.h"
#import "Datagrid.h"
#import "UITool.h"
#import "DatePopupViewController.h"
#import "EntityManager.h"
#import "FieldInfoManager.h"
#import "HtmlHelper.h"
#import "ObjectDetailViewController.h"
#import "RecordTypeMappingInfoManager.h"
#import "CustomUITextField.h"
#import "PicklistForRecordTypeInfoManager.h"

@implementation EditViewController
@synthesize detail;//,editView;
@synthesize sections,layoutItems,mode,tagMapper,objectId,mapData,mapSections,updateInfo;
@synthesize allTextField;

- (id)init:(Item*)item mode:(NSString*)pMode objectId:(NSString *)pobjectId relationField:(NSString*)relationField{
    
    self = [super init];
    NSArray* tmpLayoutId;
    
    if ([[item.fields objectForKey:@"recordTypeId"] length] == 0 || [item.fields objectForKey:@"recordTypeId"] == nil) {
    
            NSMutableDictionary *cri = [[NSMutableDictionary alloc] initWithCapacity:1];
            [cri setValue:[[ValuesCriteria alloc] initWithString:@"012000000000000AAA"] forKey:@"RecordTypeId"];
            [cri setValue:[[ValuesCriteria alloc] initWithString:@"Master"] forKey:@"name"];
            [cri setValue:[[ValuesCriteria alloc] initWithString:item.entity] forKey:@"entity"];
            recordTypeId = @"012000000000000AAA";
            tmpLayoutId = [RecordTypeMappingInfoManager list:cri];
    }else {
    
        
            NSMutableDictionary *cri = [[NSMutableDictionary alloc] initWithCapacity:1];
            [cri setValue:[[ValuesCriteria alloc] initWithString:[item.fields objectForKey:@"recordTypeId"]] forKey:@"RecordTypeId"];
            [cri setValue:[[ValuesCriteria alloc] initWithString:item.entity] forKey:@"entity"];
            recordTypeId = [item.fields objectForKey:@"recordTypeId"];
            tmpLayoutId = [RecordTypeMappingInfoManager list:cri];
    }
        
          
    self.detail = item;
    self.mode = pMode;
    self.objectId = pobjectId;
    fieldParent = relationField;
    
    self.layoutItems = [[NSMutableDictionary alloc] initWithCapacity:1];
    entityInfo = [InfoFactory getInfo:self.detail.entity];
    if([mode isEqualToString:@"add"]) self.title = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"ADD", nil),[self.detail entity]];
    else{
        Item *tmp = [EntityManager find:detail.entity column:@"Id" value:self.objectId];
        NSString *name = [tmp.fields valueForKey:@"Name"];
        self.title = name==nil?[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"EDIT", nil),[entityInfo getLabel]]:[NSString stringWithFormat:@"Edit %@(%@)",[entityInfo getLabel],name==nil?@"":name];
    }
    self.tagMapper = [[NSMutableDictionary alloc] init];
    allTextField = [[NSMutableArray alloc] initWithCapacity:1];
    
    //Group items(Field) by heading
    NSMutableArray *sectionNameOrder = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    mapSections = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    NSMutableDictionary *dic = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
    [dic setValue:[[[ValuesCriteria alloc] initWithString:[detail.fields valueForKey:@"RecordTypeId"]==nil?@"012000000000000AAA":[detail.fields valueForKey:@"RecordTypeId"]] autorelease] forKey:@"recordTypeId"];

    [dic setValue:[[[ValuesCriteria alloc] initWithString:detail.entity] autorelease] forKey:@"entity"];
  //  Item *it = [RecordTypeMappingInfoManager find:dic];
    
    mapData = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    NSMutableDictionary *filters = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
    madatoryFields = [[NSMutableDictionary alloc] initWithCapacity:1];
    [filters setValue:[ValuesCriteria criteriaWithString:self.detail.entity] forKey:@"entity"];
    if([tmpLayoutId count]>0)
        [filters setValue:[ValuesCriteria criteriaWithString:[[[tmpLayoutId objectAtIndex:0] fields] objectForKey:@"layoutId"]] forKey:@"Id"];

    NSArray *listField = [EditLayoutSectionsInfoManager list:filters];
    
    Item *tmp = [EntityManager find:detail.entity column:@"Id" value:self.objectId];
    
    NSMutableDictionary *dicData = [[NSMutableDictionary alloc] init];
    for(Item *item in listField){
        NSString *fieldName = [item.fields valueForKey:@"value"];
        [madatoryFields setValue:[item.fields valueForKey:@"required"] forKey:fieldName];
        if([self.mode isEqualToString:[Datagrid getAddImg]]){
            [dicData setValue:@"" forKey:fieldName];
            
        }else{
            [dicData setValue:[tmp.fields valueForKey:fieldName] forKey:fieldName];
        }
    }
    if([self.mode isEqualToString:[Datagrid getAddImg]]){
        [dicData setValue:self.objectId forKey:@"AccountId"];
    }else{
        [dicData setValue:self.objectId forKey:@"Id"];
    }

    self.detail = [[Item alloc] init:detail.entity fields:dicData];
    
    for(Item *item in listField){
        NSString *heading = [item.fields valueForKey:@"heading"];
        if(![mapSections.allKeys containsObject:heading]){
            [sectionNameOrder addObject:heading];
            NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:1];
            [mapSections setValue:items forKey:heading];
        }
        [[mapSections objectForKey:heading] addObject:item];
    }
    [dicData setValue:self.objectId forKey:@"Id"];
    
    NSMutableArray *detailSections = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    NSMutableArray *shipping = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    for(NSString *heading in sectionNameOrder){
        [shipping removeAllObjects];
        Section *section = [[Section alloc] initWithName:heading];
        int i=0;
        for(Item *item in [mapSections valueForKey:heading]){
            NSString *fieldname = [item.fields valueForKey:@"value"];
            if([[item.fields valueForKey:@"useCollapsibleSection"] isEqualToString:@"false"]){
                if([heading isEqualToString:@"Address Information"]){
                    if(i%2==0){
                        [section.fields addObject:fieldname];
                    }else{
                        [shipping addObject:fieldname];
                    }
                }else{
                    [section.fields addObject:fieldname];
                }
            }
            [self.layoutItems setValue:item forKey:fieldname];
            i++;
        }
        if([shipping count] > 0){
            [section.fields addObjectsFromArray:shipping];
            [shipping removeAllObjects];
        }
        [detailSections addObject:section];
    }
    
    sections = [detailSections copy];
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)dealloc{
    [super dealloc];
    [detail release];
    [layoutItems release];
    [sections release];
    [tagMapper release];
    [allTextField release];
    [mapSections release];
    [madatoryFields release];
    //[tempTextField release];
}

- (void)saveClick:(id)sender {
    
    for(UITextField *textField in allTextField){
        if([textField isFirstResponder]){
            [textField resignFirstResponder];
            break;
        }
    }
    
    BOOL isMadatoryEnter = YES;
    NSString *fieldName;
    
    for(NSString *field in [detail.fields allKeys]){
        BOOL isMadat = [[madatoryFields valueForKey:field] isEqualToString:@"true"];
        if(isMadat){
            NSString *value = [detail.fields valueForKey:field];
            
            if([[value stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]] isEqualToString:@""]){
                isMadatoryEnter = NO;
                fieldName = field; 
                break;
            }
        }
    }
    
    if(!isMadatoryEnter){
        Item *fieldInfo = [self.layoutItems valueForKey:fieldName];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Validation Error : " message:[NSString stringWithFormat: @"Please enter a value for the field %@ ",[fieldInfo.fields valueForKey:@"label"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }else{
        NSString* info;
        if([mode isEqualToString:[Datagrid getAddImg]]){
            info = [[NSString alloc] initWithFormat:NSLocalizedString(@"RECORD_SAVE", Nil),self.detail.entity];
            NSString *localid = [NSString stringWithFormat:@"%d",[EntityManager getCount:self.detail.entity] + 1];
          
            if ([self.detail.entity isEqualToString:@"Contact"]) {
                if ([[self.detail.fields valueForKey:@"Name"] isEqualToString:@""] ||
                      [self.detail.fields valueForKey:@"Name"] == nil) {
                    
                    [self.detail.fields setValue:[NSString stringWithFormat:@"%@ %@", [self.detail.fields objectForKey:@"FirstName"],[self.detail.fields objectForKey:@"LastName"]] forKey:@"Name"];
                }
            }
            
            [self.detail.fields setValue:recordTypeId forKey:@"recordTypeId"];
            [self.detail.fields setValue:localid forKey:@"Id"];
            [self.detail.fields setValue:@"2" forKey:@"modified"];
            [self.detail.fields setValue:@"0" forKey:@"error"];
            [self.detail.fields setValue:@"0" forKey:@"deleted"];
            
            [EntityManager insert:self.detail modifiedLocally:NO];
            
        }else if([mode isEqualToString:[Datagrid getEditImg]]){
            info = [[NSString alloc] initWithFormat:NSLocalizedString(@"RECORD_SAVE", Nil),self.detail.entity];
            [self.detail.fields setValue:@"0" forKey:@"error"];
            
            [EntityManager update:self.detail modifiedLocally:YES];
            
        }
        
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@",self.detail.entity] message:  info delegate:self cancelButtonTitle:NSLocalizedString(@"OK", Nil) otherButtonTitles:nil];
        [alert show];
        [alert release];
        
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(updateInfo) [updateInfo didUpdate:detail];
    [self.navigationController popViewControllerAnimated:YES];

}


-(void)textFieldDidEndEditing:(CustomUITextField *)textField{
    Section *section = [sections objectAtIndex:textField.section];
    NSString *fieldName = [section.fields objectAtIndex:textField.tag];
    Item *info = [entityInfo getFieldInfoByName:fieldName];
    NSString *fieldType = [info.fields valueForKey:@"type"];
    BOOL isNumeric = YES;
    if([fieldType isEqualToString:@"double"] || [fieldType isEqualToString:@"currency"] || [fieldType isEqualToString:@"int"] || [fieldType isEqualToString:@"percent"]){
        for(int i=0;i<textField.text.length;i++){
            NSString *str = [NSString stringWithFormat:@"%C",[textField.text characterAtIndex:i]];
            if([str isEqualToString:@"."]) continue;
            if(!isnumber([textField.text characterAtIndex:i])){
                isNumeric = NO;
                break;
            }
        }
    }
    if(!isNumeric){
        tempTextField = textField;
        textField.text = @"";
        Item *fieldInfo = [self.layoutItems valueForKey:fieldName];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Field Type" message:[NSString stringWithFormat:@"Field %@ must be enter a number",[fieldInfo.fields valueForKey:@"label"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }else{
        [detail.fields setValue:textField.text forKey:fieldName];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - View lifecycle
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    //UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveClick:)];
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SAVE", nil) style:UIBarButtonItemStyleDone target:self action:@selector(saveClick:)];
    
    [self.navigationItem setRightBarButtonItem:editButton];
    [editButton release];
    
    CGRect rect = [UIScreen mainScreen].bounds;
    
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.sectionHeaderHeight = SETTING_HEADER_HEIGHT;
    
    UIImageView *background = [[UIImageView alloc] initWithFrame:self.tableView.backgroundView.frame];
    background.image = [UIImage imageNamed:@"gridGradient.png"];
    background.contentMode = UIViewContentModeScaleToFill;
    
    self.tableView.backgroundView = background;
    [background release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{

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
    return [self.sections count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[[self.sections objectAtIndex:section] fields] count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *hdrView = [[UIView alloc] initWithFrame:CGRectMake(0,0, tableView.frame.size.width, SETTING_HEADER_HEIGHT)];
    hdrView.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(90, 0, SETTING_HEADER_ROW_WIDTH, SETTING_HEADER_HEIGHT)];
    label.font = [UIFont boldSystemFontOfSize:SETTING_HEADER_FONT_SIZE];
    label.textAlignment = UITextAlignmentLeft;
    label.highlightedTextColor = [UIColor whiteColor];
    label.textColor = [UIColor darkGrayColor];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0, 1);
    label.backgroundColor = [UIColor clearColor];
    
    HtmlHelper *help = [[HtmlHelper alloc] init];
    label.text = [help convertEntiesInString:[[sections objectAtIndex:section] name]];
    [help release];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(46, 10, 30, 30)];
    button.tag = section;
    
    [button setBackgroundImage:[UIImage imageNamed:[[[self.sections objectAtIndex:section] fields] count] > 0 ? @"arrow_down.png" : @"arrow_right.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickToCollape:) forControlEvents:UIControlEventTouchUpInside];
    [hdrView addSubview:button];
    [hdrView addSubview:label];
    [button release];
    [label release];
    
    return hdrView;
}

-(void) viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)clickToCollape:(id)sender {
        
    for(UITextField *textField in allTextField){
        if([textField isFirstResponder]){
            [textField resignFirstResponder];
            break;
        }
    }
    
    UIButton *button = (UIButton *)sender;
    NSMutableArray *indexes = [[NSMutableArray alloc] initWithCapacity:1];
    
    Section *section = [self.sections objectAtIndex:button.tag];
    
    BOOL isOpen;
    
    if ([section.fields count] > 0) {
        [button setBackgroundImage:[UIImage imageNamed:@"arrow_right.png"] forState:UIControlStateNormal];
        for (int i = 0; i < [section.fields count]; i++) {
            [indexes addObject:[NSIndexPath indexPathForRow:i inSection:button.tag]];
        }
        [section.fields removeAllObjects];
        
        [self.tableView deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];    
        isOpen = YES;
    } else {
        // must add before animating
        for(Item *item in [mapSections valueForKey:section.name]){
            NSString *fieldname = [item.fields valueForKey:@"value"];
            [section.fields addObject:fieldname];
            [self.layoutItems setValue:item forKey:fieldname];
        }
    
        for (int i = 0; i < [section.fields count]; i++) {
            [indexes addObject:[NSIndexPath indexPathForRow:i inSection:button.tag]];
        }
        [self.tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];
        if ([section.fields count] > 0) {
            [button setBackgroundImage:[UIImage imageNamed:@"arrow_down.png"] forState:UIControlStateNormal];
        }
        isOpen = NO;
    }
    
    NSMutableDictionary *criteria = [[NSMutableDictionary alloc] initWithCapacity:1];
    [criteria setValue:[[[ValuesCriteria alloc] initWithString:detail.entity] autorelease] forKey:@"entity"];
    [criteria setValue:[[[ValuesCriteria alloc] initWithString:section.name] autorelease] forKey:@"heading"];
    for(Item *item in [EditLayoutSectionsInfoManager list:criteria]){
        [item.fields setValue:isOpen?@"true":@"false" forKey:@"useCollapsibleSection"];
        [EditLayoutSectionsInfoManager update:item];
    }
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[CustomCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Configure the cell...
    Section *section = [self.sections objectAtIndex:indexPath.section];
    
    NSString *fieldname = [section.fields objectAtIndex:indexPath.row];
    Item *fieldInfo = [self.layoutItems valueForKey:fieldname];
    Item *info = [entityInfo getFieldInfoByName:fieldname];

    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.text = [fieldInfo.fields valueForKey:@"label"];
    
    BOOL isMadatory = [[madatoryFields valueForKey:fieldname] isEqualToString:@"true"];
    NSString *value = [detail.fields valueForKey:fieldname];
    
    if([[info.fields objectForKey:@"type"] isEqualToString:@"reference"]){
        
        NSArray *arr = [FieldInfoManager referenceToEntitiesByField:detail.entity field:fieldname];
        Item *item = [EntityManager find:[arr objectAtIndex:arr.count>1?1:0] column:@"Id" value:[detail.fields valueForKey:fieldname]];
        if ([fieldParent isEqualToString:fieldname]) {
            item = [EntityManager find:[arr objectAtIndex:arr.count>1?1:0] column:@"Id" value:objectId];
        }
        value = [item.fields objectForKey:@"Name"];
        [mapData setObject:value==nil?@"":value forKey:[detail.fields valueForKey:fieldname]==nil?@"":[detail.fields valueForKey:fieldname]];
    }
    
    if([[info.fields objectForKey:@"type"] isEqualToString:@"picklist"]){
        NSArray* listItems = [PicklistForRecordTypeInfoManager getPicklistItems:fieldname entity:[entityInfo getName] recordTypeId:recordTypeId ==nil?@"012000000000000AAA":recordTypeId];
        
        if ([[detail.fields valueForKey:fieldname] length] == 0 || [detail.fields valueForKey:fieldname] == nil) {
            for (Item* item in listItems) {
                if ([[item.fields objectForKey:@"defaultValue"] isEqualToString:@"true"]) {
                      value = [item.fields objectForKey:@"value"];
                      [detail.fields setValue:value forKey:fieldname];
                      [mapData setObject:value forKey:fieldname];
                       break;
                }
            }
        }
    }
    
    if ([[info.fields objectForKey:@"type"] isEqualToString:@"boolean"]) {
        if (value.length == 0) {
            [self.detail.fields setValue:@"false" forKey:fieldname]; 
        }
    }
    //Set Up cell
    [UITool setupEditCell:cell fieldsInfo:info value:value tag:indexPath.row delegate:self isMadatory:isMadatory];
    for(UIView *view in cell.contentView.subviews){
        if([view isKindOfClass:[CustomUITextField class]]) {
            ((CustomUITextField*)view).section = indexPath.section;
            [allTextField addObject:view];
        }
    }
    
    return cell;
}

- (NSString *)getFieldName:(UIView*)view{
    CGRect position = [view convertRect:view.frame toView:self.tableView];
    NSArray *indexPaths = [self.tableView indexPathsForRowsInRect:position];
    NSIndexPath *path = [indexPaths objectAtIndex:0];
    Section *section = [sections objectAtIndex:path.section];
    NSString *fieldName = [section.fields objectAtIndex:path.row];
    return fieldName;

}

- (void)changeSwitch:(id)sender{
    NSString *code = [self getFieldName:sender];
    if (((UISwitch *)sender).on) {
        [self.detail.fields setValue:@"true" forKey:code];
    } else {
        [self.detail.fields setValue:@"false" forKey:code]; 
    }

}

- (void)done:(NSString*)newDate editPath:(NSIndexPath*)path{
    
    Section *section = [sections objectAtIndex:path.section];
    NSString *fieldName = [section.fields objectAtIndex:path.row];
    [self.detail.fields setValue:newDate forKey:fieldName];
    [self.tableView reloadData];
    
}
- (void)clear:(NSIndexPath*)path{
    Section *section = [sections objectAtIndex:path.section];
    NSString *fieldName = [section.fields objectAtIndex:path.row];
    [self.detail.fields setValue:@"" forKey:fieldName];
    [self.tableView reloadData];
}

- (void)updateCell:(NSIndexPath*)path newValue:(NSString*)value{
    Section *section = [self.sections objectAtIndex:path.section];
    NSString *fieldname = [section.fields objectAtIndex:path.row];
    Item *info = [entityInfo getFieldInfoByName:fieldname];
    NSString *fieldType = [info.fields objectForKey:@"type"];
    
    if([fieldType isEqualToString:@"reference"]){
        
        NSArray *arr = [FieldInfoManager referenceToEntitiesByField:detail.entity field:fieldname];
        Item *item = [EntityManager find:[arr objectAtIndex:arr.count>1?1:0] column:@"Name" value:value];
        [detail.fields setValue:[item.fields objectForKey:@"Id"] forKey:fieldname];
        
    }else{
        [detail.fields setValue:value forKey:fieldname];
    }
    [self.tableView reloadData];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Section *section = [self.sections objectAtIndex:indexPath.section];
    NSString *fieldname = [section.fields objectAtIndex:indexPath.row];
    Item *info = [entityInfo getFieldInfoByName:fieldname];
    Item *fieldInfo = [self.layoutItems valueForKey:fieldname];
    NSString *fieldType = [info.fields objectForKey:@"type"];
    if([fieldType isEqualToString:@"reference"] || [fieldType isEqualToString:@"picklist"]){
        NSString *selectValue = [detail.fields valueForKey:fieldname];
      //  if([fieldType isEqualToString:@"reference"]) selectValue = [mapData objectForKey:selectValue];
        
        NSArray* listItems;
        
        if([fieldType isEqualToString:@"reference"]){
            NSArray *arr = [FieldInfoManager referenceToEntitiesByField:[entityInfo getName] field:fieldname];
            NSString *entity = [arr objectAtIndex:0];
            if([arr count] > 1 && ![[DatabaseManager getInstance] checkTable:entity]){
                entity = [arr objectAtIndex:1];
            }
            listItems = [EntityManager list:entity criterias:nil];
            selectValue = [mapData objectForKey:selectValue];
        }else{
            listItems = [PicklistForRecordTypeInfoManager getPicklistItems:fieldname entity:[entityInfo getName] recordTypeId:recordTypeId ==nil?@"012000000000000AAA":recordTypeId];
        }
        
        
        ListPopupViewController *selectPopup = [[ListPopupViewController alloc] initWithController:[entityInfo getName] fieldName:fieldname listData:listItems recordType:recordTypeId ==nil?@"012000000000000AAA":recordTypeId parentController:self selectValue:selectValue fieldType:fieldType];
        selectPopup.title = [fieldInfo.fields objectForKey:@"label"];
        selectPopup.editPath = indexPath;
        [selectPopup showPopup:[tableView cellForRowAtIndexPath:indexPath] parentView:self.view];
        [selectPopup release];
        
    }else if([fieldType isEqualToString:@"datetime"] || [fieldType isEqualToString:@"date"]){
        
        NSString *date = [detail.fields valueForKey:fieldname];
        DatePopupViewController *datePopup = [[DatePopupViewController alloc] initWithDate:date fieldName:fieldname fieldType:fieldType parentController:self];
        datePopup.title = [fieldInfo.fields objectForKey:@"label"];
        datePopup.editPath = indexPath;
        [datePopup show:[tableView cellForRowAtIndexPath:indexPath] parentView:self.view];
        [datePopup release];
        
    }
}

@end
