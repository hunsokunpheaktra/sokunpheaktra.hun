//
//  DatetimeHelper.h
//
//  Created by Sy Pauv
//
//  This class is a helper class

//  NSString *inputDateString = @"2011-09-1T13:00:00.000Z";
//  NSString* test = [DatetimeHelper display:inputDateString withTimeZone:@"US/Pacific" ];

//  NSString *inputDateString2 = @"2011-09-1";
//  NSString* test2 = [DatetimeHelper display:inputDateString2 withTimeZone:@"US/Pacific" ];

//

#import <Foundation/Foundation.h>


#define SALESFORCE_DATETIME_FORMAT @"yyyy-MM-dd'T'HH:mm:ss.'000Z'"	
#define SALESFORCE_DATE_FORMAT @"yyyy-MM-dd"
#define DISPLAY_DATE_FORMAT @"MM/dd/yyyy"			
#define DISPLAY_DATETIME_FORMAT @"MM/dd/yyyy HH:mm:ss"		

@interface DatetimeHelper : NSObject {
    
}

+(NSString*) display:(NSString*)value;
+(NSString*) display:(NSString*)value withTimeZone:(NSString*)usertimezone;
+(NSString*) serverDateTime:(NSDate*) value;
+(NSString*) serverDate:(NSDate*) value;
+(NSDate*) stringToDateTime:(NSString *)value;
+(NSDate*) stringToDate:(NSString *)value;

@end
