//
//  DragAndDropViewController.m
//  CRMiOS
//
//  Created by Sy Pauv on 10/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "DragAndDropViewController.h"


@implementation DragAndDropViewController

@synthesize contactData, dstData;
@synthesize calendar, selectedDate;
@synthesize nameFilter, filter, uIsearchBar;
@synthesize barinfo;

#pragma mark -
#pragma mark UIViewController


- (void)viewDidLoad{
    
    self.title = NSLocalizedString(@"CALENDAR", @"Calendar");
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    
    self.view.clipsToBounds = NO;
    CGRect rect=[[UIScreen mainScreen]bounds];
    int width = rect.size.width;
    int height = rect.size.height;
    
    // set up data
    [self getContactData];
    [self filterAppointmentData];
    
    draggedCell = nil;
    draggedData = nil;
    pathFromDstTable = nil;
    
    //view calendar
    self.calendar = [[TKCalendarMonthView alloc] init];
    self.calendar.delegate = self;
    self.calendar.dataSource = self;
    calendar.frame = CGRectMake(0, 0, calendar.frame.size.width , calendar.frame.size.height);
    [calendar reload];
    
    // set up views
    [self setupSourceTableWithFrame:CGRectMake(calendar.frame.size.width, 0, width / 2 + 300, height)];
    [self setupDestinationTableWithFrame:CGRectMake(0, 0, calendar.frame.size.width, height)];
    
    //set navigate title 
    srcTableNavItem.title=NSLocalizedString(@"Contact_PLURAL", nil);
    dstTableNavItem.title=NSLocalizedString(@"Appointment_PLURAL", nil);
    
    self.selectedDate = [EvaluateTools getTodayGMT];

    //separator between source and destination view
    UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(calendar.frame.size.width, 0, 1.5, height)];
    separator.backgroundColor = [UIColor blackColor];
    [self.view addSubview:separator];
    [separator release];
    
    // set up gestures
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanning:)];
    [panGesture setMaximumNumberOfTouches:1];
    [self.view addGestureRecognizer:panGesture];
    
    [panGesture release];
    [self filterAppointmentData];
    
}

