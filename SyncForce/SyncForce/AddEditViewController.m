//
//  AddEditViewController.m
//  SyncForce
//
//  Created by Gaeasys on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddEditViewController.h"
#import "ValuesCriteria.h"
#import "EntityManager.h"
#import "Section.h"
#import "RecordTypeMappingInfoManager.h"
#import "EditLayoutSectionsInfoManager.h"
#import "HtmlHelper.h"
#import "EditTool.h"
#import "EditCell.h"


@implementation AddEditViewController

@synthesize updateInfo;

- (id)init:(Item*)item mode:(NSString*)pMode objectId:(NSString*)pobjectId relationField:(NSString*)relationField {
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    NSMutableDictionary *cri = [[NSMutableDictionary alloc] initWithCapacity:1];
    Item* tmpLayoutId;
    layoutItems = [[NSMutableDictionary alloc] initWithCapacity:1];
    sectionNameRowSection = [[NSMutableDictionary alloc] init];
    
    detail = [[Item alloc] init:item.entity fields:item.fields];
    mode = pMode;
    objectId = pobjectId;
    fieldParent = relationField;
    entityInfo = [InfoFactory getInfo:detail.entity];
    
    // Set title
    if([mode isEqualToString:@"Add"]) self.title = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"ADD", nil),[detail entity]];
    else{
      
        NSString* tm = @"";
        if([detail.entity isEqualToString:@"Case"] || [detail.entity isEqualToString:@"Task"] ||  [detail.entity isEqualToString:@"Event"]) tm = @"Subject";
        else if ([detail.entity isEqualToString:@"Contract"]) tm = @"ContractNumber";
        else tm = @"Name";
        
        NSString *name = [detail.fields valueForKey:tm];
        self.title = name==nil?[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"EDIT", nil),[entityInfo getLabel]]:[NSString stringWithFormat:@"Edit %@(%@)",[entityInfo getLabel],name==nil?@"":name];
    }
    

    // Find record layout Id
    if ([[item.fields objectForKey:@"recordTypeId"] length] == 0 || [item.fields objectForKey:@"recordTypeId"] == nil) {
        [cri setValue:[[[ValuesCriteria alloc] initWithString:@"012000000000000AAA"] autorelease] forKey:@"RecordTypeId"];
        [cri setValue:[[[ValuesCriteria alloc] initWithString:@"Master"] autorelease] forKey:@"name"];
        [cri setValue:[[[ValuesCriteria alloc] initWithString:item.entity] autorelease] forKey:@"entity"];
        recordTypeId = @"012000000000000AAA";
        tmpLayoutId = [RecordTypeMappingInfoManager find:cri];
    }else {
        [cri setValue:[[ValuesCriteria alloc] initWithString:[item.fields objectForKey:@"recordTypeId"]] forKey:@"RecordTypeId"];
        [cri setValue:[[ValuesCriteria alloc] initWithString:item.entity] forKey:@"entity"];
        recordTypeId = [item.fields objectForKey:@"recordTypeId"];
        tmpLayoutId = [RecordTypeMappingInfoManager find:cri];
    }
    
       
    // Find List edit layout item
    [cri removeAllObjects];
    [cri setValue:[ValuesCriteria criteriaWithString:detail.entity] forKey:@"entity"];
    if(tmpLayoutId)
        [cri setValue:[ValuesCriteria criteriaWithString:[tmpLayoutId.fields objectForKey:@"layoutId"]] forKey:@"Id"];
    
    NSArray *listField = [EditLayoutSectionsInfoManager list:cri];
    
    [tmpLayoutId release];
    [cri release];
    
    // If new record
    NSMutableDictionary *dicData = [[NSMutableDictionary alloc] init];
    if ([mode isEqualToString:@"Add"]) {
         for(Item *item in listField){
             [dicData setValue:@"" forKey:[item.fields valueForKey:@"value"]];
         }
        
        if ([[entityInfo getAllFields] containsObject:@"RecordTypeId"])
        [dicData setValue:recordTypeId forKey:@"recordTypeId"];
         
        detail = [[Item alloc] init:detail.entity fields:dicData];
    }   
    
    [dicData release];
    
    //Group items(Field) by heading
    sectionNameOrder = [[NSMutableArray alloc] initWithCapacity:1];
    mapSections = [[NSMutableDictionary alloc] initWithCapacity:1];
  
    for(Item *item in listField){
        NSString *heading = [item.fields valueForKey:@"heading"];
        if(![mapSections.allKeys containsObject:heading]){
            [sectionNameOrder addObject:heading];
            NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:1];
            [mapSections setValue:items forKey:heading];
            [items release];
        }
        [[mapSections objectForKey:heading] addObject:item];
    }

    [listField release];
    
    NSMutableArray *detailSections = [NSMutableArray arrayWithCapacity:1] ;//[[NSMutableArray alloc] initWithCapacity:1];
    for(NSString *heading in sectionNameOrder){
        Section *section = [[Section alloc] initWithName:heading];
        for(int i=0;i<[[mapSections valueForKey:heading] count];i++){
            Item *item = [[mapSections valueForKey:heading] objectAtIndex:i];
            if (![[sectionNameRowSection allKeys] containsObject:heading]) {
                [sectionNameRowSection setObject:[item.fields objectForKey:@"rows"] forKey:heading];
            }
            
            NSString *fieldLabel = [item.fields valueForKey:@"label"];
            NSString *type = [item.fields valueForKey:@"type"];
            
            if(![type isEqualToString:@"Separator"] && ![[layoutItems allKeys] containsObject:fieldLabel]){
                NSMutableArray*tmp = [[NSMutableArray alloc] initWithObjects:item, nil];
                [layoutItems setObject:tmp forKey:fieldLabel];
                [section.fields addObject:fieldLabel];
                [tmp release];
            }else {
                [[layoutItems objectForKey:fieldLabel] addObject:item];
            }
            
        }
        
        [detailSections addObject:section];
        [section release];
    }

    sections = [detailSections retain];

    
    return self;
    
}


