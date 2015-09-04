//
//  GLSRequest.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 1/14/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "GLSRequest.h"
#import "GLSParser.h"

@implementation GLSRequest

-(NSString*)getMehtod{
    return @"GET";
}
-(NSString*)getBaseURL{
    //self.trackingNo = @"Z5BGB06J";
     return [NSString stringWithFormat:@"https://gls-group.eu/app/service/open/rest/DE/en/rstt001?match=%@&caller=witt002",self.trackingNo];
}

-(NSString*)getBody{
    return @"";
}

-(NSString *)getProviderName{
    return @"GLS";
}
-(NSString*)getRegularExpression{
    return @"^\\w{8}$";
}

-(ResponseParser *)getParser{
    return [[[GLSParser alloc] init] autorelease];
}

@end
