//
//  RageIAPHelper.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 12/24/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "RageIAPHelper.h"

@implementation RageIAPHelper

+ (RageIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static RageIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.Parcel.deleteAds",
                                      @"com.Parcel.synchronize",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}


@end
