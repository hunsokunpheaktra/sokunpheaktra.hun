//
//  DailyAgendaViewController.h
//  DailyAgendaViewController
//
//  Created by Fellow Consulting AG on 8/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "UICGDirections.h"
#import "SelectionListener.h"
#import "UICRouteOverlayMapView.h"
#import "NavigateListener.h"
#import "CalendarViewController.h"
#import "UICRouteAnnotation.h"
#import "AnnotationDetailViewController.h"
#import "BigDetailViewController.h"
#import "PadMainViewController.h"
#import "AgendaDetailViewController.h"
#import "GoogleMapParser.h"

@class CalendarViewController;
@class AgendaDetailViewController;

@interface DailyAgendaViewController : UIViewController<SelectionListener, MKMapViewDelegate, UICGDirectionsDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate> {
    
    MKMapView *mapView;
    UICGDirections *mapDirections;
    UICRouteOverlayMapView *routeOverlayView;
    UILabel *infoLabel;
    AgendaDetailViewController *detailVC;
    CalendarViewController *popupCalendar;
    UIView *mapAndTextView;
    UITableView *listView;
    UIView *dataView;
    UITextField *txtDate;

    
    NSMutableDictionary *mapAnnotation;
    NSMutableDictionary *mapData;
    NSMutableArray *columns;
    NSArray *appointmentList;
    NSDate *currentDate;
    NSArray *listWaypoints;

    
}

@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) CalendarViewController *popupCalendar;
@property (nonatomic, retain) UICRouteOverlayMapView *routeOverlayView;
@property (nonatomic, retain) UITableView *listView;
@property (nonatomic, retain) UIView *dataView;
@property (nonatomic, retain) UIView *mapAndTextView;
@property (nonatomic, retain) UILabel *infoLabel;
@property (nonatomic, retain) AgendaDetailViewController *detailVC;
@property (nonatomic, retain) UITextField *txtDate;

@property (nonatomic, retain) NSMutableDictionary *mapAnnotation;
@property (nonatomic, retain) UICGDirections *mapDirections;
@property (nonatomic, retain) NSArray *listWaypoints;
@property (nonatomic, retain) NSDate *currentDate;
@property (nonatomic, retain) NSArray *appointmentList;
@property (nonatomic, retain) NSArray *relatedList;

- (void)update;
- (void)refreshList;
- (Item *)getRelatedItem:(Item *)newItem;
- (NSString *)getAddress:(Item *)newItem;
- (NSArray *)getListWaypoints;
- (void)chooseView;
- (IBAction)showAnnotationDetails:(id)sender;
- (void)buildAnnotations;
- (void)setMapCenter;

@end
