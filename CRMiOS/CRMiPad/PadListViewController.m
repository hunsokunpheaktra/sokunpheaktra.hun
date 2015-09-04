//
//  ImageViewController.m
//  Orientation
//
//  Created by Sy Pauv Phou on 3/24/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "PadListViewController.h"
//#import "IIViewDeckController.h"

@implementation PadListViewController

@synthesize parent;
@synthesize subtype;
@synthesize sinfo;
@synthesize groups;
@synthesize listView;
@synthesize nameFilter;
@synthesize selectedItem;
@synthesize filter;
@synthesize addButton;
@synthesize alternateVC;
@synthesize viewAlternate;
@synthesize navigationBar;
@synthesize listData;
@synthesize swapButton;
@synthesize actions;

- (id)initWithSubtype:(NSString *)newSubtype parent:(PadMainViewController *)newParent
{
    self = [super init];

    self.parent = newParent;
    self.subtype = newSubtype;
    self.sinfo = [Configuration getSubtypeInfo:self.subtype];
    if ([self.subtype isEqualToString:@"Appointment"] || [self.subtype isEqualToString:@"Call"]) {
        self.alternateVC = [[MiniCalendarViewController alloc] initWithList:self];
    } else if ([self.subtype isEqualToString:@"Task"]) {
        self.alternateVC = [[TaskSummaryViewController alloc] initWithList:self];
    }
    self.viewAlternate = self.alternateVC != nil;
    self.actions = [[NSMutableArray alloc] initWithCapacity:1];
    if ([Configuration isYes:@"canExportPDF"]) {
        [actions addObject:@"EXPORT_PDF"];
    }
    if ([Configuration isYes:@"canExportData"]) {
        [actions addObject:@"EXPORT_CSV"];
    }
    if ([self.subtype isEqualToString:@"Appointment"]) {
        if ([Configuration isYes:@"canExportICal"]) {
            [actions addObject:@"APPOINTMENT_EXPORT"];
            [actions addObject:@"APPOINTMENT_IMPORT"];
        }
    }
    if (self.alternateVC != nil) {
        [actions addObject:@"SWITCH_VIEW"];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView {
    
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
    mainView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self setView:mainView];

    // Navigation Bar
    self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [self.navigationBar setTintColor:[UITools readHexColorCode:[Configuration getProperty:@"headerColor"]]];
    
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:[sinfo localizedPluralName]];
    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addClick)];
    
    if ([self.actions count] > 0) {
        swapButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionClick)];
        [navItem setLeftBarButtonItem:swapButton];
    }
    
    [navItem setRightBarButtonItem:self.addButton];
    [self checkAddButton];
    
    [self.navigationBar setItems:[NSArray arrayWithObject:navItem]];
    self.navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    self.nameFilter = @"";
    
    [self buildView];
}

- (void)swapView {
    self.viewAlternate = !self.viewAlternate;
    [self buildView];
}

