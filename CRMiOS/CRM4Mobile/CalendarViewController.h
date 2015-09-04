//
//  CalendarViewController.h
//  CRMiOS
//
//  Created by Hun Sokunpheaktra on 8/31/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKCalendarMonthView.h"
#import "DailyAgendaViewController.h"
#import "SelectionListener.h"
#import "CalendarUtils.h"


@interface CalendarViewController : UIViewController <TKCalendarMonthViewDataSource,TKCalendarMonthViewDelegate> {
    
    TKCalendarMonthView *calendar;
    UIPopoverController *popup;
    NSObject <SelectionListener> *selectListener;
    
}

- (id)initWithListener:(NSObject<SelectionListener> *)listener;

@property (nonatomic,retain) NSObject <SelectionListener> *selectListener;
@property (nonatomic,retain) TKCalendarMonthView *calendar;
@property (nonatomic,retain) UIPopoverController *popup;

- (void) showCalendarPopup:(UITextField *)textField parentView:(UIViewController*)parentView selectDate:(NSDate*)date;

@end
