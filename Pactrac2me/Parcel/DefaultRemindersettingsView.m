//
//  DefaultDemindersettingsView.m
//  Parcel
//
//  Created by Sy Pauv on 12/4/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "DefaultRemindersettingsView.h"

@interface DefaultRemindersettingsView ()
-(void)done;
@end
@implementation DefaultRemindersettingsView
-(id)inithWithItem:(Item *)item{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.workItem=[[Item alloc]init:@"Setting" fields:[NSMutableDictionary dictionaryWithDictionary:item.fields]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = REMINDER_SETTING;
    
    self.isCustom=[[self.workItem.fields objectForKey:@"isManual"] isEqualToString:@"yes"];
    self.customValue= [self.workItem.fields objectForKey:@"defaultReminderSetting"];
    self.defaultsetting= NSLocalizedString([self.workItem.fields objectForKey:@"defaultReminderSetting"], @"");
    self.settings=@[@"1 WEEKS",@"2 WEEKS",@"4 WEEKS",MANUAL_INPUT];
    
    self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc]initWithTitle:MSG_OK style:UIBarButtonItemStyleDone target:self action:@selector(save)]autorelease];
    self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc]initWithTitle:MSG_SAVE style:UIBarButtonItemStyleBordered target:self action:@selector(done)]autorelease];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.settings count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    cell.accessoryType=UITableViewCellAccessoryNone;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    
    NSString* unit = [[[self.settings objectAtIndex:indexPath.row] componentsSeparatedByString:@" "] objectAtIndex:1];
    NSString* amount = [[[self.settings objectAtIndex:indexPath.row] componentsSeparatedByString:@" "] objectAtIndex:0];
    
    NSString *value = [NSString stringWithFormat:@"%@ %@",amount,unit];
    cell.textLabel.text = value;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
    
    unit = [[self.defaultsetting componentsSeparatedByString:@" "] objectAtIndex:1];
    amount = [[self.defaultsetting componentsSeparatedByString:@" "] objectAtIndex:0];
    NSString* tm =[NSString stringWithFormat:@"%@ %@",amount,unit];
    
    if ([value isEqualToString:tm]  && !self.isCustom) {
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }
    
    if ([value isEqualToString:@"Manual Input"]) {
        cell.selectionStyle=UITableViewCellSelectionStyleBlue;
        if (self.isCustom) {
            cell.accessoryType=UITableViewCellAccessoryCheckmark;
        }
        
        unit = [[self.customValue componentsSeparatedByString:@" "] objectAtIndex:1];
        amount = [[self.customValue componentsSeparatedByString:@" "] objectAtIndex:0];
        
        value = [NSString stringWithFormat:@"%@ %@",amount,unit];
    
        cell.detailTextLabel.text= value ;
    }
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    NSString *value = [self.settings objectAtIndex:indexPath.row];
    self.defaultsetting= value;
    
    if ([value isEqualToString:@"Manual Input"]) {
        
        ManualReminderInput *manualinput = [[ManualReminderInput alloc]initWithStyle:UITableViewStyleGrouped];
        manualinput.listener=self;
        manualinput.defalutValue=self.customValue;
        
        UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:manualinput];
        nav.navigationBar.tintColor = [UIColor colorWithRed:0.1 green:0.3 blue:0.5 alpha:1.0];
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self presentViewController:nav animated:YES completion:nil];
        [nav release];
        [manualinput release];
    }else{
        self.isCustom=FALSE;
        [self.tableView reloadData];
    }
}

-(void)done{
    NSString *value=self.isCustom?self.customValue:self.defaultsetting;
    [self.workItem.fields setObject:self.isCustom?@"yes":@"no" forKey:@"isManual"];
    [self.workItem.fields setObject:value forKey:@"defaultReminderSetting"];
    [self.listener didselect:self.workItem];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma  mark - updatelistener

-(void)didUpdate:(NSString*)fName value:(NSString*)value{
    self.customValue = value;
    self.isCustom = TRUE;
    [self.tableView reloadData];
}
-(void)mustUpdate:(Item*)item{
}
@end