-(void)viewDidLoad {
    
    
    self.tableView.sectionHeaderHeight = SETTING_HEADER_HEIGHT;
    self.tableView.allowsSelection = NO;
    
    UIImageView *background = [[UIImageView alloc] initWithFrame:self.tableView.backgroundView.frame];
    background.image = [UIImage imageNamed:@"gridGradient.png"];
    background.contentMode = UIViewContentModeScaleToFill;
    
    self.tableView.backgroundView = background;
    [background release];

    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SAVE", nil) style:UIBarButtonItemStyleDone target:self action:@selector(saveClick:)];
    
    [self.navigationItem setRightBarButtonItem:editButton];
    [editButton release];
    
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
}

- (void) updateField:(NSString*) newValue apiFieldName:(NSString*)apiName {
    [detail.fields setValue:newValue forKey:apiName];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return [sections count];
}


-(float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    float height = 50;

    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath: indexPath]; 
    
    for (UILabel* fieldLabel in cell.contentView.subviews) {
        if ([fieldLabel isKindOfClass:[UILabel class]]) {
            for (Item* item in [layoutItems valueForKey:fieldLabel.text]) {
                 NSString *fieldtype = [[[entityInfo getFieldInfoByName:[item.fields objectForKey:@"value"]] fields] valueForKey:@"type"];
                
                if ([fieldtype isEqualToString:@"textarea"]) {
                    NSString *fieldLenght = [[[entityInfo getFieldInfoByName:[item.fields objectForKey:@"value"]] fields] valueForKey:@"length"];
                    height = MAX(height, ([fieldLenght intValue] <= 1000) ? 80 : 120);
                }
                
            } 
        }
        
    }
    
    return height;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if ([sectionNameOrder containsObject:[[sections objectAtIndex:section] name]]) {
        return [[sectionNameRowSection objectForKey:[[sections objectAtIndex:section] name]] intValue];
    }
    
    return [[[sections objectAtIndex:section] fields] count];
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
    
    [button setBackgroundImage:[UIImage imageNamed:[sectionNameRowSection objectForKey:[[sections objectAtIndex:section] name]] != nil ? @"arrow_down.png" : @"arrow_right.png"] forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(clickToCollape:) forControlEvents:UIControlEventTouchUpInside];
    [hdrView addSubview:button];
    [hdrView addSubview:label];
    [button release];
    [label release];
    
    return hdrView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    EditCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[EditCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    for (UIView *view in cell.contentView.subviews) [view removeFromSuperview];
    
    int tagIndex;
    
    // Configure the cell...
    Section *section = [sections objectAtIndex:indexPath.section];
    NSMutableArray *dataRowItems = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    
    CGRect rect = CGRectZero;
    float start_x = 0;
    float tWidth  = (tableView.frame.size.width-120)/4 ;
    float space = 10.f;
    
    NSString *fieldname;
    
    int nb = [section.fields count] % [[[[[mapSections objectForKey:[section name]] objectAtIndex:0] fields] objectForKey:@"rows"] intValue];

    if([[[[[mapSections objectForKey:[section name]] objectAtIndex:0] fields] objectForKey:@"rows"] intValue] != [section.fields count]) 
        tagIndex =  (indexPath.row < nb || nb == 0)?(2*indexPath.row):(indexPath.row + nb);
    else 
        tagIndex = indexPath.row;
    

    fieldname = [section.fields objectAtIndex:tagIndex];
    
    // Set up the Left View
        start_x = 15;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake( start_x, 0, tWidth - space - start_x , 40)];
        label.textAlignment = UITextAlignmentRight;
        label.numberOfLines = 4;
        label.backgroundColor = [UIColor clearColor];            
        label.text = fieldname; //[fieldInfo.fields valueForKey:@"label"];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont boldSystemFontOfSize:14];
        //[cell.contentView addSubview:label];
        [dataRowItems addObject:label];
        [label release];

        start_x = tWidth; 
     
    rect.origin.x = start_x;
    rect.size.width = tWidth;
    rect.size.height = tableView.rowHeight;
  
    //Set Up data for left field
    EditTool*tool = [[EditTool alloc] setupAddEditCell:cell entityInfo:entityInfo valueItem:detail listFieldInfo:[layoutItems valueForKey:fieldname] fieldName:fieldname rect:rect tag:tagIndex delegate:self parentField:fieldParent parentId:objectId];
    [dataRowItems addObject:tool];
    [tool release];
    
    // Set up the Right View
    if ([section.fields count] > [[[[[mapSections objectForKey:[section name]] objectAtIndex:0] fields] objectForKey:@"rows"] intValue]) {
        
        if ((indexPath.row + [[[[[mapSections objectForKey:[section name]] objectAtIndex:0] fields] objectForKey:@"rows"] intValue])< [section.fields count]) {
           
            tagIndex = 2*indexPath.row + 1;
            fieldname = [section.fields objectAtIndex:tagIndex];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(2*start_x + 15, 0, tWidth - space -15, 40)];
            label.textAlignment = UITextAlignmentRight;
            label.numberOfLines = 4;
            label.backgroundColor = [UIColor clearColor];
            label.text =  fieldname ;//[fieldInfo.fields valueForKey:@"label"];
            label.textColor = [UIColor blackColor];
            label.font = [UIFont boldSystemFontOfSize:14];
            //[cell.contentView addSubview:label];
            [dataRowItems addObject:label];
            [label release];

            start_x = 3 * tWidth;
            
            rect.origin.x = start_x;
            rect.size.width = tWidth;
            
            //Set Up cell
            tool = [[EditTool alloc] setupAddEditCell:cell entityInfo:entityInfo valueItem:detail listFieldInfo:[layoutItems valueForKey:fieldname] fieldName:fieldname rect:rect tag:tagIndex delegate:self parentField:fieldParent parentId:objectId];
            [dataRowItems addObject:tool];
            [tool release];
            
        }  
    }
    
    cell.rowItems = dataRowItems;
    
    return cell;
    
}



