//
//  IphoneCalendarView.h
//  CRMiOS
//
//  Created by Sy Pauv on 12/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKCalendarMonthView.h"
#import "BetweenCriteria.h"
#import "EditingViewController.h"
#import "AppointmentListView.h"

@interface IphoneCalendarView : UIViewController<TKCalendarMonthViewDataSource, TKCalendarMonthViewDelegate, UpdateListener> {
    
    TKCalendarMonthView *calendar;
    NSDate *dateselected;
    
}
@property (nonatomic ,retain) NSDate *dateselected;
@property (nonatomic ,retain) TKCalendarMonthView *calendar;

-(void)showDetail;
- (void)add;

@end
