//
//  AddNewViewController.m
//  CRMiOS
//
//  Created by Sy Pauv on 5/13/11.
//  Copyright 2011 Gaeasys. All rights reserved.
//

#import "AddNewViewController.h"
#import "Database.h"

@implementation AddNewViewController
@synthesize  entity,newItem,listField;
@synthesize datePicker;
@synthesize dateFormater;
@synthesize listView;
@synthesize currectTxtField;


-(id)initWithEntity:(NSString *)newEntity withListView:(ListViewController *)newListView withItem:(NSMutableDictionary *)newItemdic;{
    self = [super initWithStyle:UITableViewStyleGrouped];
    self.entity=newEntity;
    self.listView=newListView;
    self.newItem=newItemdic;
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.listField = [LayoutManager readLayout:entity];
    
    UIBarButtonItem *cancel=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    UIBarButtonItem *save=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(done:)];
    
    
    self.title=[NSString stringWithFormat:@"New %@",self.entity];
    self.navigationItem.leftBarButtonItem=cancel;
    self.navigationItem.rightBarButtonItem=save;
    [super viewDidLoad];
    [cancel release];
    [save release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.listField count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[listField objectAtIndex:indexPath.section]];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[listField objectAtIndex:indexPath.section]]autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    
    
    NSString *code = [listField objectAtIndex:indexPath.section];
    CRMField *field=[InfoFactory getField:entity code:code];
    
    [UITools setupEditCell:cell entity:entity field:field value:[newItem objectForKey:field.code] tag:indexPath.section delegate:self iphone:YES];

    
    return cell;}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *code = [listField objectAtIndex:section];
    CRMField *field=[InfoFactory getField:self.entity code:code];
    if (field.mandatory== [NSNumber numberWithBool:YES]) {
        return [NSString stringWithFormat:@"%@ *",field.displayName];
    }
    return field.displayName;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSString *code = [listField objectAtIndex:indexPath.section];
    CRMField *field=[InfoFactory getField:entity code:code];
    if([field.type isEqualToString:@"Picklist"]){
        PickListSelectController *picklist=[[PickListSelectController alloc]initWithEntity:self.entity field:code item:self.newItem updateListener:self];
        [self.navigationController pushViewController:picklist animated:YES];
        [picklist release];
    }

    
}

//After click save it will go to Detail Automatic

-(IBAction)done:(id)sender{
    
    
    for (NSString *field in listField) {
        NSString *value = [self.newItem objectForKey:field];
        if ([field isEqualToString:@"Id"]) {
            continue;
        }
        if(value==nil){
            [self.newItem setValue:@"" forKey:field];
        }
    }
    
    if ([ValidationController checkValidation:self.entity ListItem:newItem]==NO) {
        
        [EntityManager insert:self.entity item:(NSDictionary *)newItem];
        [self.listView goToDetail:newItem];
        [self.navigationController dismissModalViewControllerAnimated:YES];
        
    }
 
  

}

- (IBAction)cancel:(id)sender{
    
    [self dismissModalViewControllerAnimated:YES];	
}

#pragma mark-
#pragma marl TextField handle editing

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {	
    
    NSString *Fieldcode = [listField objectAtIndex:theTextField.tag];
    [newItem setValue:theTextField.text forKey:Fieldcode];
	[theTextField resignFirstResponder];
	return YES;

}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
   
    if(self.datePicker.superview!=nil){
        [self.datePicker removeFromSuperview];
    }
    
    NSString *Fieldcode = [listField objectAtIndex:textField.tag];
    CRMField *field=[InfoFactory getField:entity code:Fieldcode];
    
    if([field.type isEqualToString:@"DateTime"]||[field.type isEqualToString:@"Date"]){
        
        //clear keyboard when we edit field date & dateTime
        
        [currectTxtField resignFirstResponder];
         currectTxtField=textField;
        
        [self showDatePicker];
        return NO;
        
    }else{
        
        currectTxtField=textField;
        
    }
    
    return YES;
}


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    NSString *Fieldcode = [listField objectAtIndex:textField.tag];
    [newItem setValue:textField.text forKey:Fieldcode];
	[textField resignFirstResponder];
    
	return YES;
    
}

