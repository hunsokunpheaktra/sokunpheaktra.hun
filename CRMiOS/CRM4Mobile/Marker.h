//
//  Marker.h
//  TestMap
//
//  Created by Fellow Consulting AG on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Marker : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *newTitle;
    NSString *newSubTitle;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;


-(id)initWithCoordinate:(CLLocationCoordinate2D) coordinate;
- (NSString *)subtitle;
- (NSString *)title;

@end
