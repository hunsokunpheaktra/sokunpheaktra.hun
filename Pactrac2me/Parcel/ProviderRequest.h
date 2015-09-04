//
//  ProviderRequest.h
//  Parcel
//
//  Created by Hun Sokunpheaktra on 1/9/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseParser.h"
#import "HTMLParser.h"
#import "HTMLNode.h"

@interface ProviderRequest : NSObject

@property (nonatomic, retain) NSURLConnection *theConnection;
@property (nonatomic, retain) NSMutableData *webData;
@property (nonatomic, retain) NSNumber *status;
@property (nonatomic, retain) NSString *trackingNo;

-(id)initWithTrackingNo:(NSString*)tn;

-(NSDictionary*)doRequest;

-(NSString*)getRegularExpression;
-(NSString*)getBaseURL;
-(NSString*)getMehtod;
-(NSString*)getBody;
-(NSString*)getProviderName;
- (NSDictionary *)htmlParser:(NSString*)htmlText;
-(ResponseParser*)getParser;

@end
