//
//  ShowMapViewController.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 11/14/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "ShowMapViewController.h"
#import "PhotoUtile.h"
#import "CustomAnotation.h"
#import "Base64.h"

@implementation ShowMapViewController

@synthesize mapView,myTableView;

-(id)initWithItem:(Item*)item{
    
    self = [super init];
    currentItem = item;
    self.title = NSLocalizedString(@"DELIVERY_LOCATION", @"Delivery Location");
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)] autorelease];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tab-icon1.png"] style:UIBarButtonItemStyleDone target:self action:@selector(showCurrentLocation)] autorelease];
    self.navigationItem.leftBarButtonItem.style = UIBarButtonItemStyleBordered;
    return self;
}

-(void)showCurrentLocation{
    [self addPlaceMarkOnMap];
}

-(void)dealloc{
    [super dealloc];
    [detailBg release];
    [allFieldLabel release];
    [allFieldName release];
}

-(void)done{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect frame = self.view.frame;
    
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-44)];
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
    [self.view addSubview:mapView];
    [mapView release];
    
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"STANDARD", @"Standard"),NSLocalizedString(@"HYBRID", @"Hybrid"),NSLocalizedString(@"SATELLITE", @"Satellite"), nil]];
    segment.segmentedControlStyle = UISegmentedControlStyleBar;
    segment.selectedSegmentIndex = 0;
    [segment setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:11],UITextAttributeFont, nil] forState:UIControlStateNormal];
    [segment sizeToFit];
    [segment addTarget:self action:@selector(segmentChange:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *type = [[[UIBarButtonItem alloc] initWithCustomView:segment] autorelease];
    [segment release];
    
    UIBarButtonItem *space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil] autorelease];
    
    UIBarButtonItem *info = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"PRODUCT_INFO", @"Product Info") style:UIBarButtonItemStyleBordered target:self action:@selector(showItemDetail)] autorelease];
    
    self.navigationController.toolbarHidden = NO;
    self.navigationController.toolbar.tintColor = [UIColor colorWithRed:(65./255.) green:(92./255.) blue:(151./255.) alpha:1];
    self.toolbarItems = [NSArray arrayWithObjects:type, space, info, nil];
    
    allFieldLabel = [[NSArray alloc] initWithObjects:@"Description",@"TrackingNo",@"Forwarder",@"Reciever", nil];
    allFieldName = [[NSArray alloc] initWithObjects:@"description",@"trackingNo",@"forwarder",@"reciever", nil];
    
    [self addPlaceMarkOnMap];
    
}

-(void)initDetail:(CGRect)frame{
    
    UIImage *image = [UIImage imageNamed:@"preview-bg.png"];
    image = [image stretchableImageWithLeftCapWidth:20 topCapHeight:image.size.height/2];
    detailBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, frame.size.width, frame.size.height-15)];
    detailBg.autoresizesSubviews = YES;
    detailBg.image = image;
    [self.view addSubview:detailBg];
    
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 10, frame.size.width-20, detailBg.frame.size.height-20) style:UITableViewStyleGrouped];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [detailBg addSubview:myTableView];
    [myTableView release];
    
    UIView *background = [[UIView alloc] initWithFrame:myTableView.frame];
    background.backgroundColor = [UIColor clearColor];
    myTableView.backgroundView = background;
    [background release];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, myTableView.frame.size.width, 90)];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    Item *att=[currentItem.attachments objectForKey:@"invoiceImage"];
    NSString *b64img=att==nil?@"":[att.fields objectForKey:@"body"];
    image = [UIImage imageWithData:[Base64 decode:b64img]];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.imageView.contentMode = UIViewContentModeScaleAspectFill;
    button.frame = CGRectMake(10, 8, 90, 80);
    [button setImage:image forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithRed:(248./255.) green:(246./255.) blue:(246./255.) alpha:1];
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    button.layer.borderWidth = 3;
    button.layer.shadowOpacity = 0.8;
    button.layer.shadowRadius = 1.5;
    button.layer.shadowOffset = CGSizeMake(0.3, 0.3);
    [headerView addSubview:button];
    
    UIButton *locationBg = [UIButton buttonWithType:UIButtonTypeCustom];
    locationBg.backgroundColor = [UIColor whiteColor];
    locationBg.frame = CGRectMake(112, 8, 178, 80);
    locationBg.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    locationBg.layer.cornerRadius = 3;
    locationBg.layer.shadowRadius = 0.8;
    locationBg.layer.shadowOpacity = 0.8;
    locationBg.layer.shadowOffset = CGSizeMake(0.3, 0.3);
    [headerView addSubview:locationBg];
    
    UILabel *status = [[UILabel alloc] initWithFrame:CGRectMake(7, (locationBg.frame.size.height/2)-21, 158, 30)];
    status.font = [UIFont boldSystemFontOfSize:13];
    status.text = [currentItem.fields objectForKey:@"status"];
    status.backgroundColor = [UIColor clearColor];
    [locationBg addSubview:status];
    [status release];
    
    UILabel *statusDate = [[UILabel alloc] initWithFrame:CGRectMake(7, (locationBg.frame.size.height/2)-2, 158, 20)];
    statusDate.font = [UIFont boldSystemFontOfSize:11];
    statusDate.text = [currentItem.fields objectForKey:@"statusDate"];
    statusDate.textColor = [UIColor grayColor];
    statusDate.backgroundColor = [UIColor clearColor];
    [locationBg addSubview:statusDate];
    [statusDate release];
    
