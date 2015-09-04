//
//  RecordTypeChooserViewController.m
//  SyncForce
//
//  Created by Gaeasys on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecordTypeChooserViewController.h"

@implementation RecordTypeChooserViewController

@synthesize entityName;

- (id)initWIthListItems:(NSArray*)items parent:(id)parent entityName:(NSString*)entity{
    
    self = [super init];
    listItems = items;
    parentCon = parent;
    self.entityName = entity;    
    self.tableView = [[[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UIView* view = [[[UIView alloc] init] autorelease];
    [view setBackgroundColor:[UIColor colorWithRed:(208.0/255.0) green:(238.0/255.0) blue:(248.0/255.0) alpha:1]];
    self.tableView.backgroundView = view;
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@ %@ %@",NSLocalizedString(@"SELECT", nil),entityName,NSLocalizedString(@"RECORD_TYPE", nil)];
    
    UIBarButtonItem *bntSave = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SAVE", nil) style:UIBarButtonItemStyleBordered target:parent action:@selector(saveRecordType:)] autorelease];
    self.navigationItem.rightBarButtonItem = bntSave;
    
    UIBarButtonItem *bntCancel = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIBarButtonItemStyleBordered target:parent action:@selector(cancelPopupRecordType:)] autorelease];
    self.navigationItem.leftBarButtonItem = bntCancel;
    
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150;
}

//-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return ;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    for (UIView *view in [cell.contentView subviews]) [view removeFromSuperview];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50,10, 300, 40)];
    label.textColor = [UIColor colorWithRed:0.298039 green:0.337255 blue:0.423529 alpha:1];
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    label.backgroundColor = [UIColor clearColor];
    label.text = NSLocalizedString(@"RECORD_TYPE_OF_NEW_RECORD", nil); //@"Record Type of new record"
    [cell.contentView addSubview:label];
    [label release];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(50, 65,7, 40)];
    [button setBackgroundColor:[UIColor redColor]];
    [cell.contentView addSubview:button];
    
    RecordTypeListViewController* recordType = [[RecordTypeListViewController alloc] initWithframe:CGRectMake(50, 50, 350, 80) listItems:listItems updateListener:parentCon];
    [cell.contentView addSubview:recordType.view];
    [recordType release];
    
    return cell;
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

@end
