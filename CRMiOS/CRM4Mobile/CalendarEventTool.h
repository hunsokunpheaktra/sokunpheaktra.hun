//
//  CalendarEventTool.h
//  CRMiOS
//
//  Created by Sy Pauv on 12/20/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "EntityManager.h"
@interface CalendarEventTool : NSObject {
}

+ (void)importAppointments;
+ (void)exportAppointments:(NSArray *)listItem;
+ (BOOL)checkExistingEvent:(EKEvent *)event;

@end
