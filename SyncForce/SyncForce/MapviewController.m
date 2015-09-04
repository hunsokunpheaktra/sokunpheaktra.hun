//
//  MapviewController.m
//  SyncForce
//
//  Created by Hun Sokunpheaktra on 12/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MapviewController.h"

@interface AddressAnnotation : NSObject<MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *mTitle;
    NSString *mSubTitle;
}

@property (nonatomic,retain) NSString *mTitle;
@property (nonatomic,retain) NSString *mSubTitle;

@end

@implementation AddressAnnotation

@synthesize coordinate;
@synthesize mTitle,mSubTitle;

- (NSString *)subtitle{
    return mSubTitle;
}

- (NSString *)title{
    return mTitle;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
    coordinate=c;
    return self;
}
@end

@implementation MapviewController

- (id)initWithFrame:(CGRect)mapFrame account:(Item*)item{
    
    mapview = [[[MKMapView alloc] initWithFrame:mapFrame] autorelease];
    mapview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    mapview.delegate = self;
    mapview.zoomEnabled = YES;
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta=0.01;
    span.longitudeDelta=0.01;
    
    NSString *address = [self getAddress:item];
    
    CLLocationCoordinate2D location = [self addressLocation:address];
    region.span=span;
    region.center=location;
    
    AddressAnnotation *addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:location];
    
    addAnnotation.mTitle = [item.fields valueForKey:@"Name"];
    addAnnotation.mSubTitle = address;
    
    [mapview addAnnotation:addAnnotation];
    [addAnnotation release];
    [mapview setRegion:region animated:TRUE];
    [mapview regionThatFits:region];
    
    self.view = mapview;
    
    return self;
}

-(CLLocationCoordinate2D)addressLocation:(NSString*)address{
    
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=csv", 
                           [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *locationString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    NSArray *listItems = [locationString componentsSeparatedByString:@","];
    
    double latitude = 0.0;
    double longitude = 0.0;
    
    if([listItems count] >= 4 && [[listItems objectAtIndex:0] isEqualToString:@"200"]) {
        latitude = [[listItems objectAtIndex:2] doubleValue];
        longitude = [[listItems objectAtIndex:3] doubleValue];
    }
    else {
        //Show error
    }
    CLLocationCoordinate2D location;
    location.latitude = latitude;
    location.longitude = longitude;
    
    return location;
}

- (NSString *)getAddress:(Item *)newItem{
    return [NSString stringWithFormat:@"%@ %@ %@ %@ %@", 
             [newItem.fields objectForKey:@"BillingStreet"]==nil?@"":[newItem.fields objectForKey:@"BillingStreet"],
             [newItem.fields objectForKey:@"BillingToPostalCode"]==nil?@"":[newItem.fields objectForKey:@"BillingToPostalCode"],
             [newItem.fields objectForKey:@"BillingCity"]==nil?@"":[newItem.fields objectForKey:@"BillingCity"],
             [newItem.fields objectForKey:@"BillingState"]==nil?@"":[newItem.fields objectForKey:@"BillingState"],
             [newItem.fields objectForKey:@"BillingCountry"]==nil?@"":[newItem.fields objectForKey:@"BillingCountry"]];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
    MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
    annView.pinColor = MKPinAnnotationColorGreen;
    annView.canShowCallout = YES;
    annView.calloutOffset = CGPointMake(-5, 5);
    return annView;
}

-(void)dealloc{
    [super dealloc];
    [mapview release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return YES;
}

@end
