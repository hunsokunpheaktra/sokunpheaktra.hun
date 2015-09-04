//
//  FedexRequest.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 1/14/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "FedexRequest.h"
#import "FedexParser.h"

@implementation FedexRequest

-(NSString*)getMehtod{
    return @"POST";
}
-(NSString*)getBaseURL{
    
    return @"https://www.fedex.com/trackingCal/track";
    //return  @"http://www.fedex.com/Tracking?ascend_header=1&clienttype=dotcomreg&cntry_code=de&language=french&tracknumbers=";
}
-(NSString*)getBody{
    
    //self.trackingNo = @"531346988234";
    return [NSString stringWithFormat:@"action=trackpackages&data={\"TrackPackagesRequest\":{\"appType\":\"wtrk\",\"uniqueKey\":\"\",\"processingParameters\":{\"anonymousTransaction\":true,\"clientId\":\"WTRK\",\"returnDetailedErrors\":true,\"returnLocalizedDateTime\":false},\"trackingInfoList\":[{\"trackNumberInfo\":{\"trackingNumber\":\"%@\",\"trackingQualifier\":\"\",\"trackingCarrier\":\"\"}}]}}",self.trackingNo];
}

-(NSString *)getProviderName{
    return @"Fedex";
}

-(NSString*)getRegularExpression{
    return @"\\b96 ?\\d{5} ?\\d{3} ?\\d{3} ?\\d{3} ?\\d{3} ?\\d{3}\\b|"
    "\\b\\d{3} ?\\d{3} ?\\d{3} ?\\d{3} ?\\d{3}\\b|"
    "\\b\\d{3} ?\\d{3} ?\\d{3} ?\\d{3}\\b";
}

-(ResponseParser *)getParser{
    return [[[FedexParser alloc] init] autorelease];
}



@end

