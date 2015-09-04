//
//  CalendarUtils.m
//  CRMiOS
//
//  Created by Arnaud Marguerat on 8/16/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "CalendarUtils.h"

@implementation CalendarUtils


+ (BetweenCriteria *)buildDateCriteria:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc]init]autorelease];
    NSTimeZone *tz = [CurrentUserManager getUserTimeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    NSDate *start = [[NSDate alloc] initWithTimeInterval:-[tz secondsFromGMTForDate:date] - [[NSTimeZone systemTimeZone] secondsFromGMTForDate:date] sinceDate:date];
    
    NSDate *end = [[NSDate alloc] initWithTimeInterval:24*60*60 - 1 sinceDate:start]; // need to remove one second, else we see 0:00 from the next day
    BetweenCriteria *dateCriteria = [[BetweenCriteria alloc] initWithColumn:@"StartTime" start:[dateFormatter stringFromDate:start] end:[dateFormatter stringFromDate:end]];
    return dateCriteria;
}

+ (NSArray*)doMarks:(TKCalendarMonthView *)monthView marksFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate subtype:(NSString *)subtype {	
    
    NSMutableArray *data = [[NSMutableArray alloc]initWithCapacity:1];
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc]init]autorelease];
    //[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDateFormatter *dateTimeFormatter = [[[NSDateFormatter alloc]init]autorelease];
    [dateTimeFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    
    NSDate *lastDatePlusOneDay = [NSDate dateWithTimeInterval:24*60*60 sinceDate:lastDate];
    
    BetweenCriteria *criteria = [[BetweenCriteria alloc] initWithColumn:@"StartTime" start:[dateTimeFormatter stringFromDate:startDate] end:[dateTimeFormatter stringFromDate:lastDatePlusOneDay]];
    NSArray *appointments = [EntityManager list:subtype entity:@"Activity" criterias:[NSArray arrayWithObject:criteria]];
    NSArray *reversedAppointments = [[appointments reverseObjectEnumerator] allObjects];
    NSTimeZone *tz = [CurrentUserManager getUserTimeZone];
    for (Item *item in reversedAppointments) {
        
        if ([item.fields objectForKey:@"StartTime"]!=nil) {
            
            NSDate *appDate = [dateTimeFormatter dateFromString:[item.fields objectForKey:@"StartTime"]];
            NSDate *appDate2 = [[NSDate alloc] initWithTimeInterval:[tz secondsFromGMTForDate:appDate] sinceDate:appDate];
            NSString *sAppDate = [dateFormatter stringFromDate:appDate2];
            if (![data containsObject:sAppDate]) {
                [data addObject:sAppDate];
            }
        }
        
    }
    [appointments release];
    
	NSMutableArray *marks = [NSMutableArray array];
	
	NSCalendar *cal = [NSCalendar currentCalendar];
	
	NSDateComponents *comp = [cal components:(NSMonthCalendarUnit | NSMinuteCalendarUnit | NSYearCalendarUnit | 
											  NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSSecondCalendarUnit) 
									fromDate:startDate];
	NSDate *d = [cal dateFromComponents:comp];
    
    // add twelve hours to the date, to avoid issues with summer/winter time
    NSDateComponents *twelveHours = [[NSDateComponents alloc] init];
	[twelveHours setHour:12];
    d = [cal dateByAddingComponents:twelveHours toDate:d options:0];
    
	NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
	[offsetComponents setDay:1];	
	
	while (YES) {
        
		if ([marks count] >= 42) {
			break;
		}
        
        NSString *code = [[d description] substringToIndex:10];
		
		// If the date is in the data array, add it to the marks array, else don't
		if ([data containsObject:code]) {
			[marks addObject:[NSNumber numberWithBool:YES]];
		} else {
			[marks addObject:[NSNumber numberWithBool:NO]];
		}
		
		// Increment day using offset components (ie, 1 day in this instance)
		d = [cal dateByAddingComponents:offsetComponents toDate:d options:0];
	}
	
	[offsetComponents release];
	
	return [NSArray arrayWithArray:marks];
    
}


@end
