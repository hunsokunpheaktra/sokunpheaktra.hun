//
//  DetailViewController.m
//  SyncForce
//
//  Created by Gaeasys Admin on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "Section.h"
#import "CustomCell.h"
#import "DetailLayoutSectionsInfoManager.h"
#import "EntityManager.h"
#import "Entity.h"
#import "InfoFactory.h"
#import "ValuesCriteria.h"

@implementation DetailViewController
@synthesize detail,detailView;
@synthesize sections,layoutItems;

- (id)init:(Item*)item{
    [super init];
    
    item = [[EntityManager list:@"Account" criterias:[[NSDictionary alloc] init]] objectAtIndex:0];
    self.detail = item;
    self.layoutItems = [[NSMutableDictionary alloc] initWithCapacity:1];
    entityInfo = [InfoFactory getInfo:self.detail.entity];
    self.title = [NSString stringWithFormat:@"%@ (%@)",[entityInfo getLabel],[self.detail.fields valueForKey:@"Name"]];
    
    //Group items(Field) by heading
    NSMutableArray *sectionNameOrder = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableDictionary *mapSections = [[NSMutableDictionary alloc] initWithCapacity:1];
    NSMutableDictionary *filters = [[NSMutableDictionary alloc] initWithCapacity:1];
    [filters setValue:[ValuesCriteria criteriaWithString:self.detail.entity ] forKey:@"entity"];
    for(Item *item in [DetailLayoutSectionsInfoManager list:filters]){
        NSString *heading = [item.fields valueForKey:@"heading"];
        if(![mapSections.allKeys containsObject:heading]){
            [sectionNameOrder addObject:heading];
            NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:1];
            [mapSections setValue:items forKey:heading];
        }
        [[mapSections objectForKey:heading] addObject:item];
    }
    
    NSMutableArray *detailSections = [[NSMutableArray alloc] initWithCapacity:1];
    for(NSString *heading in sectionNameOrder){
        Section *section = [[Section alloc] initWithName:heading];
        for(Item *item in [mapSections valueForKey:heading]){
            NSString *fieldname = [item.fields valueForKey:@"value"];
            [section.fields addObject:fieldname];
            [self.layoutItems setValue:item forKey:fieldname];
        }
        [detailSections addObject:section];
    }
    
    sections = detailSections;
    return self;
}

- (void)loadView {

    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit)];
    [self.navigationItem setRightBarButtonItem:editButton];    
    
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self setView:mainView];
    
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0.1 green:0.3 blue:0.5 alpha:1.0]];
    
    self.detailView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 200, 200) style:UITableViewStyleGrouped];
    self.detailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.detailView.delegate = self;
    self.detailView.dataSource = self;
    self.detailView.sectionHeaderHeight = SETTING_HEADER_HEIGHT;
    [mainView addSubview:self.detailView];
    
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
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(92, 0, SETTING_HEADER_ROW_WIDTH, SETTING_HEADER_HEIGHT)];
    label.font = [UIFont boldSystemFontOfSize:SETTING_HEADER_FONT_SIZE];
    label.textAlignment = UITextAlignmentLeft;
    label.highlightedTextColor = [UIColor whiteColor];
    label.textColor = [UIColor darkGrayColor];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0, 1);
    label.backgroundColor = [UIColor clearColor];
    label.text = [[sections objectAtIndex:section] name];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(46, 0, 48, 48)];
    button.tag = section;
    [button setBackgroundImage:[UIImage imageNamed:[[[self.sections objectAtIndex:section] fields] count] > 0 ? @"toggle-down.png" : @"toggle-right.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickToCollape:) forControlEvents:UIControlEventTouchUpInside];
    [hdrView addSubview:button];     
    [hdrView addSubview:label];
    
    return hdrView;
}

- (void)clickToCollape:(id)sender{
    
    UIButton *button = (UIButton *)sender;
    NSMutableArray *indexes = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *list = [self.sections objectAtIndex:button.tag];
    
    if ([list count] > 0) {
        [button setBackgroundImage:[UIImage imageNamed:@"toggle-right.png"] forState:UIControlStateNormal];
        for (int i = 0; i < [list count]; i++) {
            [indexes addObject:[NSIndexPath indexPathForRow:i inSection:button.tag]];
        }
        
        [list removeAllObjects]; // must delete before animating
        [self.detailView deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];     
    } else {
        // must add before animating
        [list addObjectsFromArray:[self fillSection:button.tag]];
        [button setBackgroundImage:[UIImage imageNamed:@"toggle-down.png"] forState:UIControlStateNormal];
        for (int i = 0; i < [list count]; i++) {
            [indexes addObject:[NSIndexPath indexPathForRow:i inSection:button.tag]];
        }
        [self.detailView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];
    }
    
}

- (NSMutableArray *)fillSection:(int)section {
    NSMutableArray *tmpData = [[NSMutableArray alloc] initWithCapacity:1];
    
    
    return tmpData;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat result = 45;
//    if(indexPath.section < [self.sections count]){
//        Section *section = [self.sections objectAtIndex:indexPath.section];
//        if ([section.isGrouping boolValue]){
//            result = 55;
//        }
//    }
    return result;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier1 = @"Cell1";
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
    if (cell == nil) {
        cell = [[[CustomCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier1] autorelease];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
     
    // Configure the cell...
    Section *section = [self.sections objectAtIndex:indexPath.section];
    NSString *fieldname = [section.fields objectAtIndex:indexPath.row];
    Item *fieldInfo = [self.layoutItems valueForKey:fieldname];
    
    cell.textLabel.text = [fieldInfo.fields valueForKey:@"label"];
    cell.detailTextLabel.text = [detail.fields valueForKey:fieldname];
    
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


- (void)dealloc {
    [detail release];
    [detailView release];
    [super dealloc];
}
@end
