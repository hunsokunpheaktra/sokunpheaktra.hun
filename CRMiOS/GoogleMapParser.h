//
//  MapUtils.h
//  CRMiOS
//
//  Created by Arnaud on 11/03/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSXMLParser.h>
#import <MapKit/MapKit.h>
#import "ParserListener.h"

@interface GoogleMapParser : NSObject <NSXMLParserDelegate> {
    NSMutableString *currentText;
    BOOL _inLocation;
    NSString *status;
    NSString *latitude, *longitude;
}

@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSMutableString *currentText;
@property (assign) BOOL inLocation;
@property (nonatomic, retain) NSString *latitude, *longitude;

- (void)parse:(NSData *)data;
+ (CLLocationCoordinate2D)getLocationOfAddress:(NSString *)address opener:(NSObject<UIAlertViewDelegate> *)opener;

@end
