//
//  DailyAgendaViewController.m
//  TestMap
//
//  Created by Fellow Consulting AG on 8/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "DailyAgendaViewController.h"

#define MAP_PADDING 1.05
#define MIN_VISIBLE_LATITUDE 0.01

@implementation DailyAgendaViewController

@synthesize mapAndTextView, mapView, dataView, listView, routeOverlayView;
@synthesize infoLabel;
@synthesize detailVC;
@synthesize appointmentList, relatedList, currentDate;
@synthesize listWaypoints;
@synthesize popupCalendar;
@synthesize txtDate;
@synthesize mapDirections, mapAnnotation;

- (void)dealloc {
    [self.infoLabel release];
    [self.mapAndTextView release];
    [self.mapView release];
    [self.currentDate release];
    [self.popupCalendar release];
    [self.mapAnnotation release];
    [super dealloc];
    
}



- (id)init {
    self = [super init];
    return self;
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self chooseView];
    [self refreshList];
}

- (void)loadView
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    self.title = NSLocalizedString(@"DAILY_AGENDA", @"daily agenda title");
    
    UIView *mainView = [[UIView alloc] init];
    [self setView:mainView];
    
    self.mapAndTextView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    self.mapAndTextView.layer.shadowRadius = 5;
    self.mapAndTextView.layer.shadowOpacity = 0.5;
    self.mapAndTextView.layer.masksToBounds = NO;
    self.mapAndTextView.autoresizingMask = UIViewAutoresizingNone;
    self.mapAndTextView.layer.shadowOffset = CGSizeMake(-5, -5);
    
    self.mapView = [[MKMapView alloc] initWithFrame:mapAndTextView.frame];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.mapView.zoomEnabled = YES;
    self.mapView.scrollEnabled = YES;
    self.mapView.delegate = self;
    [self.mapAndTextView addSubview:self.mapView];
    
    self.infoLabel = [[UILabel alloc] initWithFrame:self.mapAndTextView.frame];
    self.infoLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.infoLabel.font = [UIFont systemFontOfSize:32];
    self.infoLabel.textAlignment = UITextAlignmentCenter;
    self.infoLabel.numberOfLines = 3;
    [self.mapAndTextView addSubview:self.infoLabel];
    
    
    self.dataView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)] autorelease];
    
    self.txtDate = [[UITextField alloc] initWithFrame:CGRectMake(60, 10, 80, 40)];
    self.txtDate.delegate = self;
    [self.txtDate setBorderStyle:UITextBorderStyleRoundedRect];
    self.txtDate.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.txtDate.textAlignment = UITextAlignmentCenter;
    [self.txtDate setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    txtDate.text = [formatter stringFromDate:[EvaluateTools getTodayGMT]];

    
    self.currentDate = [formatter dateFromString:txtDate.text];
    
    self.listView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, 200, 140) style:UITableViewStylePlain];
    [self.listView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    self.listView.delegate = self;
    self.listView.dataSource = self;
    
    [self.dataView addSubview:txtDate];
    [self.dataView addSubview:listView];
    [self.view addSubview:dataView];
    
    //detail
    self.detailVC = [[[AgendaDetailViewController alloc] initWithItem:nil] autorelease];
    self.detailVC.view.layer.shadowOffset = CGSizeMake(-5, -5);
    self.detailVC.view.layer.shadowRadius = 5;
    self.detailVC.view.layer.shadowOpacity = 0.5;
    self.detailVC.view.layer.masksToBounds = NO;
    [self.detailVC.view setAutoresizingMask:UIViewAutoresizingNone];
    
    [mainView addSubview:detailVC.view];
    [mainView addSubview:self.mapAndTextView];
    
    self.mapAnnotation = [[NSMutableDictionary alloc] initWithCapacity:1];
    self.routeOverlayView = [[UICRouteOverlayMapView alloc] initWithMapView:self.mapView];
    
    
    self.mapDirections = [UICGDirections sharedDirections];
	self.mapDirections.delegate = self;
    

    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    popupCalendar = [[[CalendarViewController alloc] initWithListener:self] autorelease];
    popupCalendar.view.frame = CGRectMake(0, 0, 300, 40);
    [textField resignFirstResponder];
    [popupCalendar showCalendarPopup:textField parentView:self selectDate:self.currentDate];
    
}




- (void)didSelect:(NSString *)field valueId:(NSString *)valueId display:(NSString *)display {
    
    
    NSDateFormatter *parser = [UITools getDateFormatter:@"Date"];
    NSDate *d = [parser dateFromString:valueId];
    
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    txtDate.text = [formatter stringFromDate:d];

    self.currentDate = d;
    [self refreshList];
    
}

