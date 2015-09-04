//
//  Marker.m
//  TestMap
//
//  Created by Fellow Consulting AG on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Marker.h"

@implementation Marker

@synthesize coordinate;

- (NSString *)subtitle{
	return newSubTitle;
}
- (NSString *)title{
	return newTitle;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	coordinate=c;
	return self;
}

@end