- (void)clickToCollape:(id)sender {
    
    
    UIButton *button = (UIButton *)sender;
    NSMutableArray *indexes = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];    
    Section *section = [sections objectAtIndex:button.tag];
    
    int nbRow ; 
    
    if ([[mapSections allKeys] containsObject:section.name]) {
        nbRow =  [[[[[mapSections objectForKey:section.name ] objectAtIndex:0] fields] objectForKey:@"rows"] intValue];
    }else 
        nbRow = [section.fields count];
    
    
    if ([sectionNameRowSection objectForKey:section.name] != nil) {
        [button setBackgroundImage:[UIImage imageNamed:@"arrow_right.png"] forState:UIControlStateNormal];
        for (int i = 0; i < nbRow; i++) {
            [indexes addObject:[NSIndexPath indexPathForRow:i inSection:button.tag]];
        }
        
        //[section.fields removeAllObjects]; // must delete before animating
        [sectionNameRowSection removeObjectForKey:section.name];
        [self.tableView deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];
        
    } else {
        // must add before animating
        // [section.fields addObjectsFromArray:[self fillSection:button.tag]];
        [button setBackgroundImage:[UIImage imageNamed:@"arrow_down.png"] forState:UIControlStateNormal];
        for (int i = 0; i < nbRow; i++) {
            [indexes addObject:[NSIndexPath indexPathForRow:i inSection:button.tag]];
        }
        
        [sectionNameRowSection setObject:[NSString stringWithFormat:@"%d",nbRow] forKey:section.name];
        [self.tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];
    }
    
    
}