- (void)buildView {

    for (UIView *view in [self.view subviews]) {
        [view removeFromSuperview];
    }
    
    int offsetY = 0;
    [self.navigationBar setFrame:CGRectMake(0, 0, 320, 44)];
    [self.view addSubview:self.navigationBar];
    offsetY += self.navigationBar.frame.size.height;
    
    if (self.viewAlternate) {
        
        //smooth animation when calendar appear
        CATransition* trans = [CATransition animation];
        [trans setType:kCATransitionFade];
        [trans setDuration:0.5];
        [trans setSubtype:kCATransitionFromBottom];
        [alternateVC.view.layer addAnimation:trans forKey:@"Transition"];
        if([alternateVC isKindOfClass:[TaskSummaryViewController class]])[((TaskSummaryViewController *)alternateVC) reloadData];
        int height = [alternateVC isKindOfClass:[TaskSummaryViewController class]] ? self.view.frame.size.height - 44: 310;
        [alternateVC.view setFrame:CGRectMake(0, offsetY, self.view.frame.size.width, height)];
        alternateVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:alternateVC.view];
        offsetY += alternateVC.view.frame.size.height;
        [self filterData];
        
    } else {
        
        // Tool bar (filter + search)
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, offsetY, self.view.frame.size.width, 44)];
        toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        NSMutableArray *toolbarItems = [[NSMutableArray alloc] initWithCapacity:1];
        if ([[self.sinfo getFilters:NO] count] != 0) { 
            filter = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(filterClick:)];
            [filter setWidth:80];
            [toolbarItems addObject:filter];
        }
        
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 208, 44)];
        searchBar.text = self.nameFilter;
        searchBar.delegate = self;
        UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithCustomView:searchBar];
        [toolbarItems addObject:searchItem];
        [toolbar setItems:toolbarItems];
        [self.view addSubview:toolbar];
        offsetY += toolbar.frame.size.height;
        [self filterData];
    }
    
    if (alternateVC == nil || !self.viewAlternate || ![alternateVC isKindOfClass:[TaskSummaryViewController class]]) {
        // List view
        if (self.listView == nil) {
            self.listView = [[UITableView alloc] initWithFrame:CGRectNull style:UITableViewStylePlain];
            self.listView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.listView.delegate = self;
            self.listView.dataSource = self;
        }
        if ([[self.sinfo entity] isEqualToString:@"Contact"]) {
            [self.listView setRowHeight:80];
        } else {
            [self.listView setRowHeight:54];
        }
        [self.listView setFrame:CGRectMake(0, offsetY, self.view.frame.size.width, self.view.frame.size.height - offsetY)];
        [self.view addSubview:self.listView];
        [self.listView reloadData];
 
    }

    
}


- (void)checkAddButton {
    
    NSObject <EntityInfo> *info = [Configuration getInfo:[self.sinfo entity]]; 
    NSDictionary *fields = [FieldsManager list:[self.sinfo entity]];
    self.addButton.enabled = ([info canCreate] && [fields count] > 0);
    [fields release];
}


