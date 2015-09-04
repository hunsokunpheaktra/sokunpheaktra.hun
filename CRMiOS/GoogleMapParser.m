//
//  MapUtils.m
//  CRMiOS
//
//  Created by Arnaud on 11/03/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import "GoogleMapParser.h"

@implementation GoogleMapParser

@synthesize latitude, longitude;
@synthesize currentText;
@synthesize status;

- (id)init {
    self = [super init];
    self.status = nil;
    self.currentText = nil;
    self.inLocation = NO;
    return self;
}

- (void)parse:(NSData *)data {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (self.currentText != nil) {
        [self.currentText appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"location"]) {
        self.inLocation = YES;
    }

    self.currentText = [[NSMutableString alloc] init];
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if (self.inLocation) {
        if ([elementName isEqualToString:@"lat"]) {
            self.latitude = [NSString stringWithString:self.currentText];
        }
        if ([elementName isEqualToString:@"lng"]) {
            self.longitude = [NSString stringWithString:self.currentText];
        }
    }
    if ([elementName isEqualToString:@"status"]) {
        self.status = [NSString stringWithString:self.currentText];
    }
    if ([elementName isEqualToString:@"location"]) {
        self.inLocation = NO;
    }
    [self.currentText release];
    self.currentText = nil;

}

+ (CLLocationCoordinate2D)getLocationOfAddress:(NSString *)address opener:(NSObject<UIAlertViewDelegate> *)opener {
    
	NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/xml?address=%@&sensor=false",
                           [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSError* error;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString] options:NSDataReadingUncached error:&error];
    GoogleMapParser *parser = [[GoogleMapParser alloc] init];
    [parser parse:data];
    
	
	double latitude = 0.0;
	double longitude = 0.0;
	
	if ([parser.status isEqualToString:@"OK"]) {
		latitude = [parser.latitude doubleValue];
		longitude = [parser.longitude doubleValue];
	} else {
        
		//Show error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Address not found!" delegate:opener cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        [alert release];
        
	}
    
	CLLocationCoordinate2D location;
	location.latitude = latitude;
	location.longitude = longitude;
	
    [parser release];
    
	return location;
}

@end
