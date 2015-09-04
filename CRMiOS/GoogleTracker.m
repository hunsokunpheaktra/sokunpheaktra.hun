//
//  GoogleTracker.m
//  CRMiOS
//
//  Created by Sy Pauv on 8/10/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "GoogleTracker.h"


@implementation GoogleTracker
static const NSInteger kGANDispatchPeriodSec = 10;

+(void)startTrack{

    //UA-24945973-2
    //UA-9914116-4
    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-9914116-4"
                                           dispatchPeriod:kGANDispatchPeriodSec
                                                 delegate:nil];
    
    NSError *error;
    if (![[GANTracker sharedTracker] trackPageview:@"/CRM4Mobile"
                                         withError:&error]) {
        //handle error
    }

}

@end
