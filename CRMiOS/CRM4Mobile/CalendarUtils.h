//
//  CalendarUtils.h
//  CRMiOS
//
//  Created by Arnaud Marguerat on 8/16/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TKCalendarMonthView.h"
#import "BetweenCriteria.h"

@interface CalendarUtils : NSObject

+ (NSArray*)doMarks:(TKCalendarMonthView *)monthView marksFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate subtype:(NSString *)subtype;
+ (BetweenCriteria *)buildDateCriteria:(NSDate *)date;


@end
