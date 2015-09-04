//
//  DatetimeHelper.m
//  Reader
//
//  Created by Sy Pauv
//

#import "DatetimeHelper.h"
#import "PropertyManager.h"

@implementation DatetimeHelper

static NSString *USER_TIMEZONE = Nil;

+(NSString*) display:(NSString*)value{
    if(!USER_TIMEZONE){
        USER_TIMEZONE = [PropertyManager read:@"TimeZoneSidKey"];
    }
    NSString *disval = [self display:value withTimeZone:USER_TIMEZONE];
    return disval == nil? @"" : disval;
}


+(NSString*)display:(NSString*)value withTimeZone:(NSString*)usertimezone {
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    
    // test
     
    // timezone from Salesforce  = 0
     NSTimeZone* salesforcetz = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:salesforcetz];
    
    // check if it is date or date time
    NSRange range = [value rangeOfString:@":"];    
    
    // @"2011-09-1T01:10:10.000Z";
   if (range.length>0) {
       [dateFormatter setDateFormat:SALESFORCE_DATETIME_FORMAT];
       
   }
   else {
       
       [dateFormatter setDateFormat:SALESFORCE_DATE_FORMAT];
   }
    // parse the date
    NSDate *date = [dateFormatter dateFromString:value];

    
   // destination format
    // switch back to user timezone
    
    if (range.length>0) {
        // user timezone
        NSTimeZone* usertz = [NSTimeZone timeZoneWithName:usertimezone];
        [dateFormatter setTimeZone:usertz];
        [dateFormatter setDateFormat:DISPLAY_DATETIME_FORMAT];

    }
    else {
        
        [dateFormatter setDateFormat:DISPLAY_DATE_FORMAT];
    }
          
    
    return [dateFormatter stringFromDate:date];

}

+(NSString*)serverDateTime:(NSDate*)value{
  //  NSLog(@" serverDateTime from value : %@" , value);
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    NSTimeZone* salesforcetz = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:salesforcetz];
    [dateFormatter setDateFormat:SALESFORCE_DATETIME_FORMAT];
    
    return [dateFormatter stringFromDate:value];
}

+(NSString*) serverDate:(NSDate*) value{
    NSLog(@" serverDateTime from value : %@" , value);
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    NSTimeZone* salesforcetz = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:salesforcetz];
    [dateFormatter setDateFormat:SALESFORCE_DATE_FORMAT];
    return [dateFormatter stringFromDate:value];
}

+(NSDate*) stringToDateTime:(NSString *)value {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    NSTimeZone* salesforcetz = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:salesforcetz];
    [dateFormatter setDateFormat:SALESFORCE_DATETIME_FORMAT];
    return [dateFormatter dateFromString:value];
}

+(NSDate*) stringToDate:(NSString *)value{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    NSTimeZone* salesforcetz = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:salesforcetz];
    [dateFormatter setDateFormat:SALESFORCE_DATE_FORMAT];

    return [dateFormatter dateFromString:value];
}

@end