- (void)filterData {
    [self.groups release];
    NSString *filterCode = [FilterManager getFilter:self.subtype];
    if ([filterCode length] == 0) {
        filter.title = NSLocalizedString(@"NO_FILTER", @"No Filter");
    } else if ([filterCode isEqualToString:@"favorite"]) {
        filter.title = NSLocalizedString(filterCode, @"");
    } else {
        filter.title = [EvaluateTools translateWithPrefix:filterCode prefix:@"FILTER_"];
    }
    NSMutableArray *criterias = [NSMutableArray arrayWithArray:[FilterManager getCriterias:self.subtype]];
    if ([nameFilter length] > 0) {
        NSObject <Criteria> *searchCriteria; 
        NSObject <Criteria> *search2Criteria;
        if ([Configuration isYes:@"wildcardSearch"]) {
            searchCriteria = [[ContainsCriteria alloc] initWithColumn:@"search" value:nameFilter];
            search2Criteria = [[ContainsCriteria alloc] initWithColumn:@"search2" value:nameFilter];
        } else {
            searchCriteria = [[LikeCriteria alloc] initWithColumn:@"search" value:nameFilter];
            search2Criteria = [[LikeCriteria alloc] initWithColumn:@"search2" value:nameFilter];
        }
        if ([[Configuration getInfo:self.subtype] searchField2]!=nil) {
            OrCriteria *orCriteria = [[OrCriteria alloc] 
                    initWithCriteria1: searchCriteria
                    criteria2: search2Criteria];
            [criterias addObject:orCriteria];
            [orCriteria release];
        } else {
            [criterias addObject:searchCriteria];
        }    
    }
    if (self.viewAlternate) {
        if ([self.alternateVC isKindOfClass:[MiniCalendarViewController class]]) {
            MiniCalendarViewController *calendarVC = (MiniCalendarViewController *)self.alternateVC;
            BetweenCriteria *criteria = [CalendarUtils buildDateCriteria:[calendarVC.calendar dateSelected]];
            [criterias addObject:criteria];
            [criteria release];
        }
    }
    // additional fields : when the list contains several subtypes
    NSMutableArray *additional = [[NSMutableArray alloc] initWithCapacity:1];
    NSObject <EntityInfo> *info = [Configuration getInfo:[self.sinfo entity]];
    for (NSObject<Subtype> *oinfo in [info getSubtypes]) {
        if (![oinfo.name isEqualToString:self.sinfo.name]) {
            [additional addObjectsFromArray:[oinfo listFields]];
        }
    }
    NSArray *items = [EntityManager list:self.subtype entity:self.sinfo.entity criterias:criterias additional:additional limit:0];
    self.listData = items;
    self.groups = [GroupManager getGroups:self.subtype items:items];
    //[filters release];
    [items release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [groups release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [groups count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    Group *group = [groups objectAtIndex:section];
    return group.items.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Group *group = [groups objectAtIndex:indexPath.section];
    Item *item = [group.items objectAtIndex:indexPath.row];

	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    NSString *rowSubtype = [Configuration getSubtype:item];
    NSObject<Subtype> *rowInfo = [Configuration getSubtypeInfo:rowSubtype entity:self.sinfo.entity];

	// Configure the cell...
	cell.textLabel.text = [rowInfo getDisplayText:item];
    cell.detailTextLabel.text = [rowInfo getDetailText:item];
    NSString *icon = [rowInfo getIcon:item];

    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    // favorite icon
    while ([cell.contentView.subviews count] > 0) {
        [[cell.contentView.subviews objectAtIndex:0] removeFromSuperview];
    }
    // modified icon
    while ([cell.backgroundView.subviews count] > 0) {
        [[cell.backgroundView.subviews objectAtIndex:0] removeFromSuperview];
    }
    if ([[item.fields objectForKey:@"favorite"]isEqualToString:@"1"]) {
        UIImageView *star = [[UIImageView alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width - 32 ,[subtype isEqualToString:@"Contact"] ? 21:10, 32, 32)];
        star.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [star setImage:[UIImage imageNamed:@"btn_star_big_on.png"]];
        [cell.contentView addSubview:star];
        [star release];
    }

    // Set up the cell backgroundcolor    
    UIImageView *imageView = nil;
    if ([item.fields objectForKey:@"error"] != nil) {
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"row_error.png"]];
    } else if ([[item.fields objectForKey:@"modified"] isEqualToString:@"1"] && [item.fields objectForKey:@"Id"] !=nil ) {        
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"row_updated.png"]];
    } else if ([[item.fields objectForKey:@"modified"] isEqualToString:@"1"] && [item.fields objectForKey:@"Id"] == nil){
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"row_new.png"]];
    }
    if (imageView != nil) {
        [imageView setFrame:CGRectMake(0, 0, 16, 16)];
        UIView *bg = [[UIView alloc] initWithFrame:cell.frame];
        [bg addSubview:imageView];
        cell.backgroundView = bg;
        [imageView release];
        [bg release];
    }
    
    if (icon != nil) {
        cell.imageView.image = [UIImage imageNamed:icon];
    } else {
        cell.imageView.image = Nil;
    }
    
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    Group *group = [groups objectAtIndex:section];
    return group.name;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Group *group = [groups objectAtIndex:indexPath.section];
    self.selectedItem = [group.items objectAtIndex:indexPath.row];
    [self.parent setCurrentDetail:self.selectedItem];
    //[self.viewDeckController toggleLeftView];
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
    [self filterData];
    [self.listView reloadData];
}