- (void)dealloc
{

    [srcTableNavItem release];
    [dstTableNavItem release];
    
    [srcTableNavBar release];
    [dstTableNavBar release];
    
    [srcTableView release];
    [dstTableView release];
    [dropArea release];
    
    [contactData release];
    [dstData release];
    
    if(draggedCell != nil)
        [draggedCell release];
    if(draggedData != nil)
        [draggedData release];
    if(pathFromDstTable != nil)
        [pathFromDstTable release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated{
    
    [self chooseView];

}

- (void)orientationChanged:(NSNotification *)notification
{
    [self chooseView];
    
}

- (void)chooseView{
    
    CGRect rect=[[UIScreen mainScreen]bounds];
    int width = rect.size.width;
    int height = rect.size.height;
    
    UIInterfaceOrientation deviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (deviceOrientation == UIInterfaceOrientationPortrait || deviceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        
        [UIView animateWithDuration:0.2 animations:^
         {
             CGRect frame = dstTableView.frame;
             frame.size.height =height - calendar.frame.size.height- 140;
             dstTableView.frame = frame;
             
             CGRect srcFrame=srcTableView.frame;
             srcFrame.size.width = width - calendar.frame.size.width;
             srcFrame.size.height = height - 150;
             srcTableView.frame=srcFrame;
             srcTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth ;
             
             CGRect srcNavFrame=srcTableNavBar.frame;
             srcNavFrame.size.width = width - calendar.frame.size.width;
             srcTableNavBar.frame = srcNavFrame;
             
             CGRect searchbarrect=[uIsearchBar frame];
             searchbarrect.size.width = width - (calendar.frame.size.width+120);
             uIsearchBar.frame=searchbarrect;
             
         }];
        
        
    } else if (deviceOrientation == UIInterfaceOrientationLandscapeLeft || deviceOrientation == UIInterfaceOrientationLandscapeRight ){
        
        [UIView animateWithDuration:0.2 animations:^
         {
             CGRect frame = dstTableView.frame;
             frame.size.height =height - calendar.frame.size.height - 400;
             dstTableView.frame = frame;
             
             CGRect srcFrame=srcTableView.frame;
             srcFrame.size.width = 710 ;
             srcFrame.size.height = height - 400;
             srcTableView.frame=srcFrame;
             
             CGRect srcNavFrame=srcTableNavBar.frame;
             srcNavFrame.size.width = 710 ; 
             srcTableNavBar.frame = srcNavFrame;
             
             CGRect searchbarrect=[uIsearchBar frame];
             searchbarrect.size.width =600;
             uIsearchBar.frame=searchbarrect;
             
         }];
        
    }
    [self getContactData];
    [srcTableView reloadData];
    [dstTableView reloadData];
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}


#pragma mark -
#pragma mark Helper methods for initialize view
- (void)setupSourceTableWithFrame:(CGRect)frame
{
    srcTableNavItem = [[UINavigationItem alloc] init];
    srcTableNavItem.title = @"Contact section";
    
    CGRect navBarFrame = frame;
    navBarFrame.size.height = navBarHeight;
    
    UIButton *info=[UIButton buttonWithType:UIButtonTypeInfoLight];
    [info addTarget:self action:@selector(showinfo) forControlEvents:UIControlEventTouchUpInside];
    
    self.barinfo=[[UIBarButtonItem alloc]initWithCustomView:info];
    self.navigationItem.rightBarButtonItem=barinfo;
    
    srcTableNavBar = [[UINavigationBar alloc] initWithFrame:navBarFrame];
    [srcTableNavBar pushNavigationItem:srcTableNavItem animated:false];
    [srcTableNavBar setTintColor:[UITools readHexColorCode:[Configuration getProperty:@"headerColor"]]];
    [self.view addSubview:srcTableNavBar];
    
   NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:@"Contact"];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(frame.origin.x, navBarHeight, frame.size.width, 44)];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    NSMutableArray *toolbarItems = [[NSMutableArray alloc] initWithCapacity:1];
    
    if ([[sinfo getFilters:NO] count] != 0) { 
        self.filter = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(filterClick:)];
        [filter setWidth:80];
        [toolbarItems addObject:filter];

    }
    
    uIsearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width-80, 44)];
    uIsearchBar.delegate = self;
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithCustomView:uIsearchBar];
    [toolbarItems addObject:searchItem];
    [toolbar setItems:toolbarItems];
    [self.view addSubview:toolbar]; 
    
    
    CGRect tableFrame = frame;
    tableFrame.origin.y = navBarHeight+44;
    tableFrame.size.height -= navBarHeight+44;
    
    srcTableView = [[UITableView alloc] initWithFrame:tableFrame];
    [srcTableView setDelegate:self];
    [srcTableView setDataSource:self];
    [srcTableView setRowHeight:60];
    [self.view addSubview:srcTableView];
    
}

- (void)setupDestinationTableWithFrame:(CGRect)frame
{
    dstTableNavItem = [[UINavigationItem alloc] init];
    dstTableNavItem.title = @"Appointment Section";
    
    CGRect navBarFrame = frame;
    navBarFrame.size.height = navBarHeight;
    
    dstTableNavBar = [[UINavigationBar alloc] initWithFrame:navBarFrame];
    [dstTableNavBar pushNavigationItem:dstTableNavItem animated:false];
    [dstTableNavBar setTintColor:[UITools readHexColorCode:[Configuration getProperty:@"headerColor"]]];
    [self.view addSubview:dstTableNavBar];
    
    CGRect dropAreaFrame = frame;
    dropAreaFrame.origin.y = navBarHeight;
    dropAreaFrame.size.height -= navBarHeight;
    
    dropArea = [[UIView alloc] initWithFrame:dropAreaFrame];
    [dropArea setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:dropArea];
    
    CGRect contentFrame = dropAreaFrame;
    contentFrame.origin = CGPointMake(0, 0);
    
    CGRect tableFrame = contentFrame;
    
    //Add calendar to view
    UIView *CalendarView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, tableFrame.size.width, calendar.frame.size.height)];
    [CalendarView addSubview: calendar];
    calendar.center=CalendarView.center;
    [calendar selectDate:[EvaluateTools getTodayGMT]];
    [CalendarView setBackgroundColor:[UIColor whiteColor]];
    [dropArea addSubview:CalendarView];
    
    //setup appointment list
    tableFrame.origin.y=calendar.frame.size.height;
    dstTableView = [[UITableView alloc] initWithFrame:tableFrame];
    [dstTableView setEditing:NO];
    dstTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [dstTableView setDelegate:self];
    [dstTableView setDataSource:self];
    [dropArea addSubview:dstTableView];
    
}

