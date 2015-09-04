//
//  DetailFilterViewController.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/25/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "DetailFilterViewController.h"


@implementation DetailFilterViewController

@synthesize dateFilters;
@synthesize ownerFilters;
@synthesize entity;
@synthesize dateFilter;
@synthesize ownerFilter;
@synthesize enabled;
@synthesize switchBtn;
@synthesize parent;

- (id)initWithEntity:(NSString *)newEntity parent:(NSObject <UpdateListener> *)pParent {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.parent = pParent;
        self.entity = newEntity;
        self.ownerFilters = [NSArray arrayWithObjects:@"Broadest", @"Sales Rep", @"Personal", nil];
        self.dateFilters = [NSArray arrayWithObjects:@"All", @"Last Year", @"Last Month", @"Last Week", nil];
        NSObject <Subtype> *sinfo =  [[[Configuration getInfo:entity] getSubtypes] objectAtIndex:0];
        self.title = [NSString stringWithFormat:NSLocalizedString(@"OBJECT_FILTER", @"Object filter"), [sinfo localizedName]];
        self.ownerFilter = [PropertyManager read:[NSString stringWithFormat:@"ownerFilter%@", self.entity]];
        self.dateFilter = [PropertyManager read:[NSString stringWithFormat:@"dateFilter%@", self.entity]];
        self.enabled = [PropertyManager read:[NSString stringWithFormat:@"sync%@", self.entity]];
        
        switchBtn = [[UISwitch alloc] init];
        [switchBtn setOn:[self.enabled isEqualToString:@"true"]];
        [switchBtn addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    tableView.sectionFooterHeight = 10;
    if(section == 0 && isChange){
        tableView.sectionFooterHeight = 60;
        UITextView *textInfo = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
        textInfo.editable = NO;
        textInfo.font = [UIFont boldSystemFontOfSize:14];
        textInfo.textColor = [UIColor redColor];
        textInfo.text = NSLocalizedString(@"CONFIRM_SYNC", @"Confirm");
        textInfo.backgroundColor = [UIColor clearColor];
        return textInfo;
    }
    return nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return Nil;
    } else if (section == 1) {
        return NSLocalizedString(@"OWNER_FILTER", @"header label 'owner filter'");
    } else {
        return NSLocalizedString(@"LAST_MOD_FILTER", @"header label 'last modify filter'");
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.enabled isEqualToString:@"true"] ? 3 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return [self.ownerFilters count];
    } else {
        return [self.dateFilters count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    if (indexPath.section == 0) {
        [cell setAccessoryView:switchBtn];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell.textLabel setText:NSLocalizedString(@"ENABLED", @"Enabled")];
    } else {
        [cell setAccessoryView:Nil];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        NSString *value, *current;
        if (indexPath.section == 1) {
            value = [self.ownerFilters objectAtIndex:indexPath.row];
            current = self.ownerFilter;
            NSObject <Subtype> *sinfo =  [[[Configuration getInfo:entity] getSubtypes] objectAtIndex:0];

            if ([value isEqualToString:@"Broadest"]) {
                [cell.textLabel setText:[NSString stringWithFormat:@"All %@", [sinfo localizedPluralName]]];
            } else if ([value isEqualToString:@"Sales Rep"]) {
                [cell.textLabel setText:[NSString stringWithFormat:@"My Team %@", [sinfo localizedPluralName]]];
            } else {
                [cell.textLabel setText:[NSString stringWithFormat:@"My %@", [sinfo localizedPluralName]]];
            }
        } else {
            value = [self.dateFilters objectAtIndex:indexPath.row];
            current = self.dateFilter;
            [cell.textLabel setText:value];
        }
        
        if ([current isEqualToString:value]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    isChange = NO;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    for (int i = 0; i < [tableView numberOfRowsInSection:indexPath.section]; i++) {
        [[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexPath.section]] setAccessoryType:UITableViewCellAccessoryNone];
    }
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    NSString *property, *value;
    if (indexPath.section == 1) {
        property = [NSString stringWithFormat:@"ownerFilter%@", self.entity];
        value = [self.ownerFilters objectAtIndex:indexPath.row];
        self.ownerFilter = value;
    } else {
        property = [NSString stringWithFormat:@"dateFilter%@", self.entity];
        value = [self.dateFilters objectAtIndex:indexPath.row];
        self.dateFilter = value;
    }
    if(![[PropertyManager read:property] isEqualToString:value]){
        isChange = YES;
        [self.tableView reloadData];
    }
    [PropertyManager save:property value:value];
}

- (void)switchChanged:(id)sender {
    self.enabled = [switchBtn isOn] ? @"true" : @"false";
    [PropertyManager save:[NSString stringWithFormat:@"sync%@", self.entity] value:self.enabled];
    if (![switchBtn isOn]) {
        
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:UITableViewRowAnimationFade];
        
    } else {
        
        [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:UITableViewRowAnimationFade];
        
        //If the user deactive an object all information should be delete
        [[Database getInstance]remove:entity criterias:nil];
    }
    [TabTools buildTabs:self.tabBarController];
    [parent mustUpdate];
}

@end