- (void)selectItem:(NSString *)key {
    self.selectedItem = [EntityManager find:[self.sinfo entity] column:@"gadget_id" value:key];
    if (self.viewAlternate) {
        if ([self.alternateVC isMemberOfClass:[MiniCalendarViewController class]]) {
            MiniCalendarViewController *calendarVC = (MiniCalendarViewController *)alternateVC;
            NSDate *itemDate = [EvaluateTools dateFromString:[self.selectedItem.fields objectForKey:@"StartTime"]];
            NSTimeZone *tz = [CurrentUserManager getUserTimeZone];
            itemDate = [NSDate dateWithTimeInterval:[tz secondsFromGMTForDate:itemDate] sinceDate:itemDate];
            [calendarVC.calendar selectDate:itemDate];
            [self filterData];
            [self.listView reloadData];
        }
        if ([self.alternateVC isMemberOfClass:[TaskSummaryViewController class]]) {
            TaskSummaryViewController *taskVC = (TaskSummaryViewController *)alternateVC;
            [taskVC reloadData];
            [taskVC selectItem:key];
        }
    }
    for (Group *group in groups) {
        for (Item *item in group.items) {
            if ([[item.fields valueForKey:@"gadget_id"] isEqualToString:key]) {
                NSIndexPath *index = [NSIndexPath indexPathForRow:[group.items indexOfObject:item] inSection:[groups indexOfObject:group]];
                [self.listView selectRowAtIndexPath:index animated:YES scrollPosition:UITableViewScrollPositionMiddle];
                [self.parent.itemViewController setCurrentDetail:self.selectedItem];
            }
        }
    }
    
}

- (void)filterClick:(id)sender {
    FilterListPopup *popup = [[FilterListPopup alloc] initPopup:self.subtype listener:self];
    [popup showList:sender];   

}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if ([groups count] == 0 || [groups count] > 50 || self.viewAlternate) {
        return Nil;
    }
    NSMutableArray *index = [[NSMutableArray alloc] initWithCapacity:1];
    for (Group *group in self.groups) {
        [index addObject:group.shortName]; 
    }
    return index;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}




- (void)mustUpdate {
    [self checkAddButton];
    [self filterData];
    [self.listView reloadData];
    
    if (self.viewAlternate) {
        if([alternateVC isKindOfClass:[TaskSummaryViewController class]]) [((TaskSummaryViewController *)alternateVC) reloadData]; 
        if([alternateVC isKindOfClass:[MiniCalendarViewController class]]) [((MiniCalendarViewController *)alternateVC) refresh]; 
    }
    if (self.selectedItem == nil) {
        return;
    }
    NSString *groupId = [self.sinfo getGroupName:self.selectedItem];
    // bug fix #5117
    // the groupId may change if the user change some field that is constitutive of the groupId.
    BOOL scroll = NO;
    if ([[self.parent.itemViewController.detail.fields objectForKey:@"gadget_id"] isEqualToString:[self.selectedItem.fields objectForKey:@"gadget_id"]]) {
        NSString *newGroupId = [self.sinfo getGroupName:self.parent.itemViewController.detail];
        if (![newGroupId isEqualToString:groupId]) {

            scroll = YES;
            groupId = newGroupId;
            self.selectedItem = self.parent.itemViewController.detail;
            if (self.viewAlternate && [self.alternateVC isKindOfClass:[MiniCalendarViewController class]]) {
                NSTimeZone *tz = [CurrentUserManager getUserTimeZone];
                NSDate *date = [EvaluateTools dateFromString:[self.selectedItem.fields objectForKey:@"StartTime"]];
                date = [date dateByAddingTimeInterval:[tz secondsFromGMTForDate:date]];
                [((MiniCalendarViewController *)alternateVC) setSelectedDate:date];
                [((MiniCalendarViewController *)alternateVC) refresh];
                [self mustUpdate];
            }
        }
    }
    int section = 0;
    for (Group *group in self.groups) {
        if ([group.name isEqualToString:groupId]) {
            int row = 0;
            for (Item *detail in group.items) {
                if ([[detail.fields objectForKey:@"gadget_id"] isEqualToString:[self.selectedItem.fields objectForKey:@"gadget_id"]]) {
                    if (scroll) {
                        [self.listView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
                    } else {
                        [self.listView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:NO scrollPosition:UITableViewScrollPositionNone];
                    }
                    [self.parent.itemViewController setCurrentDetail:self.selectedItem];
                    return;
                }
                row++;
            } 
        }
        section++;
    }
    // we reach this line after deleting an item - we need to empty the current detail
    [self.parent.itemViewController setCurrentDetail:nil];

}

- (void)newItem:(NSObject <Subtype> *)iinfo {

    Item *newObject = [[Item alloc] init:[iinfo entity] fields:[[NSDictionary alloc]init]];
    [iinfo fillItem:newObject];
    
    if (self.viewAlternate && ([self.subtype isEqualToString:@"Appointment"] || [self.subtype isEqualToString:@"Call"])) {
        NSDate *date = [((MiniCalendarViewController *) self.alternateVC) getSelectedDate];
        [EvaluateTools initAppointment:newObject date:date];
    }

    EditViewController *addViewController = [[EditViewController alloc] initWithDetail:newObject updateListener:self.parent isCreate:YES action:nil];
    // remove all the existing views
    [self.parent.itemViewController.navigationController popToRootViewControllerAnimated:NO];
    [self.parent.itemViewController.navigationController pushViewController:addViewController animated:YES];
    [addViewController release];
    [newObject release];
        
}

- (void)viewWillAppear:(BOOL)animated {

    if ([self.subtype isEqualToString:@"Contact"]) {
        [self mustUpdate];
    }

}

- (void)viewPDF {

    PDFViewController *pdf = [[PDFViewController alloc] initWithData:self.listData info:sinfo];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:pdf];
    [self.parent.navigationController presentModalViewController:nav animated:YES];
    [nav release];
    [pdf release];
    
}

