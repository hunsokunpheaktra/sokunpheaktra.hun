//
//  CalendarEventTool.m
//  CRMiOS
//
//  Created by Sy Pauv on 12/20/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "CalendarEventTool.h"


@implementation CalendarEventTool 


+ (void)updateIfModified:(Item *)item fields:(NSDictionary *)fields {
    BOOL modified = NO;
    for (NSString *key in fields) {
        if (![[item.fields objectForKey:key] isEqualToString:[fields objectForKey:key]]) {
            [item.fields setObject:[fields objectForKey:key] forKey:key];
            modified = YES;
        }
    }
    if (modified) {
        [item.fields setValue:[NSNull null] forKey:@"deleted"];
        [EntityManager update:item modifiedLocally:YES];
    }
}

+ (void)importAppointments {
    NSDateFormatter * timeParser = [[[NSDateFormatter alloc] init] autorelease];
    [timeParser setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [timeParser setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    if ([EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent] != EKAuthorizationStatusAuthorized) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"CALENDAR",@"Calendar") message:NSLocalizedString(@"CALENDAR_PERMISSION_ENABLE_MESSAGE",@"User has not granted permission!.Please Goto Settings > Privacy > Calendars > Parcel > ENABLE ") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"Ok") otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }

    EKEventStore *eventStore = [[[EKEventStore alloc] init] autorelease];
    NSDate *start = [[[NSDate alloc] init] autorelease];
    NSDate *end = [NSDate dateWithTimeInterval:365*24*60*60 sinceDate:start];
     NSPredicate *predicate=[eventStore predicateForEventsWithStartDate:start endDate:end calendars:[NSArray arrayWithObject:[eventStore defaultCalendarForNewEvents]]];
    NSArray *events = [eventStore eventsMatchingPredicate:predicate];
    for (EKEvent *event in events) {
        // try to search with oracle ID
        NSMutableArray *criterias = [[NSMutableArray alloc] initWithCapacity:1];
        [criterias addObject:[ValuesCriteria criteriaWithColumn:@"Id" value:event.notes]];
        NSArray *apps = [EntityManager list:@"Appointment" entity:@"Activity" criterias:criterias additional:[NSArray arrayWithObjects:@"EndTime", @"Location", @"ExternalSystemId", nil] limit:0];
        if ([apps count] == 0) {
           [criterias addObject:[ValuesCriteria criteriaWithColumn:@"deleted" value:@"1"]];
           apps = [EntityManager list:@"Appointment" entity:@"Activity" criterias:criterias additional:[NSArray arrayWithObjects:@"EndTime", @"Location", @"ExternalSystemId", nil] limit:0];
        }
        NSString *startTime = [timeParser stringFromDate:event.startDate];
        NSString *endTime = [timeParser stringFromDate:event.endDate];
        NSString *extId = [NSString stringWithFormat:@"%i", [event.eventIdentifier hash]];
        NSMutableDictionary *work = [[NSMutableDictionary alloc] initWithCapacity:4];
        [work setValue:event.title forKey:@"Subject"];
        [work setValue:startTime forKey:@"StartTime"];
        [work setValue:endTime forKey:@"EndTime"];
        [work setValue:event.location forKey:@"Location"];
        [work setValue:extId forKey:@"ExternalSystemId"];
        if ([apps count] == 1) {
            Item *app = [apps objectAtIndex:0];
            [self updateIfModified:app fields:work];

        } else {
            // try to search with iCal id
            NSArray *criterias = [NSArray arrayWithObject:[ValuesCriteria criteriaWithColumn:@"ExternalSystemId" value:extId]];
            NSArray *apps = [EntityManager list:@"Appointment" entity:@"Activity" criterias:criterias additional:[NSArray arrayWithObjects:@"EndTime", @"Location", @"ExternalSystemId", nil] limit:0];
            if ([apps count] == 1) {
                Item *app = [apps objectAtIndex:0];
                [self updateIfModified:app fields:work];
            } else {
                Item *app = [[Item alloc] init:@"Activity" fields:work];
                [[Configuration getSubtypeInfo:@"Appointment"] fillItem:app];
                [EntityManager insert:app modifiedLocally:YES];
            }
        }
    }
    
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"APPOINTMENTS_IMPORTED", @"appointments imported"), [events count]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"APPOINTMENT_IMPORT", nil) message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alert show];
    [alert release];
}


+ (void)exportAppointments:(NSArray *)listItem {

    EKEventStore *eventStore = [[EKEventStore alloc] init] ;
    for (Item *item in listItem) {
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (version >= 6.0){
            if ([EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent] == EKAuthorizationStatusAuthorized) {                [self saveEvent:item eventStor:eventStore];
            }else{
                UIAlertView *alert=[[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"CALENDAR",@"Calendar") message:NSLocalizedString(@"CALENDAR_PERMISSION_ENABLE_MESSAGE",@"User has not granted permission!.Please Goto Settings > Privacy > Calendars > Parcel > ENABLE ") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"Ok") otherButtonTitles: nil]autorelease];
                [alert show];
                [alert release];
            }
        }else{
            [self saveEvent:item eventStor:eventStore];
        }
    }
    
    [eventStore release];
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"APPOINTMENTS_EXPORTED", @"appointments exported"), [listItem count]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"APPOINTMENT_EXPORT", nil) message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alert show];
    [alert release];
    
}

+(void)saveEvent:(id)i eventStor:(EKEventStore *)store{
    Item *item=(Item *)i;
    NSDateFormatter * timeParser = [[[NSDateFormatter alloc] init] autorelease];
    [timeParser setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [timeParser setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];

    EKEvent *event  = [EKEvent eventWithEventStore:store];
    event.title     = [item.fields objectForKey:@"Subject"];
    event.startDate = [timeParser dateFromString:[item.fields objectForKey:@"StartTime"]];
    event.endDate   = [timeParser dateFromString:[item.fields objectForKey:@"EndTime"]];
    event.notes = [item.fields objectForKey:@"Id"];
    event.location = [item.fields objectForKey:@"Location"];
    [event setCalendar:[store defaultCalendarForNewEvents]];
    NSError *err;
    if ([self checkExistingEvent:event]) {
        [store saveEvent:event span:EKSpanThisEvent error:&err];
    }

}

+ (BOOL)checkExistingEvent:(EKEvent *)event{

    EKEventStore *store = [[[EKEventStore alloc ] init] autorelease];
    NSArray *calendars = store.calendars;
    EKCalendar *defaultCal = store.defaultCalendarForNewEvents;
    BOOL isDefaultCalModifiable = defaultCal.allowsContentModifications ;
    NSPredicate *predicate = [store predicateForEventsWithStartDate:event.startDate 
                                                    endDate:event.endDate calendars:calendars];
    NSArray *matchingEvents = [store eventsMatchingPredicate:predicate];
    if( ! isDefaultCalModifiable ) {
        // The default calendar is not modifiable
        return NO;
    } 
    if ( [ matchingEvents count ] > 0 ) {
        EKEvent *anEvent;  
        int j;
        for ( j=0; j < [ matchingEvents count]; j++) {
            anEvent = [ matchingEvents objectAtIndex:j ] ;
            if([ event.title isEqualToString: anEvent.title ]) {
                return NO;
            }
        }
    }

    return YES;
}

@end
