//
//  MapViewController.m
//  CRMiOS
//
//  Created by Sy Pauv on 6/27/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "MapViewController.h"

@implementation AddressAnnotation

@synthesize coordinate;
@synthesize mTitle, mSubTitle;

- (NSString *)subtitle {
	return mSubTitle;
}
- (NSString *)title {
	return mTitle;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)c withTitle:(NSString *)title subTitle:(NSString *)subtitle{
	coordinate = c;
    self.mTitle = title;
    self.mSubTitle = subtitle;
	return self;
}

@end

@implementation MapViewController

@synthesize strAddress, item;


-(id)initWithItem:(Item *)newItem{
    self.item = newItem;
    return [super init];

}

- (void)viewDidLoad {
    self.title = @"Address";
    
    if ([item.entity isEqualToString:@"Contact"]) {
        self.strAddress = [NSString stringWithFormat:@"%@,%@,%@",
            [item.fields objectForKey:@"AlternateAddress1"],
            [item.fields objectForKey:@"AlternateCity"],
            [item.fields objectForKey:@"AlternateCountry"], nil];
    } else if ([item.entity isEqualToString:@"Lead"]) {
        self.strAddress = [NSString stringWithFormat:@"%@,%@,%@",
           [item.fields objectForKey:@"StreetAddress"],
           [item.fields objectForKey:@"City"],
           [item.fields objectForKey:@"Country"], nil];
    } else {
        self.strAddress = [NSString stringWithFormat:@"%@,%@,%@",
           [item.fields objectForKey:@"PrimaryBillToStreetAddress"],
           [item.fields objectForKey:@"PrimaryBillToCity"],
           [item.fields objectForKey:@"PrimaryBillToCountry"], nil];
    }


    
    mapView =[[MKMapView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    mapView.mapType = MKMapTypeStandard;
    self.view = mapView;
	
    MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta=0.0;
	span.longitudeDelta=0.01;
	
	CLLocationCoordinate2D location = [GoogleMapParser getLocationOfAddress:self.strAddress opener:self];
	region.span=span;
	region.center=location;
	
	if(addAnnotation != nil) {
		[mapView removeAnnotation:addAnnotation];
		[addAnnotation release];
		addAnnotation = nil;
	}
	addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:location withTitle:[item.fields objectForKey:@"AccountName"] subTitle:self.strAddress];
	[mapView addAnnotation:addAnnotation];
	
	[mapView setRegion:region animated:TRUE];
	[mapView regionThatFits:region];

    [super viewDidLoad];
}



- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
    
	MKPinAnnotationView *annView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
	annView.pinColor = MKPinAnnotationColorGreen;
	annView.animatesDrop = TRUE;
	annView.canShowCallout = YES;
	annView.calloutOffset = CGPointMake(-5, 5);
	return annView;

}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

-(void)back{

    [self dismissModalViewControllerAnimated:YES];
    
}

@end