- (void)initDraggedCellWithCell:(UITableViewCell*)cell AtPoint:(CGPoint)point
{
    // get rid of old cell, if it wasn't removed already
    if(draggedCell != nil)
    {
        [draggedCell removeFromSuperview];
        [draggedCell release];
        draggedCell = nil;
    }
    
    CGRect frame = CGRectMake(point.x-(cell.frame.size.width/2),point.y-15,cell.frame.size.width, cell.frame.size.height);
    draggedCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"DragCell"];
    draggedCell.selectionStyle = UITableViewCellSelectionStyleBlue;
    draggedCell.textLabel.text =cell.textLabel.text;
    draggedCell.textLabel.textColor = cell.textLabel.textColor;
    draggedCell.detailTextLabel.text =cell.detailTextLabel.text;
    draggedCell.imageView.image = cell.imageView.image;
    draggedCell.highlighted = YES;
    draggedCell.frame = frame;
    draggedCell.alpha = 0.8;
    draggedCell.layer.cornerRadius=5.0;
    draggedCell.layer.masksToBounds = YES;
    [self.view addSubview:draggedCell];
    
}

#pragma mark -
#pragma mark UIGestureRecognizer

- (void)handlePanning:(UIPanGestureRecognizer *)gestureRecognizer
{
    switch ([gestureRecognizer state]) {
            
        case UIGestureRecognizerStateBegan:
            [self startDragging:gestureRecognizer];
            break;
        case UIGestureRecognizerStateChanged:
            [self doDrag:gestureRecognizer];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self stopDragging:gestureRecognizer];
            break;
        default:
            break;
            
    }
}

#pragma mark -
#pragma mark Helper methods for dragging

- (void)startDragging:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint pointInSrc = [gestureRecognizer locationInView:srcTableView];
    CGPoint screenpoint= [gestureRecognizer locationInView:self.view];
    
    if([srcTableView pointInside:pointInSrc withEvent:UITouchPhaseBegan])
    {
        [self startDraggingFromSrcAtPoint:pointInSrc pointscreen:screenpoint];
        dragFromSource = YES;
        
    }
}

//Start Dragging Item from Contact's list
- (void)startDraggingFromSrcAtPoint:(CGPoint)point pointscreen:(CGPoint)screenPoint
{
    //get indexpath of source table from touch point
    NSIndexPath* indexPath = [srcTableView indexPathForRowAtPoint:point];
    UITableViewCell* cell = [srcTableView cellForRowAtIndexPath:indexPath];

    
    if(cell != nil)
    {
        
        [self initDraggedCellWithCell:cell AtPoint:screenPoint];
        
        cell.highlighted = NO;
        
        if(draggedData != nil)
        {
            [draggedData release];
            draggedData = nil;
        }
        draggedData = [[contactData objectAtIndex:indexPath.row] retain];
        
    }
    
}

- (void)doDrag:(UIPanGestureRecognizer *)gestureRecognizer
{
    if(draggedCell != nil && draggedData != nil)
    {
        CGPoint translation = [gestureRecognizer translationInView:[draggedCell superview]];
        [draggedCell setCenter:CGPointMake([draggedCell center].x + translation.x,
                                           [draggedCell center].y + translation.y)];
        [gestureRecognizer setTranslation:CGPointZero inView:[draggedCell superview]];
    }
    
}

