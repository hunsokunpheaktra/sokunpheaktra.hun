//
//  MiniCalendarViewController.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 11/3/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "MiniCalendarViewController.h"


@implementation MiniCalendarViewController

@synthesize listVC;
@synthesize calendar;
@synthesize selectedDate;

- (id)initWithList:(PadListViewController *)newListVC {
    self = [super init];
    self.listVC = newListVC;
    return self;
}



- (void)loadView {
    UIView *mainView = [[UIView alloc] init];
    
    //view calendar
    self.calendar = [[TKCalendarMonthView alloc] init];
    self.calendar.delegate = self;
    self.calendar.dataSource = self;
    calendar.frame = CGRectMake(0, 0, calendar.frame.size.width , calendar.frame.size.height);
    [calendar reload];
    self.selectedDate = [EvaluateTools getTodayGMT];
    [calendar selectDate:self.selectedDate];
    
    [mainView addSubview:calendar];

    [self setView:mainView];
    [self.listVC mustUpdate];
   
}

- (void)refresh {
    [self.calendar reload];
    [self.calendar selectDate:self.selectedDate];
}

- (void)dealloc
{
    [self.calendar release];
    [self.selectedDate release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark -
#pragma mark TKCalendarMonthViewDelegate methods

- (void)calendarMonthView:(TKCalendarMonthView *)monthView didSelectDate:(NSDate *)d {
    self.selectedDate = d;
    [listVC mustUpdate];
    
}


#pragma mark -
#pragma mark TKCalendarMonthViewDataSource methods

- (NSArray*)calendarMonthView:(TKCalendarMonthView *)monthView marksFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate {	
    return [CalendarUtils doMarks:monthView marksFromDate:startDate toDate:lastDate subtype:listVC.subtype]; 
}




- (NSDate *)getSelectedDate {
 
    return self.selectedDate;
    
}


@end