// show date/time picker layout

-(void)showDatePicker{
    
    // check if our date picker is already on screen
    
	if (self.datePicker.superview == nil)
	{
        self.datePicker=[[UIDatePicker alloc]init];
        
        NSString *code = [listField objectAtIndex:currectTxtField.tag];
        
        //Set Date and DateTime Format for pickerView
        
        CRMField *field=[InfoFactory getField:entity code:code];
        
        if([field.type isEqualToString:@"DateTime"]){
            
            self.dateFormater = [[[NSDateFormatter alloc] init] autorelease];
            [self.dateFormater setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
            NSDate *date = [self.dateFormater dateFromString:[newItem objectForKey:code]];
            if ([newItem objectForKey:code]==nil) {
                date=[self.dateFormater dateFromString:[self.dateFormater stringFromDate:[NSDate date]]];
            }
            self.datePicker.datePickerMode=UIDatePickerModeDateAndTime;
            [self.datePicker setDate:date];
            
        }else if([field.type isEqualToString:@"Date"]){   
            
            self.dateFormater = [[[NSDateFormatter alloc] init] autorelease];
            [self.dateFormater setDateFormat:@"yyyy-MM-dd"];
            NSDate *date = [self.dateFormater dateFromString:[newItem objectForKey:code]];
            if ([newItem objectForKey:code]==nil) {
                date=[self.dateFormater dateFromString:[self.dateFormater stringFromDate:[NSDate date]]];
            }
            self.datePicker.datePickerMode=UIDatePickerModeDate;
            [self.datePicker setDate:date];
            
        }    
        
        [self.datePicker addTarget:self action:@selector(changeDate) forControlEvents:UIControlEventValueChanged];
        
        [self.view.window addSubview: self.datePicker];
        
        // size up the picker view to our screen and compute the start/end frame origin for our slide up animation
		//
		// compute the start fram
		CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
		
        CGSize pickerSize = [self.datePicker sizeThatFits:CGSizeZero];
		
        CGRect startRect = CGRectMake(0.0,screenRect.origin.y + screenRect.size.height,pickerSize.width, pickerSize.height);
		self.datePicker.frame = startRect;
        
        // compute the end frame
		CGRect pickerRect = CGRectMake(0.0,  screenRect.origin.y + screenRect.size.height - pickerSize.height,  pickerSize.width, pickerSize.height-30);
        
        self.datePicker.frame = pickerRect;
        [self.view.superview addSubview:datePicker];
        
    }
    
}

// handle event change on datePickerView

-(IBAction)changeDate{
    
    NSString *code = [listField objectAtIndex:currectTxtField.tag];
    currectTxtField.text= [UITools formatDateTime:entity code:code value:[self.dateFormater stringFromDate:self.datePicker.date] shortStyle:YES];
    [newItem setValue:[self.dateFormater stringFromDate:self.datePicker.date] forKey:code];
    
}

// hadle event change on UISwitch on/off

-(void)changeSwitch:(id)sender {
    
    
    NSString *code=[listField objectAtIndex:((UISwitch *)sender).tag];
    if (((UISwitch *)sender).on==YES) {
        [newItem setValue:@"true" forKey:code];
    }else{
        [newItem setValue:@"false" forKey:code]; 
    }
    
}


- (void)changeText:(id)sender {
    // do nothing
    UITextField *textfield=(UITextField *)sender;
    NSString *code=[listField objectAtIndex:textfield.tag];
    [newItem setValue:textfield.text forKey:code]; 
    
}


- (void)dealloc
{
    [newItem release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)mustUpdate{
    
    [self.tableView reloadData];
    
}


@end