// Stop dragging Contact
- (void)stopDragging:(UIPanGestureRecognizer *)gestureRecognizer
{
    if(draggedCell != nil && draggedData != nil)
    {
        if([gestureRecognizer state] == UIGestureRecognizerStateEnded && [calendar pointInside:[gestureRecognizer locationInView:calendar] withEvent:nil])
        {            
            CGPoint screenpoint= [gestureRecognizer locationInView:calendar];
            [calendar dateAtpoint:screenpoint];
            // TODO
                      
        }
        dragFromSource=NO;
        [draggedCell removeFromSuperview];
        [draggedCell release];
        draggedCell = nil;
        [draggedData release];
        draggedData = nil;
        
    }
}

#pragma mark -
#pragma mark UITableViewDataSource

- (BOOL)tableView:(UITableView*)tableView canMoveRowAtIndexPath:(NSIndexPath*)indexPath
{
    // disable build in reodering functionality
    return YES;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    // tell our tables how many rows they will have
    int count = 0;
    if([tableView isEqual:srcTableView])
    {
        count = [contactData count];
    }
    else if([tableView isEqual:dstTableView])
    {
        count = [dstData count];
    }
    return count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* result = nil;
    if([tableView isEqual:srcTableView])
    {
        result = [self srcTableCellForRowAtIndexPath:indexPath];
    }
    else if([tableView isEqual:dstTableView])
    {
        result = [self dstTableCellForRowAtIndexPath:indexPath];
    }
    
    return result;
}

#pragma mark -
#pragma mark Helper methods for table stuff

- (UITableViewCell*)srcTableCellForRowAtIndexPath:(NSIndexPath*)indexPath
{

	UITableViewCell *cell = [srcTableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    Item *item = [contactData objectAtIndex:indexPath.row];
    // Configure the cell...
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:@"Contact"];
	cell.textLabel.text = [sinfo getDisplayText:item];
    cell.detailTextLabel.text = [sinfo getDetailText:item];
    NSString *icon = [sinfo getIcon:item];
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    if (icon != Nil) {
        cell.imageView.image = [UIImage imageNamed:icon];
    } else {
        cell.imageView.image = Nil;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
   
    if (tableView == dstTableView) {
        Item *item = [dstData objectAtIndex:indexPath.row];
        [PadTabTools navigateTab:item];
    }
    
}

- (UITableViewCell*)dstTableCellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    // tell our destination table what kind of cell to use and its title for the given row
    UITableViewCell *cell = [dstTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:cellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [UIColor darkGrayColor];
    }

    // Configure the cell...
    Item *item = [dstData objectAtIndex:indexPath.row];
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:@"Appointment"];
	cell.textLabel.text = [sinfo getDisplayText:item];
    cell.detailTextLabel.text = [sinfo getDetailText:item];
    NSString *icon = [sinfo getIcon:item];
    
    cell.accessoryType=UITableViewCellAccessoryDetailDisclosureButton;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    if (icon != Nil) {
        cell.imageView.image = [UIImage imageNamed:icon];
    } else {
        cell.imageView.image = Nil;
    }
    
    return cell;
    
}



#pragma mark -
#pragma mark TKCalendarMonthViewDelegate methods

- (void)calendarMonthView:(TKCalendarMonthView *)monthView didSelectDate:(NSDate *)d {
    [self filterAppointmentData];
    self.selectedDate = d;
    
    if (dragFromSource) {
        
        Item *contact = (Item *)draggedData;
        Item *newObject = [[Item alloc] init:@"Activity" fields:[[NSDictionary alloc]init]]; 
        [newObject.fields setObject:[contact.fields objectForKey:@"Id"] forKey:@"PrimaryContactId"];
    
        

        NSObject <Subtype> *contactsinfo = [Configuration getSubtypeInfo:@"Contact"];

        [newObject.fields setObject:[NSString stringWithFormat:@"Appointment with %@",[contactsinfo getDisplayText:contact]] forKey:@"Subject"];
        
        
        NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:@"Appointment"];    
        [sinfo fillItem:newObject];
        [EvaluateTools initAppointment:newObject date:d];
        
        EditViewController *addViewController = [[EditViewController alloc] initWithDetail:newObject updateListener:self isCreate:YES action:nil];   
        [[self navigationController] pushViewController:addViewController animated:YES];
        [newObject release];

    }
    
    
}