// Text field
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder]; 
	return YES;
}

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *code = [textField.layer valueForKey:@"ApiFieldName"];
    NSString *fieldType = [[[entityInfo getFieldInfoByName:code] fields] valueForKey:@"type"];
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    BOOL isNumeric = YES;
    if([fieldType isEqualToString:@"double"] || [fieldType isEqualToString:@"currency"] || [fieldType isEqualToString:@"int"] || [fieldType isEqualToString:@"percent"]){
        for(int i=0;i<newString.length;i++){
            NSString *str = [NSString stringWithFormat:@"%C",[newString characterAtIndex:i]];
            if([str isEqualToString:@"."]) continue;
            if(!isnumber([newString characterAtIndex:i])){
                isNumeric = NO;
                break;
            }
        }
    }
    
    if(!isNumeric){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error:Invalid Data" message:@"Invalid number" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return NO;
        
    }else
        [detail.fields setValue:newString forKey:code];
    
    return YES;
}   

// Text View 
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    NSString *code = [textView.layer valueForKey:@"ApiFieldName"];
    [detail.fields setValue:[textView.text stringByReplacingCharactersInRange:range withString:text] forKey:code];
    
    return YES;
}

// Update check box 
- (void)changeSwitch:(id)sender{
    
    UIButton* checkBox = (UIButton*)sender;
    NSString* apiName = [checkBox titleForState:UIControlStateDisabled];
    
    if ([checkBox backgroundImageForState:UIControlStateNormal] == [UIImage imageNamed:@"check_yes"]) {
        [checkBox setBackgroundImage:[UIImage imageNamed:@"check_no"] forState:UIControlStateNormal];
        [detail.fields setValue:@"false" forKey:apiName];
    }    
    else if ([checkBox backgroundImageForState:UIControlStateNormal] == [UIImage imageNamed:@"check_no"]){
        [checkBox setBackgroundImage:[UIImage imageNamed:@"check_yes"] forState:UIControlStateNormal];
        [detail.fields setValue:@"true" forKey:apiName];
    }
    
}


