//
//  TodayViewController.m
//  CRMiOS
//
//  Created by Sy Pauv on 6/17/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "TodayViewController.h"


@implementation TodayViewController

@synthesize listContact,listActivity;

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"TODAY_VIEW", @"today title for today screen on iphone");
    self.tableView.sectionHeaderHeight = 40;
    [self refreshList];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return MAX(1, [listActivity count]);
    } else {
        return MAX(1, [listContact count]);
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.section == 0) {
        NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:@"Appointment"];
        if ([listActivity count] == 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@.",NSLocalizedString(@"NO", nil), [sinfo localizedPluralName]];
            cell.textLabel.textColor = [UIColor grayColor];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else {
            Item *item = [listActivity objectAtIndex:indexPath.row];
            
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.text = [sinfo getDisplayText:item];
            cell.detailTextLabel.text = [sinfo getDetailText:item];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
        
    } else {
        NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:@"Contact"];
        if ([listContact count] == 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@.",NSLocalizedString(@"NO_CONTACT", nil)];
            cell.textLabel.textColor = [UIColor grayColor];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else {
            Item *item = [listContact objectAtIndex:indexPath.row];
            
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.text = [sinfo getDisplayText:item];
            cell.detailTextLabel.text = [sinfo getDetailText:item];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
        
        
    }
    
    return cell;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self.tableView reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Item *item =nil;
    
    if (indexPath.section==0 ) {
        if ([self.listActivity count] > 0) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            item = [self.listActivity objectAtIndex:indexPath.row];
            DetailViewController *detailController = [[DetailViewController alloc] initWithItem:item listener:nil];
            [self.navigationController pushViewController:detailController animated:YES];
            [detailController release];
        }
        
    } else if (indexPath.section==1) {
        if ([self.listContact count] > 0) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            item = [self.listContact objectAtIndex:indexPath.row];
            DetailViewController *detailController = [[DetailViewController alloc] initWithItem:item listener:nil];
            [self.navigationController pushViewController:detailController animated:YES];
            [detailController release];
        }
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshList];
  
}


- (void)dealloc {
    [listContact release];
    [listActivity release];
    [super dealloc];
}


- (void)refreshList {
    
    NSDate *today = [EvaluateTools getTodayGMT];

    
    self.listContact = [[NSMutableArray alloc] initWithCapacity:1];
    
    BetweenCriteria *criteria = [CalendarUtils buildDateCriteria:today];
    NSArray *appointments = [EntityManager list:@"Appointment" entity:@"Activity" criterias:[NSArray arrayWithObject:criteria]];
    self.listActivity = [NSMutableArray arrayWithArray:appointments];
    
    for (Item *item in self.listActivity) {
        if ([item.fields objectForKey:@"PrimaryContactId"]==nil)continue;
        Item *contact=[EntityManager find:@"Contact" column:@"Id" value:[item.fields objectForKey:@"PrimaryContactId"]];
        if (contact !=nil) {
            [self.listContact addObject:contact];
        }
    }
    
    if ([self.listActivity count]>0) {
        NSArray* reversed = [[self.listActivity reverseObjectEnumerator] allObjects];
        self.listActivity=[NSMutableArray arrayWithArray:reversed];   
    }
    
    [self.tableView reloadData]; 
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	return 56.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    NSString *title = nil;
    switch (section) {
        case 0:
            title = [NSString stringWithFormat:@"%@ (%d) ",NSLocalizedString(@"TODAY_ACTIVITY", nil),[listActivity count]];;
            break;
        case 1:
            title = [NSString stringWithFormat:@"%@ (%d) ",NSLocalizedString(@"TODAY_CONTACT", nil),[listContact count]];
            break;
    }
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
    [v setBackgroundColor:[UIColor clearColor]];
    UIImageView *backGround=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"header.png"]];
    [backGround setFrame:CGRectMake(10,7,tableView.bounds.size.width-20,40)];
    [v addSubview:backGround];
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(50,5, tableView.bounds.size.width - 10,40)] autorelease];
    label.text = title;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.backgroundColor = [UIColor clearColor];
    
    UIImageView *icon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:section==0?@"11-clock-white.png":@"111-user-white.png"]];
    CGRect frame = icon.frame;
    frame.origin = CGPointMake(20, 14);
    [icon setFrame:frame];
    [v addSubview:icon];
    [v addSubview:label];
    
    return v;
}

@end
