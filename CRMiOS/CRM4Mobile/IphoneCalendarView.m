//
//  IphoneCalendarView.m
//  CRMiOS
//
//  Created by Sy Pauv on 12/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "IphoneCalendarView.h"


@implementation IphoneCalendarView

@synthesize calendar,dateselected;

- (void)dealloc {
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"CALENDAR", @"title");
    //view calendar
    self.calendar = [[TKCalendarMonthView alloc] init];
    self.calendar.delegate = self;
    self.calendar.dataSource = self;
    calendar.frame = [[UIScreen mainScreen]bounds];
    [calendar reload];
    self.dateselected = [EvaluateTools getTodayGMT];
    [calendar selectDate:self.dateselected];
    self.view = calendar;
    self.view.backgroundColor = [UIColor whiteColor];
    //add button
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
    self.navigationItem.rightBarButtonItem = add;
    [add release];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}
#pragma mark -
#pragma mark TKCalendarMonthViewDelegate methods

- (void)calendarMonthView:(TKCalendarMonthView *)monthView didSelectDate:(NSDate *)d {
    
    self.dateselected=d;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];  
    [NSThread sleepForTimeInterval:0.1];  
    [self performSelectorOnMainThread:@selector(showDetail) withObject:nil waitUntilDone:NO];  
    [pool release];  

}

#pragma mark -
#pragma mark TKCalendarMonthViewDataSource methods

- (NSArray*)calendarMonthView:(TKCalendarMonthView *)monthView marksFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate {	
    return [CalendarUtils doMarks:monthView marksFromDate:startDate toDate:lastDate subtype:@"Appointment"];
}

- (void)add {

    Item *newItem = [[Item alloc] init:@"Activity" fields:[[NSMutableDictionary alloc] initWithCapacity:1]];
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:@"Appointment"];
    [sinfo fillItem:newItem];

    
    
    [EvaluateTools initAppointment:newItem date:self.dateselected];

    EditingViewController *addViewController = [[EditingViewController alloc] initWithItem:newItem updateListener:self isCreate:YES];
    [self.navigationController pushViewController:addViewController animated:YES];
    [addViewController release];
    [newItem release];

}
- (void)mustUpdate{
    
    [self.calendar reload];
    [self.calendar selectDate:self.dateselected];

}

-(void)showDetail{

    BetweenCriteria *criteria = [CalendarUtils buildDateCriteria:self.dateselected];
    NSArray *appointments = [EntityManager list:@"Appointment" entity:@"Activity" criterias:[NSArray arrayWithObject:criteria]];
    
    if ([appointments count]==1) {
        
        if ([self.navigationController.visibleViewController isKindOfClass:[IphoneCalendarView class]]) {
            DetailViewController *detailController = [[DetailViewController alloc] initWithItem:[appointments objectAtIndex:0] listener:self];
            [self.navigationController pushViewController:detailController animated:YES];
            [detailController release];
        }
        
    }else if([appointments count] > 1){ 
        if ([self.navigationController.visibleViewController isKindOfClass:[IphoneCalendarView class]]) {
            AppointmentListView *listview=[[AppointmentListView alloc]initwithCriteria:(NSDictionary *)criteria];
            [self.navigationController pushViewController:listview animated:YES];
            [listview release];
        }
    }

}


@end
