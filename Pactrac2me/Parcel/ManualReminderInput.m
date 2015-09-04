//
//  ManualReminderInput.m
//  Parcel
//
//  Created by Sy Pauv on 12/5/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "ManualReminderInput.h"

@interface ManualReminderInput ()
-(void)cancel;
-(void)save;
@end

@implementation ManualReminderInput

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.defalutValue ==nil ||[self.defalutValue isEqualToString:@""]) {
        self.option= @"DAYS";
        self.amount=@"0";
    }else{
        NSArray *values=[NSLocalizedString(self.defalutValue, @"") componentsSeparatedByString:@" "];
        if (values!=nil &&[values count]>1) {
            self.option=[values objectAtIndex:1];
            if ([self.option rangeOfString:WEEK].location != NSNotFound)
                self.option = @"WEEKS";
            
            self.amount=[values objectAtIndex:0];
        }
    }

    self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc]initWithTitle:MSG_OK style:UIBarButtonItemStyleDone target:self action:@selector(save)]autorelease];
    self.navigationItem.leftBarButtonItem=[[[UIBarButtonItem alloc]initWithTitle:ABORT style:UIBarButtonItemStylePlain target:self action:@selector(cancel)]autorelease];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    // cleanup all the previous views
    for (UIView *view in [cell.contentView subviews]) {
        [view removeFromSuperview];
    }
    CGRect bounds=[cell.contentView bounds];
    CGRect rect = CGRectInset(bounds, 9.0, 9.0);
    // Configure the cell...
    cell.accessoryType=UITableViewCellAccessoryNone;
    if (indexPath.row==0) {
        UITextField *textField = [[UITextField alloc] initWithFrame:rect];
        textField.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        [textField setBorderStyle:UITextBorderStyleNone];
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
        [textField setKeyboardAppearance:UIKeyboardAppearanceDefault];
        textField.tag=indexPath.section;
        textField.text=self.amount;
        [textField setPlaceholder:INDIVIDUAL_DAYS_WEEK_INPUT];
        [textField setClearsOnBeginEditing:YES];
        [textField addTarget:self action:@selector(textChange:) forControlEvents:UIControlEventEditingChanged];
        [cell.contentView addSubview:textField];
        [textField release];
    }else{
        cell.textLabel.text= NSLocalizedString(self.option, @"");
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==1) {
        [self.view endEditing:YES]; 
        PicklistPopupShowView *picklistPopup = [[PicklistPopupShowView alloc] initWithListDatas:@[@"DAYS",@"WEEKS"] frame:[UIScreen mainScreen].bounds mainView:self.view selectedVal:self.option type:@"picklist"];
        picklistPopup.fieldName = @"option";
        picklistPopup.title = OPTION;
        picklistPopup.updateListener = self;
        [picklistPopup show:[tableView cellForRowAtIndexPath:indexPath]];
    }
}

- (void)textChange:(id)sender{
    self.amount=((UITextField *)sender).text;
}

#pragma mark -Action

-(void)save{
    if (self.listener) {
        [self.listener didUpdate:nil value:[NSString stringWithFormat:@"%@ %@",self.amount,self.option]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)cancel{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - updatelistener
-(void)didUpdate:(NSString*)fName value:(NSString*)value{
    self.option=value;
    [self.tableView reloadData];
}
-(void)mustUpdate:(Item*)item{

}

@end
