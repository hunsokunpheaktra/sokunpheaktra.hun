//
//  MapviewController.h
//  SyncForce
//
//  Created by Hun Sokunpheaktra on 12/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Item.h"

@interface MapviewController : UIViewController<MKMapViewDelegate>{
    
    MKMapView *mapview;

}

- (id)initWithFrame:(CGRect)mapFrame account:(Item*)item;
- (CLLocationCoordinate2D)addressLocation:(NSString*)address;
- (NSString *)getAddress:(Item *)newItem;

@end
