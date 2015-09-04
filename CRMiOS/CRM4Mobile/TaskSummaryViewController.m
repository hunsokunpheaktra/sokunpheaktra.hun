//
//  TaskSummaryViewController.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 12/14/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "TaskSummaryViewController.h"


@implementation TaskSummaryViewController

@synthesize listVC;
@synthesize myTable, group, headerTitle, dateFormater, selectedId, selectedCell;

- (id)initWithList:(PadListViewController *)newListVC {
    self = [super init];
    self.listVC = newListVC;
    self.dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyy-MM-dd"];
    return self;
}

- (void)dealloc
{
    [dateFormater release];
    [myTable release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    
    UIView *mainView = [[UIView alloc] init];
    [mainView setBackgroundColor:[UIColor yellowColor]];    
    [self setView:mainView];
    self.myTable = [[UITableView alloc]initWithFrame:CGRectNull style:UITableViewStylePlain];
    [self.myTable setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.myTable setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    self.myTable.delegate = self;
    self.myTable.dataSource = self;
    [mainView addSubview:self.myTable];
    [self reloadData];
    //fix header title
    self.headerTitle = [[NSArray alloc] initWithObjects:@"OVERDUE", @"TODAY", @"THIS WEEK", @"NEXT WEEK", @"FUTURE", nil];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [self.group count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSArray *list=[self.group objectAtIndex:section ];
    return [list count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    NSString *title = [self.headerTitle objectAtIndex:section];
    CustomHeader *header = [[[CustomHeader alloc] initWithTitle:NSLocalizedString(title, @"title")] autorelease]; 
    //set header background color
    if ([title isEqualToString:@"FUTURE"]) {
        header.color = [UIColor colorWithRed:105.0f/255.0f green:105.0f/255.0f blue:105.0f/255.0f alpha:1.0];
    } else if([title isEqualToString:@"NEXT WEEK"]){
        header.color = [UIColor colorWithRed:154.0f/255.0f green:205.0f/255.0f blue:50.0f/255.0f alpha:1.0];
    } else if([title isEqualToString:@"THIS WEEK"]){
        header.color = [UIColor colorWithRed:50.0f/255.0f green:205.0f/255.0f blue:50.0f/255.0f alpha:1.0];
    } else if([title isEqualToString:@"TODAY"]){
        header.color = [UIColor colorWithRed:34.0f/255.0f green:139.0f/255.0f blue:34.0f/255.0f alpha:1.0];
    } else if([title isEqualToString:@"OVERDUE"]){
        header.color = [UIColor colorWithRed:165.0f/255.0f green:42.0f/255.0f blue:42.0f/255.0f alpha:1.0];
    }
    return header;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35.0;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *list = [self.group objectAtIndex:indexPath.section];
    Item *item = [list objectAtIndex:indexPath.row];
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    
	// Configure the cell...
	cell.textLabel.text = [listVC.sinfo getDisplayText:item];
    cell.detailTextLabel.text = [listVC.sinfo getDetailText:item];
    NSString *icon = [listVC.sinfo getIcon:item];
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];

    // Set up the cell backgroundcolor    
    UIView *bg = [[UIView alloc] initWithFrame:cell.frame];
    if ([item.fields objectForKey:@"error"] != nil) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"row_error.png"]];
        [imageView setFrame:CGRectMake(0, 0, 16, 16)];
        [bg addSubview:imageView];
        [imageView release];
    } else if ([[item.fields objectForKey:@"modified"] isEqualToString:@"1"] && [item.fields objectForKey:@"Id"] !=nil ) {        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"row_updated.png"]];
        [imageView setFrame:CGRectMake(0, 0, 16, 16)];
        [bg addSubview:imageView];
        [imageView release];
        
    } else if ([[item.fields objectForKey:@"modified"] isEqualToString:@"1"] && [item.fields objectForKey:@"Id"] == nil){
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"row_new.png"]];
        [imageView setFrame:CGRectMake(0, 0, 16, 16)];
        [bg addSubview:imageView];
        [imageView release];
    }
    
    cell.backgroundView = bg;
    [bg release];
    
    if (icon != Nil) {
        cell.imageView.image = [UIImage imageNamed:icon];
    } else {
        cell.imageView.image = Nil;
    }
    
    //accessory view
    NSDate *dueDate = [dateFormater dateFromString:[item.fields objectForKey:@"DueDate"]];
    NSDateFormatter *MMDD = [[[NSDateFormatter alloc] init] autorelease];
    [MMDD setDateFormat:@"MMM dd"];
    

    UILabel *dateview = [[UILabel alloc] initWithFrame:CGRectMake(0 ,0, 70, 32)];
    dateview.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    dateview.textAlignment = UITextAlignmentRight;
    dateview.tag = 1000;
    [dateview setFont:[UIFont boldSystemFontOfSize:12.0f]];
    [dateview setText:[MMDD stringFromDate:dueDate]];

    cell.accessoryView = dateview;
    [dateview release];
    return cell;
    
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedCell != nil) {
        ((UILabel *) self.selectedCell.accessoryView).textColor = [UIColor blackColor];
    }
    NSArray *list = [self.group objectAtIndex:indexPath.section];
    Item *item = [list objectAtIndex:indexPath.row];
    self.selectedId = [item.fields objectForKey:@"gadget_id"];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];  
    ((UILabel *) cell.accessoryView).textColor = [UIColor whiteColor];
    self.selectedCell = cell;
    [self.listVC.parent.itemViewController setCurrentDetail:item];
    
}

