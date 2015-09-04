//
//  FilterObjectViewController.m
//  SyncForce
//
//  Created by Hun Sokunpheaktra on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterObjectViewController.h"
#import "UpdateListener.h"
#import "EntityManager.h"
#import "FilterElementViewController.h"
#import "FilterObjectManager.h"
#import "AppDelegate.h"
#import "QuartzCore/QuartzCore.h"
#import "FilterManager.h"
#import "ValuesCriteria.h"
#import "SFRequest.h"
#import "MetadataRequest.h"
#import "FilterFieldManager.h"
#import "KeyFieldInfoManager.h"
#import "NotInCriteria.h"
#import "RecordTypeMappingInfoManager.h"
#import "EditLayoutSectionsInfoManager.h"
#import "DetailLayoutSectionsInfoManager.h"
#import "FieldInfoManager.h"
#import "DataType.h"

@implementation FilterObjectViewController


- (id)initWithEntity:(NSString*)newEntity{
    
    entity = newEntity;
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    self.tableView = [[[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.title = [NSString stringWithFormat:@"%@ %@",entity, NSLocalizedString(@"FILTER", nil)];
    
    UIBarButtonItem *barSave = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SAVE", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(saveFilter:)];
    
    self.navigationItem.rightBarButtonItem = barSave;
    
    subOrName = @"";
    
    if ([entity isEqualToString:@"Case"] ||
        [entity isEqualToString:@"Task"] ||
        [entity isEqualToString:@"Event"]
        ) {
        subOrName = @"Subject";
    }
    else if ([entity isEqualToString:@"Contract"]) subOrName = @"Contract Number";
    else subOrName = @"Name";

    if ([entity isEqualToString:@"Event"])
        listFields = [[NSArray alloc] initWithObjects:@"--None--",@"Start Date",@"End Date",@"Created Date",@"Last Modified Date",subOrName, nil];
    else
        listFields = [[NSArray alloc] initWithObjects:@"--None--",@"Created Date",@"Last Modified Date",subOrName, nil];

    
    listItems = [FilterObjectManager list:entity];
    listTypeFields = [[NSMutableDictionary alloc] init];
    for (int i =0; i<[listFields count]; i++) {
        NSString* fieldName = [listFields objectAtIndex:i];
        if ([fieldName isEqualToString:@"Created Date"] || [fieldName isEqualToString:@"Last Modified Date"] ||
            [fieldName isEqualToString:@"Start Date"] || [fieldName isEqualToString:@"End Date"] 
            ) {
              [listTypeFields setObject:@"Date" forKey:fieldName];
        }else [listTypeFields setObject:@"String" forKey:fieldName];
    }
    
    listDateLiteral = [[NSArray alloc] initWithObjects:@"YESTERDAY",@"TODAY",@"TOMORROW",@"LAST_WEEK",@"THIS_WEEK",@"NEXT_WEEK",@"LAST_MONTH",@"THIS_MONTH",@"NEXT_MONTH",@"LAST_90_DAYS",@"NEXT_90_DAYS",@"THIS_QUARTER",@"LAST_QUARTER",@"NEXT_QUARTER",@"THIS_YEAR",@"LAST_YEAR",@"NEXT_YEAR",@"THIS_FISCAL_QUARTER",@"LAST_FISCAL_QUARTER",@"NEXT_FISCAL_QUARTER",@"THIS_FISCAL_YEAR",@"LAST_FISCAL_YEAR",@"NEXT_FISCAL_YEAR", nil];  
    
    field = [[NSMutableDictionary alloc] initWithCapacity:1];
    operat = [[NSMutableDictionary alloc] initWithCapacity:1];
    value = [[NSMutableDictionary alloc] initWithCapacity:1];
    allTextField = [[NSMutableArray alloc] initWithCapacity:1];
    [self initListItems];
    
    listObjects = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableDictionary *criteria = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
    [criteria setValue:[[[ValuesCriteria alloc] initWithString:@"yes"] autorelease] forKey:@"value"];
    for(Item *item in [FilterManager list:criteria]){
        [listObjects addObject:[item.fields valueForKey:@"objectName"]];
    }
    
    [criteria removeAllObjects];
    [criteria setValue:[[[ValuesCriteria alloc] initWithString:entity] autorelease] forKey:@"objectName"];
    listKeyField = [[NSMutableArray alloc] initWithArray:[KeyFieldInfoManager list:criteria]];
    [self getAllListKeyFields];
    
    return self;
}



-(void) getAllListKeyFields {
   
    NSMutableDictionary *cri = [[NSMutableDictionary alloc] init];
    [cri setValue:[[ValuesCriteria alloc] initWithString:@"012000000000000AAA"] forKey:@"RecordTypeId"];
    [cri setValue:[[ValuesCriteria alloc] initWithString:@"Master"] forKey:@"name"];
    [cri setValue:[[ValuesCriteria alloc] initWithString:entity] forKey:@"entity"];
    Item*layout = [RecordTypeMappingInfoManager find:cri];
    
    [cri removeAllObjects];
    [cri setValue:[ValuesCriteria criteriaWithString:entity] forKey:@"entity"];
    if([[[layout fields] objectForKey:@"layoutId"] length]>0)
        [cri setValue:[ValuesCriteria criteriaWithString:[[layout fields] objectForKey:@"layoutId"]] forKey:@"Id"];
    
    NSArray*tmpLayout = [EditLayoutSectionsInfoManager list:cri];
    NSMutableDictionary*dic = [[NSMutableDictionary alloc] init];
    
    for (Item*item in tmpLayout) {
        [dic setValue:[item.fields objectForKey:@"label"] forKey:[item.fields objectForKey:@"value"]];
    }
    
    [cri removeAllObjects];
    [cri setValue:[ValuesCriteria criteriaWithString:entity] forKey:@"entity"];
    [cri setValue:[ValuesCriteria criteriaWithString:[[layout fields] objectForKey:@"layoutId"]] forKey:@"Id"];
    [cri setValue:[[ValuesCriteria alloc] initWithString:@"System Information"] forKey:@"heading"];
    [cri setValue:[[ValuesCriteria alloc] initWithString:@"Field"] forKey:@"type"];
    tmpLayout = [DetailLayoutSectionsInfoManager list:cri];
    for (Item*item in tmpLayout) {
        [dic setValue:@"System Information" forKey:[item.fields objectForKey:@"value"]];
    }
    
    [cri removeAllObjects];
    [cri setValue:[[[ValuesCriteria alloc] initWithString:entity] autorelease] forKey:@"entity"];
    NSArray* listField = [[FieldInfoManager list:cri] retain];
    
    arrayNameLabel = [[NSMutableDictionary alloc] init];
    listLabel= [[NSMutableArray alloc] init];
    
    for (Item* item in listField) {
        NSString*label = [dic objectForKey:[item.fields objectForKey:@"name"]];
        if ([label isEqualToString:@"System Information"]) {
            label = [item.fields objectForKey:@"label"];
            if ([label hasSuffix:@" ID"]) label = [label substringToIndex:[label length]-3];
        }
        
        if ([[dic allKeys] containsObject:[item.fields objectForKey:@"name"]]) { 
            [arrayNameLabel setObject:item forKey:label];
            [listLabel addObject:[NSDictionary dictionaryWithObject:label forKey:@"label"]];
        }
    }
    
    
    NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"label" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
    NSArray *descriptors = [NSArray arrayWithObjects:descriptor, nil];
    NSArray *sortListLabel = [listLabel sortedArrayUsingDescriptors:descriptors];
    [listLabel removeAllObjects];
    for (NSDictionary* dict in sortListLabel) {
        [listLabel addObject:[dict objectForKey:@"label"]];
    }
    
    
    [listField release];
    [cri release];


}

-(void)dealloc{
    [super dealloc];
    [listFields release];
    [operators release];
    [listTypeFields release];
    [listDateLiteral release];
    [field release];
    [operat release];
    [value release];
    [allTextField release];
    [listObjects release];

}

- (void)saveFilter:(id)sender{
    
    for(UITextField *textField in allTextField) [textField resignFirstResponder];
    
    NSMutableArray* array = [[[NSMutableArray alloc] init] autorelease];
    BOOL needWarning = NO;
    
    for(Item *item in listItems){
        NSMutableDictionary *fields = [NSMutableDictionary dictionary];
        
        [fields setValue:entity forKey:@"objectName"];
        [fields setValue:[item.fields valueForKey:@"fieldName"] forKey:@"fieldName"];
        [fields setValue:[item.fields valueForKey:@"fieldLabel"] forKey:@"fieldLabel"];
        [fields setValue:[item.fields valueForKey:@"operator"] forKey:@"operator"];
        [fields setValue:[item.fields valueForKey:@"value"] forKey:@"value"];
                
        NSString *hasField = [item.fields valueForKey:@"fieldLabel"];
        NSString *operatorChosen = [item.fields valueForKey:@"operator"];
        NSString *valueFilter = [item.fields valueForKey:@"value"];
        
        if([hasField length]>0 && [operatorChosen length] >0 && [valueFilter length] >0)  
            [array addObject:fields];
        else if((([hasField length]>0 && [operatorChosen length] == 0) || ([hasField length]>0 && [valueFilter length] == 0))||
                (([operatorChosen length]>0 && [hasField length] == 0) || ([operatorChosen length]>0 && [valueFilter length] == 0)) ||
                ([valueFilter length]>0 && [operatorChosen length] == 0) || ([valueFilter length]>0 && [hasField length] == 0)) 
        {
            needWarning = YES;           
        }
        
        
    }
    
    if(needWarning == YES){
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"FILTER_WARNING", @"") message:NSLocalizedString(@"MESSAGE_FILTER_WARNING", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", Nil) otherButtonTitles:nil];
        [alert show];
        [alert release];
    }else{
        if ([array count]>0) {
            [FilterObjectManager remove:entity];
            for (NSMutableDictionary* fields in array) {
                [FilterObjectManager insert:[[Item alloc] init:@"FilterObject" fields:fields] modifiedLocally:NO];
            }
        }
        
       // AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
       // [delegate refreshTabs];
        
        [self.navigationController popViewControllerAnimated:YES];
    }    
}

-(NSArray*) getOperators:(NSString*)fieldType {
    if ([fieldType isEqualToString:@"Created Date"] || [fieldType isEqualToString:@"Last Modified Date"] || 
        [fieldType isEqualToString:@"Start Date"] || [fieldType isEqualToString:@"End Date"]) 
        operators = [[NSMutableArray alloc] initWithObjects:@"equals",@"not equal to",@"less than",@"greater than",@"less or equal",@"greater or equal", nil];
    else if ([fieldType isEqualToString:subOrName]) operators = [[NSMutableArray alloc] initWithObjects:@"equals",@"not equal to",@"starts with",@"not start with",@"contains",@"does not contain", nil];
    
    return operators;
}

- (void)initListItems{
    
    NSMutableArray *items = [[[NSMutableArray alloc] initWithArray:listItems] autorelease];
    
    while([items count] < 5){
        Item *item = [[Item alloc] init:@"FilterObject" fields:[[NSMutableDictionary alloc] initWithCapacity:1]];
        [item.fields setValue:entity forKey:@"objectName"];
        [items addObject:item];
    }
    listItems = [items copy];
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 }
 */

-(void)mustUpdate:(NSString *)val{
    
}

-(void)updateFieldDisplay:(NSString *)newValue index:(int)index{
    
    Item* newItem = [[Item alloc] init:@"KeyFields" fields:nil];
    [newItem.fields setObject:entity forKey:@"objectName"];
    [newItem.fields setObject:newValue forKey:@"fieldLabel"];
    [newItem.fields setObject:[[[arrayNameLabel objectForKey:newValue]fields]objectForKey:@"name"] forKey:@"fieldName"];
    
    [listKeyField replaceObjectAtIndex:index withObject:newItem];
    
    [KeyFieldInfoManager remove:entity];
    for (Item* item in listKeyField) {
        [KeyFieldInfoManager insert:item];
    }    
    
    [self.tableView reloadData];
    
}

-(void)didUpdate:(Item *)newItem{
    
    
    for(UITextField *textField in allTextField) [textField resignFirstResponder];
    
    Item *item = [listItems objectAtIndex:[[newItem.fields valueForKey:@"tag"] intValue]];
    
    if([[newItem.fields valueForKey:@"header"] isEqualToString:@"Fields"]){
        
        NSString* fieldLabel = [newItem.fields valueForKey:@"value"];
        
        [item.fields setValue:fieldLabel forKey:@"fieldLabel"];
        
        if ([fieldLabel isEqualToString:subOrName])
            [item.fields setValue:[entity isEqualToString:@"Contract"]?@"ContractNumber":subOrName forKey:@"fieldName"];
        else if ([fieldLabel isEqualToString:@"Created Date"])
            [item.fields setValue:@"CreatedDate" forKey:@"fieldName"];
        else if ([fieldLabel isEqualToString:@"Last Modified Date"]) 
            [item.fields setValue:@"LastModifiedDate" forKey:@"fieldName"]; 
        else if ([fieldLabel isEqualToString:@"Start Date"]) 
            [item.fields setValue:@"StartDateTime" forKey:@"fieldName"]; 
        else if ([fieldLabel isEqualToString:@"End Date"]) 
            [item.fields setValue:@"EndDateTime" forKey:@"fieldName"]; 
        
        if ([fieldLabel isEqualToString:@"Created Date"] ||[fieldLabel isEqualToString:@"Last Modified Date"] ||
            [fieldLabel isEqualToString:@"Start Date"] ||[fieldLabel isEqualToString:@"End Date"]
           ) {
            
            if (![listDateLiteral containsObject:[item.fields objectForKey:@"value"]]) {
                [item.fields setObject:@"" forKey:@"operator"];
                [item.fields setObject:@"" forKey:@"value"];
            }
            
        }else if ([fieldLabel isEqualToString:subOrName]){
            
            if ([listDateLiteral containsObject:[item.fields objectForKey:@"value"]] || [[self getOperators:@"Date"] containsObject:[item.fields objectForKey:@"operator"]]) {
                [item.fields setObject:@"" forKey:@"operator"];
                [item.fields setObject:@"" forKey:@"value"];
            }
        }else {
            [item.fields setObject:@"" forKey:@"operator"];
            [item.fields setObject:@"" forKey:@"value"];
        }
        
        
    }else if ([[newItem.fields valueForKey:@"header"] isEqualToString:@"Operator"]){
        [item.fields setValue:[newItem.fields valueForKey:@"value"] forKey:@"operator"];
    }else {
        [item.fields setValue:[newItem.fields valueForKey:@"value"] forKey:@"value"];
    }
    
    [self.tableView reloadData]; 
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([listKeyField count]>0) 
        return 2;
    else return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0) return [listItems count];
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //if(indexPath.section == 1) return 500;
    return 100;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0) return NSLocalizedString(@"FILTER_BY_FIELD", nil) ; // @"Field Filter";
    return NSLocalizedString(@"KEY_INFORMATION", nil);
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    for (UIView *view in [cell.contentView subviews]) [view removeFromSuperview];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(indexPath.section == 0){
        
        Item *item = [listItems objectAtIndex:indexPath.row];
        
        UIButton* requireBntField = [UIButton buttonWithType:UIButtonTypeCustom];
        requireBntField.frame = CGRectMake(20,42, 5, 30);
        requireBntField.backgroundColor = [UIColor redColor];
        requireBntField.hidden = YES ;
        
        if ([[item.fields objectForKey:@"operator"] length] >0 || [[item.fields objectForKey:@"value"] length] >0) {
            if ([[item.fields objectForKey:@"fieldLabel"] length] > 0) {
                requireBntField.hidden = YES;
            } else requireBntField.hidden = NO;
        }
        
        [cell.contentView addSubview:requireBntField];
        
        FilterElementViewController *e1 = [[FilterElementViewController alloc] initWithHeader:@"Fields" title:NSLocalizedString(@"ALL_FIELDS", nil) selectValue:[item.fields valueForKey:@"fieldLabel"] arrItems:listFields frame:CGRectMake(20, 0, (self.tableView.frame.size.width - 50)/4, 80) updateListener:self isFieldDisplay:NO];
        e1.tag = indexPath.row;
        
        [field setValue:e1 forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
        [cell.contentView addSubview:e1.view];
        [e1.view release];         
        
        
        UIButton* requireBntOperator = [UIButton buttonWithType:UIButtonTypeCustom];
        requireBntOperator.frame = CGRectMake(40+((self.tableView.frame.size.width - 50)/4),42, 5, 30);
        requireBntOperator.backgroundColor = [UIColor redColor];
        requireBntOperator.hidden = YES;
        if ([[item.fields objectForKey:@"fieldLabel"] length] >0 || [[item.fields objectForKey:@"value"] length] >0) {
            if ([[item.fields objectForKey:@"operator"] length] > 0) {
                requireBntOperator.hidden = YES;
            }else requireBntOperator.hidden = NO;
        }
        [cell.contentView addSubview:requireBntOperator];
        
        NSArray* listOperator;
        if ([[item.fields objectForKey:@"fieldLabel"] length] > 0) {
            if ([[self getOperators:[item.fields objectForKey:@"fieldLabel"]] count] > 0) {
                listOperator = [self getOperators:[item.fields objectForKey:@"fieldLabel"]];
            }else listOperator = [[NSArray alloc] init]; 
        }else listOperator = [[NSArray alloc] init];    
        
        FilterElementViewController *e2 = [[FilterElementViewController alloc] initWithHeader:@"Operator" title:NSLocalizedString(@"OPERATORS", nil) selectValue:[item.fields valueForKey:@"operator"] arrItems:listOperator frame:CGRectMake(40+((self.tableView.frame.size.width - 50)/4), 0, (self.tableView.frame.size.width - 50)/4, 80) updateListener:self isFieldDisplay:NO];
        e2.tag = indexPath.row;
        [operat setValue:e2 forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
        [cell.contentView addSubview:e2.view];
        [e2.view release];
        
        if ([[item.fields objectForKey:@"fieldLabel"] isEqualToString:subOrName] || [[item.fields objectForKey:@"fieldLabel"] length] == 0) {
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(68+2*((self.tableView.frame.size.width - 50)/4), -3, 200, 40)];
            label.textColor = [UIColor colorWithRed:0.298039 green:0.337255 blue:0.423529 alpha:1];
            label.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
            label.backgroundColor = [UIColor clearColor];
            label.text = NSLocalizedString(@"VALUE", nil);
            [cell.contentView addSubview:label];
            [label release];
            
            UIButton* requiredValue = [UIButton buttonWithType:UIButtonTypeCustom];
            requiredValue.frame = CGRectMake(60+2*((self.tableView.frame.size.width - 50)/4),42, 5, 30);
            requiredValue.backgroundColor = [UIColor redColor];
            requiredValue.hidden = YES;
            if ([[item.fields objectForKey:@"operator"] length] >0 || [[item.fields objectForKey:@"fieldLabel"] length] >0) {
                if ([[item.fields objectForKey:@"value"] length] >0) {
                    requiredValue.hidden = YES;
                }else requiredValue.hidden = NO;
            }
            [cell.contentView addSubview:requiredValue];
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(68+2*((self.tableView.frame.size.width - 50)/4), 35, (self.tableView.frame.size.width - 100)/4, 40)];
            [allTextField addObject:textField];
            textField.tag = indexPath.row;
            textField.delegate = self;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.text = [item.fields valueForKey:@"value"];
            [value setValue:textField forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            
            [cell.contentView addSubview:textField];
            [textField release];
            
        } else {
            
            UIButton* requiredValue = [UIButton buttonWithType:UIButtonTypeCustom];
            requiredValue.frame = CGRectMake(60+2*((self.tableView.frame.size.width - 50)/4),42, 5, 30);
            requiredValue.backgroundColor = [UIColor redColor];
            requiredValue.hidden = YES;
            if ([[item.fields objectForKey:@"operator"] length] >0 || [[item.fields objectForKey:@"fieldLabel"] length] >0) {
                if ([[item.fields objectForKey:@"value"] length] >0) {
                    requiredValue.hidden = YES;
                }else requiredValue.hidden = NO;
            }
            [cell.contentView addSubview:requiredValue];
            
            FilterElementViewController *e3 = [[FilterElementViewController alloc] initWithHeader:@"Values" title:NSLocalizedString(@"VALUE_FILTER", nil) selectValue:[item.fields objectForKey:@"value"] arrItems:listDateLiteral frame:CGRectMake(60+2*((self.tableView.frame.size.width - 50)/4), 0, (self.tableView.frame.size.width - 50)/4, 80) updateListener:self isFieldDisplay:NO];            
            e3.tag = indexPath.row;
            
            [value setValue:e3 forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
            [cell.contentView addSubview:e3.view];
            [e3.view release];    
            
        }
        
        UIButton* bntDelete = [UIButton buttonWithType:UIButtonTypeCustom];
        [bntDelete setFrame:CGRectMake(80+3*((self.tableView.frame.size.width - 50)/4), 40, 30, 30)];
        bntDelete.tag = indexPath.row;
        [bntDelete setBackgroundImage:[UIImage imageNamed:@"delete_record"] forState:UIControlStateNormal];
        [[bntDelete imageView] setContentMode:UIViewContentModeScaleAspectFit];
        [bntDelete addTarget:self action:@selector(removefilter:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.contentView addSubview:bntDelete];
        
    }else {
        
        
        int index = indexPath.row%2 == 0?indexPath.row:indexPath.row%2;
        float wd = (tableView.frame.size.width-160)/4;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(-20, 28, wd-20, 40)];
        label.textColor = [UIColor colorWithRed:0.298039 green:0.337255 blue:0.423529 alpha:1];
        label.textAlignment = UITextAlignmentRight;
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
        label.backgroundColor = [UIColor clearColor];
        label.text = [NSString stringWithFormat:@"%@ %d",@"Column",2*index +1];
        [cell.contentView addSubview:label];
        [label release];
        

        Item* fieldKey = [[listKeyField retain] objectAtIndex:2*index];
        FilterElementViewController *keyField1 = [[FilterElementViewController alloc] initWithHeader:@"none" title:@"Fields" selectValue:[fieldKey.fields objectForKey:@"fieldLabel"] arrItems:listLabel frame:CGRectMake(wd-30, 20,wd+50, 80) updateListener:self isFieldDisplay:NO];
        keyField1.tag = 2*index;  
        [cell.contentView addSubview:keyField1.view];
        [keyField1.view release];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(2*wd, 28, wd - 20, 40)];
        label.textColor = [UIColor colorWithRed:0.298039 green:0.337255 blue:0.423529 alpha:1];
        label.textAlignment = UITextAlignmentRight;
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
        label.backgroundColor = [UIColor clearColor];
        label.text = [NSString stringWithFormat:@"%@ %d",@"Column",2*index+2];
        [cell.contentView addSubview:label];
        [label release];
        
        fieldKey = [[listKeyField retain] objectAtIndex:2*index+1];
        FilterElementViewController *keyField2 = [[FilterElementViewController alloc] initWithHeader:@"none" title:@"Fields" selectValue:[fieldKey.fields objectForKey:@"fieldLabel"] arrItems:listLabel frame:CGRectMake(3*wd -10, 20, wd+50, 80) updateListener:self isFieldDisplay:NO];
        keyField2.tag = 2*index+1;
        
        [cell.contentView addSubview:keyField2.view];
        [keyField2.view release];
         
    }
    
    return cell;
}

-(IBAction)removefilter:(id)sender {
    UIButton* bnt = (UIButton*)sender;
    [[[listItems objectAtIndex:bnt.tag] fields] setValue:@"" forKey:@"fieldLabel"];
    [[[listItems objectAtIndex:bnt.tag] fields] setValue:@"" forKey:@"fieldName"];
    [[[listItems objectAtIndex:bnt.tag] fields] setValue:@"" forKey:@"operator"];
    [[[listItems objectAtIndex:bnt.tag] fields] setValue:@"" forKey:@"value"];
    [self.tableView reloadData];
}


-(void)textFieldDidEndEditing:(UITextField *)textField{
    Item *item = [listItems objectAtIndex:textField.tag];
    [item.fields setValue:textField.text forKey:@"value"];
    [self.tableView reloadData];
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

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.tableView reloadData];
}


@end
