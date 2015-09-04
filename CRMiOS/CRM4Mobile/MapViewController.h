//
//  MapViewController.h
//  CRMiOS
//
//  Created by Sy Pauv on 6/27/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Item.h"
#import "GoogleMapParser.h"

@class Item;

@interface AddressAnnotation : NSObject<MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	
	NSString *mTitle;
	NSString *mSubTitle;
}
@property (nonatomic,retain) NSString *mSubTitle;
@property (nonatomic,retain) NSString *mTitle;
@end

@interface MapViewController : UIViewController<MKMapViewDelegate, UIAlertViewDelegate> {
    
	IBOutlet UITextField *addressField;
	IBOutlet UIButton *goButton;
	IBOutlet MKMapView *mapView;
	AddressAnnotation *addAnnotation;
    NSString *strAddress;
    Item *item;
    
}
@property (nonatomic, retain) NSString *strAddress;
@property (nonatomic, retain) Item *item;

- (id)initWithItem:(Item *)newItem;
- (void)back;




@end
