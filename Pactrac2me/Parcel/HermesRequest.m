//
//  HermesRequest.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 1/14/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "HermesRequest.h"
#import "HermesParser.h"

@implementation HermesRequest

-(NSString*)getMehtod{
    return @"GET";
}
-(NSString*)getBaseURL{
    
    //self.trackingNo = @"73010148601645";
    //return @"https://tracking.hermesworld.com/SISYRestAPIWebApp/V1/sisy-rs/GetHistoryByID?id=73010148601645&lng=en&token=1d155daa6173ddef89039f55b78b9f4812ec9d9384c7adeff7836bee91da5a550b424c349368d8843790ccf7649402d0&_=1359397763956";
    
    return [NSString stringWithFormat:@"https://tracking.hermesworld.com/SISYRestAPIWebApp/V1/sisy-rs/GetHistoryByID?id=%@&lng=en&token=1d155daa6173ddef89039f55b78b9f4812ec9d9384c7adeff7836bee91da5a550b424c349368d8843790ccf7649402d0&_=1359397763956", self.trackingNo];
}
-(NSString*)getBody{
    return @"";
}
-(NSString *)getProviderName{
    return @"Hermes";
}

-(NSString*)getRegularExpression{
    return @"^\\d{14}$";
}

-(ResponseParser *)getParser{
    return [[[HermesParser alloc] init] autorelease];
}

@end