- (void)selectItem:(NSString *)key {
    for (int i = 0; i < [self.group count]; i++) {
        NSArray *items = [self.group objectAtIndex:i];
        for (int j = 0; j < [items count]; j++) {
            Item *item = [items objectAtIndex:j];
            if ([[item.fields objectForKey:@"gadget_id"] isEqualToString:key]) {
                [self.myTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
                return;
            }
        }
    }
}

- (void)reloadData {
    self.group = [self getGroup];
    [self.myTable reloadData];
}

- (NSArray *)getGroup {
    NSMutableArray *tmpgroup = [[NSMutableArray alloc]initWithCapacity:1];
    [tmpgroup addObject:[self getOverdue]];
    [tmpgroup addObject:[self getToday]];
    [tmpgroup addObject:[self getThisWeek]];
    [tmpgroup addObject:[self getNextWeek]];
    [tmpgroup addObject:[self getFuture]];
    return [tmpgroup autorelease];
}

- (NSArray *)getOverdue {
    
    NSMutableArray *criterias = [NSMutableArray arrayWithObject:[self getCriteria:@"OVERDUE"]];
    [criterias addObject:[[NotInCriteria alloc]initWithColumn:@"Status" values:[[NSArray alloc]initWithObjects:@"Completed",nil]]];
    NSArray *items = [EntityManager list:self.listVC.subtype entity:self.listVC.sinfo.entity criterias:criterias];
    return items;    
    
}
- (NSArray *)getToday{
  
    NSMutableArray *criterias = [NSMutableArray arrayWithObject:[[ValuesCriteria alloc]initWithColumn:@"DueDate" value:[dateFormater stringFromDate:[NSDate date]]]];
    NSArray *items = [EntityManager list:self.listVC.subtype entity:self.listVC.sinfo.entity criterias:criterias];
    return items; 
}
- (NSArray *)getThisWeek{
 

    NSMutableArray *criterias = [NSMutableArray arrayWithObject:[self getCriteria:@"THIS WEEK"]];
    NSObject<Criteria> *notin=[[[NotInCriteria alloc]initWithColumn:@"DueDate" values:[[NSArray alloc]initWithObjects:[dateFormater stringFromDate:[NSDate date]], nil]]autorelease];
    [criterias addObject:notin];
    
    NSArray *items = [EntityManager list:self.listVC.subtype entity:self.listVC.sinfo.entity criterias:criterias];
    return items; 
}
- (NSArray *)getNextWeek{
      
    NSMutableArray *criterias = [NSMutableArray arrayWithObject:[self getCriteria:@"NEXT WEEK"]];
    NSArray *items = [EntityManager list:self.listVC.subtype entity:self.listVC.sinfo.entity criterias:criterias];
    return items; 
}
- (NSArray *)getFuture{

    NSMutableArray *criterias = [NSMutableArray arrayWithObject:[self getCriteria:@"FUTURE"]];
    NSArray *items = [EntityManager list:self.listVC.subtype entity:self.listVC.sinfo.entity criterias:criterias];
    return items; 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (NSObject<Criteria> *)getCriteria:(NSString *)option{

    NSDate *today = [[NSDate alloc] init];
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    BetweenCriteria *between;

    if ([option isEqualToString:@"OVERDUE"]) {
        
        [offsetComponents setDay:-1];
        NSDate *endate= [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
        [offsetComponents setDay:-7];
        NSDate *startDate=[gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
        between=[[[BetweenCriteria alloc]initWithColumn:@"DueDate" start:[dateFormater stringFromDate:startDate] end:[dateFormater stringFromDate:endate]]autorelease];
      
    } else if ([option isEqualToString:@"THIS WEEK"] || [option isEqualToString:@"NEXT WEEK"] ||[option isEqualToString:@"FUTURE"]){
        
        NSDateComponents *weekdayComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:today];
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay: - ([weekdayComponents weekday] - ([gregorian firstWeekday]))];
        NSDate *startDate = [gregorian dateByAddingComponents:componentsToSubtract toDate:today options:0];
        NSDateComponents *components = [gregorian components: (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)fromDate: startDate];
        startDate = [gregorian dateFromComponents: components];
        [offsetComponents setDay:7];
        NSDate *endate=[gregorian dateByAddingComponents:offsetComponents toDate:startDate options:0];
     
        if ([option isEqualToString:@"NEXT WEEK"] || [option isEqualToString:@"FUTURE"]) {
        
            //for next week get the first day of next week to the end of next week
            [offsetComponents setDay:1];
            startDate = [gregorian dateByAddingComponents:offsetComponents toDate:endate options:0];
            [offsetComponents setDay:7];
            endate = [gregorian dateByAddingComponents:offsetComponents toDate:startDate options:0];
    
            if ([option isEqualToString:@"FUTURE"]) {

                //for future get the day after next week for 90 days
                [offsetComponents setDay:1];
                startDate = [gregorian dateByAddingComponents:offsetComponents toDate:endate options:0];
                [offsetComponents setDay:90];
                 endate = [gregorian dateByAddingComponents:offsetComponents toDate:startDate options:0];
            }
        
        } else if([option isEqualToString:@"THIS WEEK"]) {
            [offsetComponents setDay:1];
            startDate = [gregorian dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
        }        
        
        between = [[[BetweenCriteria alloc]initWithColumn:@"DueDate" start:[dateFormater stringFromDate:startDate] end:[dateFormater stringFromDate:endate]]autorelease];
              
    }

    return between;
}


@end