- (void)exportCSV {
    
    NSString* fileName = @"report.csv";
    NSArray *arrayPaths = 
    NSSearchPathForDirectoriesInDomains(
                                        NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    NSString *path = [arrayPaths objectAtIndex:0];
    NSString* fullPath = [path stringByAppendingPathComponent:fileName];
    [ExportCSV writeFile:fullPath Data:self.listData type:sinfo];
    
    // email the PDF File. 
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init] ;
    mailComposer.mailComposeDelegate = self;
    [mailComposer addAttachmentData:[NSData dataWithContentsOfFile:fullPath]
                           mimeType:@"application/csv" fileName:@"report.csv"];
    [mailComposer setSubject:@"CRM4Mobile PDF Report"];
    if (mailComposer) [self presentModalViewController:mailComposer animated:YES];
    [mailComposer release];
    
}

#pragma mark - MFMailComposerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error 
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)actionClick {
    if ([actionsheet isVisible]) {
        return;
    } else {
        if (actionsheet!=nil) {
            [actionsheet release];
        }
    }
    actionsheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    actionsheet.tag = 1;
    for (NSString *action in actions) {
        [actionsheet addButtonWithTitle:NSLocalizedString(action, nil)];
    }
    [actionsheet setDelegate:self];
    [actionsheet showFromBarButtonItem:self.swapButton animated:YES];
}

- (NSArray *)creatableSubtypes {
    NSMutableArray *creatable = [[NSMutableArray alloc] initWithCapacity:1];
    NSObject <EntityInfo> *info = [Configuration getInfo:sinfo.entity];
    NSArray *subtypes = [info getSubtypes];
    for (NSObject <Subtype> *tmp in subtypes) {
        if ((![[tmp name] isEqualToString:[tmp entity]] || [subtypes count] == 1) && tmp.canCreate) {
            [creatable addObject:tmp];
        }
    }
    return creatable;
}