//    UIButton *locationBg1 = [UIButton buttonWithType:UIButtonTypeCustom];
//    locationBg1.backgroundColor = [UIColor whiteColor];
//    locationBg1.frame = CGRectMake(112, locationBg.frame.origin.y + locationBg.frame.size.height + 7, 178, 35);
//    locationBg1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    locationBg1.layer.cornerRadius = 3;
//    locationBg1.layer.shadowRadius = 0.8;
//    locationBg1.layer.shadowOpacity = 0.8;
//    locationBg1.layer.shadowOffset = CGSizeMake(0.3, 0.3);
//    [headerView addSubview:locationBg1];
//    
//    UILabel *location = [[UILabel alloc] initWithFrame:CGRectMake(7, (locationBg.frame.size.height/2)-8, 158, 20)];
//    location.font = [UIFont boldSystemFontOfSize:13];
//    location.text = [currentItem.fields objectForKey:@"location"];
//    location.textColor = [UIColor grayColor];
//    location.backgroundColor = [UIColor clearColor];
//    [locationBg1 addSubview:location];
//    [location release];
    
    myTableView.tableHeaderView = headerView;
    [headerView release];
    
    detailBg.frame = CGRectMake(frame.size.width, frame.size.height-115, 0, 0);
}

- (void)addPlaceMarkOnMap{
    
    [mapView removeAnnotations:mapView.annotations];
    
    NSString *address = [currentItem.fields objectForKey:@"location"];
    CLGeocoder *geoCoder = [[[CLGeocoder alloc] init] autorelease];
    [geoCoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error){
        
        if(!error && placemarks.count > 0){
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            
            CLLocation *location = placemark.location;
            CustomAnotation *annotation = [[CustomAnotation alloc] initWithCoordinate:location.coordinate];
            annotation.title = [NSString stringWithFormat:@"%@ (%@)",[currentItem.fields objectForKey:@"description"],[currentItem.fields objectForKey:@"status"]];
            annotation.subtitle = address;
            [mapView addAnnotation:annotation];
            
            [mapView setCenterCoordinate:annotation.coordinate animated:YES];
            [mapView selectAnnotation:annotation animated:YES];
            [annotation release];
            
        }
        
    }];
    
}

-(void)showItemDetail{
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    if(detailBg.frame.size.width > 0){
        
        mapView.userInteractionEnabled = YES;
        
        [UIView beginAnimations:@"" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        detailBg.frame = CGRectMake(frame.size.width-40, frame.size.height-115, 0, 0);
        
        [UIView commitAnimations];
        
    }else{
        
        mapView.userInteractionEnabled = NO;
        
        [UIView beginAnimations:@"" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        detailBg.frame = CGRectMake(0, 5, frame.size.width, frame.size.height-115);
        
        [UIView commitAnimations];
        
    }
    
}

-(void)segmentChange:(UISegmentedControl*)segment{
    
    if(segment.selectedSegmentIndex == 0){
        mapView.mapType = MKMapTypeStandard;
    }else if(segment.selectedSegmentIndex == 1){
        mapView.mapType = MKMapTypeHybrid;
    }else{
        mapView.mapType = MKMapTypeSatellite;
    }
    
}

#pragma UITableView Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return allFieldName.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSString *fieldName = [allFieldName objectAtIndex:indexPath.row];
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
    cell.textLabel.text = [allFieldLabel objectAtIndex:indexPath.row];
    
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    cell.detailTextLabel.text = [currentItem.fields objectForKey:fieldName];
    
    return cell;
    
}

#pragma MapView delegate

#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
		return nil;
	}
    
	NSString *reuseIdentifier = @"PinView";
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mv dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
    if (!annotationView) {
        annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier] autorelease];
    } else {
        annotationView.annotation = annotation;
    }
    
    annotationView.animatesDrop = YES;
    annotationView.canShowCallout = YES;
    [mv selectAnnotation:annotation animated:YES];
    
    return annotationView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
