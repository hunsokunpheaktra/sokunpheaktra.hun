//
//  CustomAnotation.h
//  SMBClient4Mobile
//
//  Created by Sy Pauv Phou on 6/4/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CustomAnotation : NSObject<MKAnnotation>
{
	CLLocationCoordinate2D coordinate;
	NSString *title;
	NSString *subtitle;

}
-(id)initWithCoordinate:(CLLocationCoordinate2D)inCoord;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end