- (void)addClick {
    if ([sinfo.entity isEqualToString:@"Activity"]) {
        [self newItem:sinfo];
    } else {
        NSArray *subtypes = [self creatableSubtypes];
        if ([subtypes count] == 1) {
            [self newItem:[subtypes objectAtIndex:0]];
        } else {
            if ([actionsheet isVisible]) {
                return;
            } else {
                if (actionsheet!=nil) {
                    [actionsheet release];
                }
            }
            actionsheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            for (NSObject <Subtype> *tmp in subtypes) {
                [actionsheet addButtonWithTitle:[tmp localizedName]];
            }
            actionsheet.tag = 2;
            [actionsheet setDelegate:self];
            [actionsheet showFromBarButtonItem:self.addButton animated:YES];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == -1) return;
   	if (actionSheet.tag == 1) {
        NSString *action = [actions objectAtIndex:buttonIndex];
        if ([action isEqualToString:@"EXPORT_PDF"]) {
            [self viewPDF];
        } else if ([action isEqualToString:@"EXPORT_CSV"]) {
            [self exportCSV];
        } else if ([action isEqualToString:@"APPOINTMENT_EXPORT"]) {
            EKEventStore *eventStore = [[EKEventStore alloc] init];
            float version = [[[UIDevice currentDevice] systemVersion] floatValue];
            if (version >= 6.0){
                [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error){
                    
                    [NSThread detachNewThreadSelector:@selector(exportAppointments) toTarget:self withObject:nil];
                    
                }];
            }else{
                    [NSThread detachNewThreadSelector:@selector(exportAppointments) toTarget:self withObject:nil];
            }
           
        } else if ([action isEqualToString:@"SWITCH_VIEW"]) {
            [self swapView];
        } else if ([action isEqualToString:@"APPOINTMENT_IMPORT"]) {
            EKEventStore *eventStore = [[EKEventStore alloc] init];
            float version = [[[UIDevice currentDevice] systemVersion] floatValue];
            if (version >= 6.0){
                [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error){
                //[CalendarEventTool importAppointments];
                [NSThread detachNewThreadSelector:@selector(importAppointments) toTarget:[CalendarEventTool class] withObject:nil];
                }];
            }else{
                [NSThread detachNewThreadSelector:@selector(importAppointments) toTarget:[CalendarEventTool class] withObject:nil];
            }
            
            [self mustUpdate];
        }
    } else {
        NSObject <EntityInfo> *info = [Configuration getInfo:sinfo.entity];
        NSArray *subtypes = [info getSubtypes];
        NSMutableArray *tmpList = [[NSMutableArray alloc] initWithCapacity:1];
        for (NSObject <Subtype> *tmp in subtypes) {
            if (![[tmp name] isEqualToString:[tmp entity]]) {
                [tmpList addObject:tmp];
            }
        }
        if (buttonIndex < [tmpList count]) {
            NSObject <Subtype> *tmp = [tmpList objectAtIndex:buttonIndex];
            [self newItem:tmp];
        }
        [tmpList release];
    }
    
}


                     
                     
 - (void)exportAppointments {
    
     NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
     NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
     [dateFormater setDateFormat:@"yyyy-MM-dd"];
     NSDate *today = [NSDate date];
     
     NSCalendar *gregorian = [NSCalendar currentCalendar];
     NSDateComponents *offsetComponents = [[[NSDateComponents alloc] init] autorelease];
     NSDate *startDate = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
     [offsetComponents setDay:90];
     NSDate *endate = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
     BetweenCriteria *between = [[[BetweenCriteria alloc] initWithColumn:@"StartTime" start:[dateFormater stringFromDate:startDate] end:[dateFormater stringFromDate:endate]] autorelease];
     [dateFormater release];
     
     NSMutableArray *criterias = [NSMutableArray arrayWithArray:[FilterManager getCriterias:@"Appointment"]];
     [criterias addObject:between];
     
     NSArray *list = [EntityManager list:@"Appointment" entity:@"Activity" criterias:criterias additional:[NSArray arrayWithObjects:@"Location", @"EndTime", nil] limit:0];
     [CalendarEventTool exportAppointments:list];
     [pool release];
 }
                     

@end