- (IBAction)showAnnotationDetails:(id)sender {
    
    UIButton *button = sender;
    NSInteger index = button.tag;
    
    Item *itemStart = [self.listWaypoints objectAtIndex:index - 1];
    Item *itemEnd = [self.listWaypoints objectAtIndex:index];
    
    NSString *url = [NSString stringWithFormat:@"http://maps.google.com/maps?&saddr=%@&daddr=%@",[[self getAddress:itemStart] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[self getAddress:itemEnd] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    AnnotationDetailViewController *annotationView = [[AnnotationDetailViewController alloc] initWithUrl:url];
    
    [self.navigationController pushViewController:annotationView animated:YES];
    
    [annotationView release];
    
}

- (void)update {
    [self.mapAnnotation removeAllObjects];
    [self.mapView removeAnnotations:mapView.annotations];
    [self.routeOverlayView removeFromSuperview];
    [self buildAnnotations];
    [self computeDirections];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.appointmentList count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
    return NSLocalizedString(@"Appointment_PLURAL", @"Table Header");
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Item *item = [appointmentList objectAtIndex:indexPath.row];
    self.detailVC.appointment = item;
    [self.detailVC mustUpdate];
    Item *relatedItem = [self getRelatedItem:item];
    if ([self.mapAnnotation objectForKey:[relatedItem.fields objectForKey:@"gadget_id"]]) {
        NSString *waypointId = [relatedItem.fields objectForKey:@"gadget_id"];
        UICRouteAnnotation *annotation = [self.mapAnnotation objectForKey:waypointId];
        [self.mapView selectAnnotation:annotation animated:YES];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    //setup cell
    Item *item = [appointmentList objectAtIndex:indexPath.row];
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:@"Appointment"];
	cell.textLabel.text = [sinfo getDisplayText:item];
    cell.detailTextLabel.text = [sinfo getDetailText:item];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    
    Item *item = [appointmentList objectAtIndex:indexPath.row];
    [PadTabTools navigateTab:item];
    
}


- (void)computeDirections {
    UICGDirectionsOptions *options = [[[UICGDirectionsOptions alloc] init] autorelease];
    options.travelMode = UICGTravelModeDriving;
    
    NSMutableArray *routePoints = [[NSMutableArray alloc] initWithCapacity:1];
    for (int i = 0; i < [self.listWaypoints count]; i++) {
        [routePoints addObject:[self getAddress:[self.listWaypoints objectAtIndex:i]]];
    }
    
    [self.mapDirections loadFromWaypoints:routePoints options:options];
}

#pragma mark <UICGDirectionsDelegate> Methods

- (void)directionsDidFinishInitialize:(UICGDirections *)directions {
    [self computeDirections];
}

- (void)directions:(UICGDirections *)directions didFailInitializeWithError:(NSError *)error {

    //route error do nothing
	
}

- (void)directionsDidUpdateDirections:(UICGDirections *)newDirections {

    
    // Overlay polylines
    UICGPolyline *polyline = [newDirections polyline];
    NSArray *routePoints = [polyline routePoints];
    [self.routeOverlayView setRoutes:routePoints];
    if (![routeOverlayView isDescendantOfView:self.mapView]) {
        [self.routeOverlayView setFrame:self.mapView.frame];
        [self.mapView addSubview:self.routeOverlayView];
    }

    
}

- (void)directions:(UICGDirections *)directions didFailWithMessage:(NSString *)message {
    
    [self.routeOverlayView removeFromSuperview];
}

- (void)setMapCenter {
    
    if ([self.mapView.annotations count] > 0) {
        
        MKCoordinateRegion region;
        CLLocationCoordinate2D minLocation = [((UICRouteAnnotation*)[mapView.annotations objectAtIndex:0]) coordinate];
        CLLocationCoordinate2D maxLocation = [((UICRouteAnnotation*)[mapView.annotations objectAtIndex:0]) coordinate];
        
        for (int i=1;i<[self.mapView.annotations count];i++){
            UICRouteAnnotation *annotation = ((UICRouteAnnotation*)[mapView.annotations objectAtIndex:i]);
            if(minLocation.latitude > [annotation coordinate].latitude){
                minLocation.latitude = [annotation coordinate].latitude; 
            }
            if(maxLocation.latitude < [annotation coordinate].latitude){
                maxLocation.latitude = [annotation coordinate].latitude; 
            }
            if(minLocation.longitude > [annotation coordinate].longitude){
                minLocation.longitude = [annotation coordinate].longitude; 
            }
            if(maxLocation.longitude < [annotation coordinate].longitude){
                maxLocation.longitude = [annotation coordinate].longitude;
            }
        }
                
        region.center.latitude = (minLocation.latitude + maxLocation.latitude) / 2;
        region.center.longitude = (minLocation.longitude + maxLocation.longitude) / 2;
        
        
        region.span.latitudeDelta = (maxLocation.latitude - minLocation.latitude) * MAP_PADDING;
    
        region.span.latitudeDelta = region.span.latitudeDelta < MIN_VISIBLE_LATITUDE ? MIN_VISIBLE_LATITUDE : region.span.latitudeDelta;
        region.span.longitudeDelta = (maxLocation.longitude - minLocation.longitude) * MAP_PADDING;
        
        [mapView setRegion:region animated:NO];
    }
    
}

- (void)buildAnnotations {
    
    NSMutableArray *tmpAnnotations = [[NSMutableArray alloc] initWithCapacity:1];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    // Add annotations
    for (int i = 0; i < [self.listWaypoints count]; i++) {
        Item *waypoint = [listWaypoints objectAtIndex:i];
        UICRouteAnnotationType type = UICRouteAnnotationTypeWayPoint;
        if (i == 0) type = UICRouteAnnotationTypeStart;
        else if (i == [self.listWaypoints count] - 1) type = UICRouteAnnotationTypeEnd;
        NSString *address = [self getAddress:waypoint];
        UICRouteAnnotation *wayAnnotation = [[[UICRouteAnnotation alloc] initWithCoordinate:[GoogleMapParser getLocationOfAddress:address opener:self] title:[self getName:waypoint] subTitle:address annotationType:type] autorelease];
        [tmpAnnotations addObject:wayAnnotation];
        [self.mapAnnotation setObject:wayAnnotation forKey:[waypoint.fields objectForKey:@"gadget_id"]];
    }

    [self.mapView addAnnotations:tmpAnnotations];
    [tmpAnnotations release];
    if ([self.mapView.annotations count] > 0) [self setMapCenter];
    
}

#pragma mark <MKMapViewDelegate> Methods

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    self.routeOverlayView.hidden = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
	self.routeOverlayView.hidden = NO;
	[self.routeOverlayView setNeedsDisplay];
}

- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id<MKAnnotation>)annotation {
    
    static NSString *identifier = @"RoutePinAnnotation";
	
	if ([annotation isKindOfClass:[UICRouteAnnotation class]]) {
		MKPinAnnotationView *pinAnnotation = (MKPinAnnotationView *)[mv dequeueReusableAnnotationViewWithIdentifier:identifier];
		if(!pinAnnotation) {
			pinAnnotation = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
		}
		if ([(UICRouteAnnotation *)annotation annotationType] == UICRouteAnnotationTypeStart) {
			pinAnnotation.pinColor = MKPinAnnotationColorGreen;
            pinAnnotation.rightCalloutAccessoryView = nil;
		} else if ([(UICRouteAnnotation *)annotation annotationType] == UICRouteAnnotationTypeEnd) {
			pinAnnotation.pinColor = MKPinAnnotationColorRed;
		} else {
			pinAnnotation.pinColor = MKPinAnnotationColorPurple;
		}
        
        if(![(UICRouteAnnotation *)annotation annotationType] == UICRouteAnnotationTypeStart){
            UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            button.tag = [mv.annotations indexOfObject:annotation];
            [button setTitle:((UICRouteAnnotation *)annotation).title forState:UIControlStateDisabled];
            [button addTarget:self action:@selector(showAnnotationDetails:) forControlEvents:UIControlEventTouchUpInside];
            pinAnnotation.rightCalloutAccessoryView = button;
        }
        
		pinAnnotation.animatesDrop = NO;
		pinAnnotation.enabled = YES;
		pinAnnotation.canShowCallout = YES;
        
		return pinAnnotation;
        
	} else {
        
        return [mapView viewForAnnotation:mapView.userLocation];
    }
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}


