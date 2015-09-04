//
//  CustomAnotation.m
//  SMBClient4Mobile
//
//  Created by Sy Pauv Phou on 6/4/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "CustomAnotation.h"

@implementation CustomAnotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

-(id)init
{
	return self;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)inCoord
{
	coordinate = inCoord;
	return self;
}

@end
