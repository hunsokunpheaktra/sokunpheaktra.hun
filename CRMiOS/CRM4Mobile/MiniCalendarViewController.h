//
//  MiniCalendarViewController.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 11/3/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PadListViewController.h"
#import "TKCalendarMonthView.h"
#import "CalendarUtils.h"

@class PadListViewController;

@interface MiniCalendarViewController : UIViewController<TKCalendarMonthViewDataSource, TKCalendarMonthViewDelegate> {
    PadListViewController *listVC;
    TKCalendarMonthView *calendar;
    NSDate *selectedDate;
}
@property (nonatomic, retain)  NSDate *selectedDate;
@property (nonatomic, retain) TKCalendarMonthView *calendar; 
@property (nonatomic, retain) PadListViewController *listVC;

- (id)initWithList:(PadListViewController *)newListVC;
- (NSDate *)getSelectedDate;
- (void)refresh;

@end
