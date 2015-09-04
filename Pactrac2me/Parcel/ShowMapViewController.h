//
//  ShowMapViewController.h
//  Parcel
//
//  Created by Hun Sokunpheaktra on 11/14/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Item.h"

@interface ShowMapViewController : UIViewController<MKMapViewDelegate,UITableViewDataSource,UITableViewDelegate>{
    
    MKMapView *mapView;
    UITableView *myTableView;
    Item *currentItem;
    UIImageView *detailBg;
    NSArray *allFieldLabel;
    NSArray *allFieldName;
    
}

@property(nonatomic,retain)UITableView *myTableView;
@property(nonatomic,retain)MKMapView *mapView;

-(id)initWithItem:(Item*)item;

-(void)initDetail:(CGRect)frame;
-(void)segmentChange:(UISegmentedControl*)segment;
-(void)showCurrentLocation;
-(void)showItemDetail;
-(void)done;

@end