// Save methode
- (void)saveClick:(id)sender {
    
    BOOL isMandCheckOk = YES;

    NSString* fieldMissingValue;
    
    for (NSArray*arrLayout in layoutItems.allValues) {
        for (Item*itemLayout in arrLayout) {
            if ([[itemLayout.fields objectForKey:@"required"] isEqualToString:@"true"]) 
                if ([[detail.fields objectForKey:[itemLayout.fields objectForKey:@"value"]] isEqualToString:@""] ||
                   [detail.fields objectForKey:[itemLayout.fields objectForKey:@"value"]] == nil ) {
                    fieldMissingValue = [itemLayout.fields valueForKey:@"label"];
                    isMandCheckOk = NO;
                    break;
                }
            
        }
        
        if (!isMandCheckOk) break;
    }
    
    
    if (isMandCheckOk) {
        NSString* info;
        if([mode isEqualToString:@"Add"]){
            info = [[NSString alloc] initWithFormat:NSLocalizedString(@"RECORD_SAVE", Nil),detail.entity];
            NSString *localid = [NSString stringWithFormat:@"%d",[EntityManager getCount:detail.entity] + 1];
            
            if ([detail.entity isEqualToString:@"Contact"] || [detail.entity isEqualToString:@"Lead"]) {
                if ([[detail.fields valueForKey:@"Name"] isEqualToString:@""] ||
                    [detail.fields valueForKey:@"Name"] == nil) {
                    
                    [detail.fields setValue:[NSString stringWithFormat:@"%@ %@", [detail.fields objectForKey:@"FirstName"],[detail.fields objectForKey:@"LastName"]] forKey:@"Name"];
                }
            }
            
            [detail.fields setValue:localid forKey:@"Id"];
            [detail.fields setValue:@"2" forKey:@"modified"];
            [detail.fields setValue:@"0" forKey:@"error"];
            [detail.fields setValue:@"0" forKey:@"deleted"];
            
            [EntityManager insert:detail modifiedLocally:NO];
            
        }else {
            info = [[NSString alloc] initWithFormat:NSLocalizedString(@"RECORD_SAVE", Nil),detail.entity];
            [detail.fields setValue:@"0" forKey:@"error"];
            
            [EntityManager update:detail modifiedLocally:YES];
            
        }
        
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@",detail.entity] message:info delegate:self cancelButtonTitle:NSLocalizedString(@"OK", Nil) otherButtonTitles:nil];
        [alert show];
        [alert release];
    
    }else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Validation Error" message:[NSString stringWithFormat: @"Please enter a value for the field %@ ",fieldMissingValue] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];

    }
    
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(updateInfo) [updateInfo didUpdate:detail];
    [self.navigationController popViewControllerAnimated:YES];
    
}


-(void)dealloc {
    [super dealloc];
    [layoutItems release];
    [sectionNameRowSection release];
    [sectionNameOrder release];
    [mapSections release];
    [sections release];
    [detail release];
    
}


//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//   
//    //EditCell *cell = (EditCell *) [[textField superview] superview];     
//    
//    CGRect textFieldRect = [self.tableView convertRect:[[textField superview] bounds] fromView:[textField superview]];
//
//   // [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    
//    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
//    
//        [self.tableView scrollRectToVisible:textFieldRect animated:YES];
//    [UIView commitAnimations];
//
//
//
//
//    
//    return YES;
//}
 


//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    
//    CGRect textFieldRect = [self.tableView convertRect:[[textField superview] bounds] fromView:[textField superview]];
//  //  [self textBeginEditing:textFieldRect];
//}





//-(BOOL) textViewShouldBeginEditing:(UITextView *)textView {
//    self.tableView.frame = tableRect;
//    CGRect textFieldRect = [self.tableView convertRect:[[textView superview] bounds] fromView:[textView superview]];
//   // [self textBeginEditing:textFieldRect];
//    
//    return YES;
//}





/*// Scroll up when keyboard is on
-(void) textBeginEditing:(CGRect)textFieldRect{
    self.tableView.frame = tableRect;
    CGRect viewRect = [self.tableView convertRect:self.tableView.bounds fromView:self.self.tableView];
    
    CGFloat midline = textFieldRect.origin.y + textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0) heightFraction = 0.0;
    else if (heightFraction > 1.0) heightFraction = 1.0;
    
    UIInterfaceOrientation orientation =[[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    else
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    
    CGRect viewFrame = self.tableView.frame;
    viewFrame.origin.y =     viewFrame.origin.y - animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.tableView setFrame:viewFrame];
    [UIView commitAnimations];
    
    
}


// Scroll down after keyboard is off
-(void) textEndEditing {
    
    CGRect viewFrame = self.tableView.frame;
    viewFrame.origin.y = viewFrame.origin.y + animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.tableView setFrame:viewFrame];
    [UIView commitAnimations];
    
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  //  tableRect = self.tableView.frame;
    [self.tableView reloadData];

}




@end
