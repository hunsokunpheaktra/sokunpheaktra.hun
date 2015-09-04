//
//  CustomDataGridNewItem.m
//  SyncForce
//
//  Created by Gaeasys on 10/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomDataGridNewItem.h"
#import "Entity.h"
#import "EntityManager.h"
#import "EditViewController.h"


@class CustomDataGrid;

@implementation CustomDataGridNewItem

@synthesize myItem,entityName,bntTarget,bntSave;


- (id)initWithObjectName:(NSString *)aEntityName target:(id)target{
    
    entityName = aEntityName;
    bntTarget = target;
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    
    UIControl *controltype;
    
    NSMutableDictionary *dicFields = [[[NSMutableDictionary alloc] init] autorelease];
    NSArray *fieldsInfo = [Entity getFieldsCreateable:entityName];
    int start_y = 40;
    
    for(Item *item in fieldsInfo){
        
        NSDictionary *dic = [[[NSDictionary alloc] initWithObjectsAndKeys:@"",[item.fields objectForKey:@"name"],nil] autorelease];
        [dicFields addEntriesFromDictionary:dic];
        
        UILabel *fieldName = [[UILabel alloc] initWithFrame:CGRectMake(50, start_y, 250, 20)];
        fieldName.font = [UIFont systemFontOfSize:12];
        fieldName.text = [item.fields objectForKey:@"label"];
        [fieldName setTextAlignment:UITextAlignmentRight];
        
        if ([[item.fields valueForKey:@"type"] isEqualToString:@"string"]   ||
            [[item.fields valueForKey:@"type"] isEqualToString:@"date"]     ||
            [[item.fields valueForKey:@"type"] isEqualToString:@"datetime"] ||
            [[item.fields valueForKey:@"type"] isEqualToString:@"int"]      ||
            [[item.fields valueForKey:@"type"] isEqualToString:@"double"]   ||
            [[item.fields valueForKey:@"type"] isEqualToString:@"currency"] ||
            [[item.fields valueForKey:@"type"] isEqualToString:@"percent"]  ||
            [[item.fields valueForKey:@"type"] isEqualToString:@"textarea"] ||
            [[item.fields valueForKey:@"type"] isEqualToString:@"picklist"] ||
            [[item.fields valueForKey:@"type"] isEqualToString:@"reference"]||
            [[item.fields valueForKey:@"type"] isEqualToString:@"url"]      ||
            [[item.fields valueForKey:@"type"] isEqualToString:@"phone"]
            ) {
            
            UITextField *textEdit = [[UITextField alloc] initWithFrame:CGRectMake(320, start_y, 260, 20)];
            textEdit.autocorrectionType = UITextAutocorrectionTypeNo;
            textEdit.autocapitalizationType = UITextAutocapitalizationTypeNone;
            textEdit.font = [UIFont systemFontOfSize:12];
            textEdit.borderStyle = UITextBorderStyleRoundedRect;
            textEdit.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            
            [[textEdit layer] setValue:[item.fields objectForKey:@"name"] forKey:@"label"];
            [textEdit addTarget:self action:@selector(testSave:) forControlEvents:UIControlEventEditingDidEnd];
            
            controltype = textEdit;
            [textEdit release];
            
        } else if ([[item.fields valueForKey:@"type"] isEqualToString:@"boolean"]) {
            
            UIButton *toggleButtonField = [UIButton buttonWithType:UIButtonTypeCustom];
            [toggleButtonField setFrame:CGRectMake(305, start_y, 50, 20)];
            [toggleButtonField setImage:[UIImage imageNamed:@"checkBoxUnChecked"] forState:UIControlStateNormal];
            
            [toggleButtonField addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
			
            controltype = toggleButtonField;
            [toggleButtonField release];
            
        } 
        
        start_y +=20;
        [fieldName release];
    }
    
    myItem = [[Item alloc] init:entityName fields: dicFields];
    EditViewController *modelView = [[EditViewController alloc] init:myItem mode:@"add" objectId:nil relationField:nil];
    self.view = modelView.view;
    [modelView release];
    
    [super viewDidLoad];
    
}


- (void) buttonPressed:(id)sender {
    
    UIButton *toggleButton = (UIButton *)sender;
    
    if ([toggleButton imageForState:UIControlStateNormal] == [UIImage imageNamed:@"checkBoxChecked"])
    {
        [toggleButton setImage:[UIImage imageNamed:@"checkBoxUnChecked"] forState:UIControlStateNormal];
    }
    else if ([toggleButton imageForState:UIControlStateNormal] == [UIImage imageNamed:@"checkBoxUnChecked"])
    {
        [toggleButton setImage:[UIImage imageNamed:@"checkBoxChecked"] forState:UIControlStateNormal];
    }
    
}

- (void) testSave :(id)sender {
    
    UITextField *field = (UITextField *)sender;
    [myItem.fields setValue:field.text forKey:[[sender layer] valueForKey:@"label"]];
    
}


- (void) saveNewItem:(id)sender {
    
   // [[(CustomDataGrid *)bntTarget listener] saveOneRecord:myItem];
   // [(CustomDataGrid *)bntTarget testAnimated:bntSave];
    [[(CustomDataGrid *)bntTarget dataTable ] reloadData];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