- (void)refreshList {
    
    self.detailVC.appointment = nil;
    [self.detailVC mustUpdate];


    BetweenCriteria *dateCriteria = [CalendarUtils buildDateCriteria:currentDate];

    
    NSArray *tmp = [EntityManager list:@"Appointment" entity:@"Activity" criterias:[NSArray arrayWithObject:dateCriteria] additional:[NSArray arrayWithObjects:@"PrimaryContactId", @"AccountId", nil] limit:0];
    self.appointmentList = [[tmp reverseObjectEnumerator] allObjects];
    

    self.listWaypoints = [self getListWaypoints];
    [self.listView reloadData];
    
    
    if ([appointmentList count] > 0) {
        NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
        [self tableView:self.listView didSelectRowAtIndexPath:index];
        [self.listView selectRowAtIndexPath:index animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
    
    [self.mapView removeFromSuperview];
    if ([self.appointmentList count] > 0) {
        if ([self.listWaypoints count] > 0) {
            [self.mapAndTextView addSubview:mapView];
            self.infoLabel.text = @"";
        } else {
            self.infoLabel.text = NSLocalizedString(@"LOCATION_NOT_SET", nil);
        }
        [self update];
    } else {
        self.infoLabel.text = NSLocalizedString(@"NO_APPOINTMENT", nil);
    }
    
}

- (Item *)getRelatedItem:(Item *)newItem{
    Item *relatedItem = nil;
    NSMutableArray *relatedEntities = [[NSMutableArray alloc] initWithCapacity:1];
    if ([[Configuration getEntities] indexOfObject:@"Account"] != NSNotFound) {
        [relatedEntities addObject:@"Account"];
    }
    if ([[Configuration getEntities] indexOfObject:@"Contact"] != NSNotFound) {
        [relatedEntities addObject:@"Contact"];
    }
    for (NSString *relatedEntity in relatedEntities) {
        NSString *keyField = [NSString stringWithFormat:@"%@Id", relatedEntity];
        if ([relatedEntity isEqualToString:@"Contact"]) keyField = @"PrimaryContactId";
        NSArray *criterias = [NSArray arrayWithObject:[[ValuesCriteria alloc] initWithColumn:@"Id" value:[newItem.fields objectForKey:keyField]]];
        relatedItem = [EntityManager find:relatedEntity criterias:criterias];
        if (relatedItem != nil) break;
    }
    return relatedItem;
    
}

- (NSString *)getName:(Item *)waypoint {
    NSString *subtype = [Configuration getSubtype:waypoint];
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:subtype entity:waypoint.entity];
    return [sinfo getDisplayText:waypoint];
}

- (NSString *)getAddress:(Item *)waypoint {
    NSArray *addressFields = nil;
    if ([waypoint.entity isEqualToString:@"Account"]) {
        addressFields = [NSArray arrayWithObjects:@"PrimaryBillToStreetAddress", @"PrimaryBillToPostalCode", @"PrimaryBillToCity", @"PrimaryBillToCountry", nil];
    } else if ([waypoint.entity isEqualToString:@"Contact"]) {
        addressFields = [NSArray arrayWithObjects:@"AlternateAddress1", @"AlternateZipCode", @"AlternateCity", @"AlternateCountry", nil];
    }
    NSMutableString *address = [[[NSMutableString alloc] initWithCapacity:1] autorelease];
    if (addressFields != nil) {
        for (NSString *addressField in addressFields) {
            if ([waypoint.fields objectForKey:addressField]!=nil) {
                [address appendFormat:@"%@ ",[waypoint.fields objectForKey:addressField]];
            }
        }
    }
    return address;
}


- (void)chooseView {
    UIInterfaceOrientation deviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (deviceOrientation == UIInterfaceOrientationPortrait || deviceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        self.detailVC.view.frame = CGRectMake(384, 0, 384, 400);
        self.dataView.frame = CGRectMake(0, 0, 384, 400);
        self.mapAndTextView.frame = CGRectMake(0, 400, 768, 512);
    } else {
        self.detailVC.view.frame = CGRectMake(0, 330, 400, 384);
        self.dataView.frame = CGRectMake(0, 0, 400, 384);
        self.mapAndTextView.frame = CGRectMake(400, 0, 624, 768);
    }
}

- (void)orientationChanged:(NSNotification *)notification {
    [self chooseView];
}

- (NSArray *)getListWaypoints {    
    NSMutableArray *tmpList = [[NSMutableArray alloc] initWithCapacity:1];
    for (Item *tmp in self.appointmentList) {
        Item *waypoint = [self getRelatedItem:tmp];
        if (waypoint!=nil) {
            NSString *address = [self getAddress:waypoint];
            if (![[address stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
                CLLocationCoordinate2D location = [GoogleMapParser getLocationOfAddress:address opener:self];
                if (location.latitude != 0.0 && location.longitude != 0.0) {
                    [tmpList addObject:waypoint];
                }
            }
        }
    }
    return tmpList;
}


@end