#pragma mark -
#pragma mark TKCalendarMonthViewDataSource methods

- (NSArray*)calendarMonthView:(TKCalendarMonthView *)monthView marksFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate {	
    return [CalendarUtils doMarks:monthView marksFromDate:startDate toDate:lastDate subtype:@"Appointment"];
    
}


// Contact Data
- (void)getContactData {
    
    NSString *filterCode = [FilterManager getFilter:@"Contact"];
    if ([filterCode length] == 0) {
        filter.title = NSLocalizedString(@"NO_FILTER", @"No Filter");
    } else {
        filter.title = [EvaluateTools translateWithPrefix:filterCode prefix:@"FILTER_"];
    }
    NSMutableArray *criterias = [NSMutableArray arrayWithArray:[FilterManager getCriterias:@"Contact"]];
    if ([nameFilter length] > 0) {
        if ([nameFilter length] > 0) {
            
            OrCriteria *orCriteria = [[OrCriteria alloc] initWithCriteria1: [[LikeCriteria alloc] initWithColumn:@"search" value:nameFilter] 
                                                                 criteria2: [[LikeCriteria alloc] initWithColumn:@"search2" value:nameFilter]];
            [criterias addObject:orCriteria];
            [orCriteria release];
            
        }

    }
    
    NSArray *items = [EntityManager list:@"Contact" entity:@"Contact" criterias:criterias];
    //[filters release];
    contactData = [[NSMutableArray alloc] initWithArray:items];
    [items release];
    
}

//filter Appointment Data
- (void)filterAppointmentData {
    

    BetweenCriteria *criteria = [CalendarUtils buildDateCriteria:[calendar dateSelected]];


    NSArray *appointments = [EntityManager list:@"Appointment" entity:@"Activity" criterias:[NSArray arrayWithObject:criteria]];
    NSArray *reversedAppointments = [[appointments reverseObjectEnumerator] allObjects];
    dstData = [[NSMutableArray alloc] initWithCapacity:1];
    for (Item *item in reversedAppointments) {
        [dstData addObject:item];
    } 
    [appointments release];
    [dstTableView reloadData];
    
}

- (void)mustUpdate{
    [self getContactData];
    [self filterAppointmentData];
    [srcTableView reloadData];
    [calendar reload];
    [calendar selectDate:self.selectedDate];
    
}

- (void)filterClick:(id)sender {
    
    FilterListPopup *popup = [[FilterListPopup alloc] initPopup:@"Contact" listener:self];
    [popup showList:sender];   
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.nameFilter = searchText;
    [self getContactData];
    [srcTableView reloadData];
}

- (void)didCreate:(NSString *)entity key:(NSString *)key {
    // do nothing
}

- (void)showinfo{
    
    if ([asheet isVisible]) {
        [asheet dismissWithClickedButtonIndex:0 animated:NO];
        return;
    }
    NSString *message=NSLocalizedString(@"CALENDAR_INFO", nil);
    
    asheet=[[UIActionSheet alloc]initWithTitle:message delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"button", nil];
    asheet.actionSheetStyle=UIActionSheetStyleBlackTranslucent ;
    [asheet showFromBarButtonItem:barinfo animated:YES];
 
    UILabel *label=[[UILabel alloc]init];
    label.frame=asheet.frame;
    label.font=[UIFont systemFontOfSize:18];
    label.textAlignment=UITextAlignmentCenter;
    label.text=message;
    label.numberOfLines=5;
    [asheet addSubview:label];
    [label release];

}



@end
