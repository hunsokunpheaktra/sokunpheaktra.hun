//
//  UICRouteAnnotation.m
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "UICRouteAnnotation.h"

@implementation UICRouteAnnotation

@synthesize coordinate;
@synthesize title,subTitle;
@synthesize annotationType;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord 
				   title:(NSString *)aTitle
                   subTitle:(NSString *)aSub
		  annotationType:(UICRouteAnnotationType)type {
	self = [super init];
	if (self != nil) {
		coordinate = coord;
		title = [aTitle retain];
        subTitle = [aSub retain];
		annotationType = type;
	}
	return self;
}

- (NSString *)subtitle{
    return self.subTitle;
}

- (void)dealloc {
	[title release];	
    [subTitle release];
	[super dealloc];
}

@end
