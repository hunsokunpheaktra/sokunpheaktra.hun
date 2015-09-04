//
//  UICRouteAnnotation.h
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum UICRouteAnnotationType {
	UICRouteAnnotationTypeStart,
	UICRouteAnnotationTypeEnd,
	UICRouteAnnotationTypeWayPoint,
} UICRouteAnnotationType;

@interface UICRouteAnnotation : NSObject<MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	NSString *title;
    NSString *subTitle;
	UICRouteAnnotationType annotationType;
}

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, retain) NSString *subTitle;
@property (nonatomic) UICRouteAnnotationType annotationType;

- (NSString *)subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord 
				   title:(NSString *)aTitle
                subTitle:(NSString *)aSub
		  annotationType:(UICRouteAnnotationType)type;

@end
