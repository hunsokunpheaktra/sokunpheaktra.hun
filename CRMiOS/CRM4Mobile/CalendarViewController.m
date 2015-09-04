//
//  CalendarViewController.m
//  CRMiOS
//
//  Created by Hun Sokunpheaktra on 8/31/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "CalendarViewController.h"

@implementation CalendarViewController

@synthesize calendar,popup;
@synthesize selectListener;

- (id)initWithListener:(NSObject<SelectionListener> *)listener{
    self = [super init];
    self.selectListener=listener;
    return self;
    
}

-(void)viewDidLoad{
    
    self.calendar = [[TKCalendarMonthView alloc] init];
    self.calendar.delegate = self;
    self.calendar.dataSource = self;
    
	calendar.frame = CGRectMake(0, 0, calendar.frame.size.width, calendar.frame.size.height);	// Ensure this is the last "addSubview" because the calendar must be the top most view layer	
	[self.view addSubview:calendar];
	[calendar reload];
    
}

- (void) showCalendarPopup:(UITextField *)textField parentView:(UIViewController*)parentView selectDate:(NSDate*)date {
    
    if([self.popup isPopoverVisible]){
        
        [self.popup dismissPopoverAnimated:YES];
        [self release];
        return;
        
    }
    
    if (date){
        [calendar selectDate:date];
    }
    
    UINavigationController *popoverContent = [[[UINavigationController alloc] initWithRootViewController:self] autorelease];
    [self setTitle:@"Calendar"];
    self.contentSizeForViewInPopover = calendar.frame.size;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.popup = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
    
    CGRect rect = [textField.superview convertRect:textField.frame toView:parentView.view];
    
    [self.popup presentPopoverFromRect:rect inView:parentView.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

#pragma mark -
#pragma mark TKCalendarMonthViewDelegate methods

- (void)calendarMonthView:(TKCalendarMonthView *)monthView didSelectDate:(NSDate *)d {
    
    NSDateFormatter *formatter = [UITools getDateFormatter:@"Date"];
    [selectListener didSelect:@"Date" valueId:[formatter stringFromDate:d] display:nil];
    [self.popup dismissPopoverAnimated:YES];
    
}

#pragma mark -
#pragma mark TKCalendarMonthViewDataSource methods

- (NSArray*)calendarMonthView:(TKCalendarMonthView *)monthView marksFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate {	
    return [CalendarUtils doMarks:monthView marksFromDate:startDate toDate:lastDate subtype:@"Appointment"];
}

- (void)dealloc
{
    [calendar release];
    [popup release];
    [super dealloc];
}

@end
