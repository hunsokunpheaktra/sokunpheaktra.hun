//
//  ProviderRequest.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 1/9/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "ProviderManager.h"
#import "ProviderRequest.h"
#import "FedexRequest.h"
#import "HermesRequest.h"
#import "TNTRequest.h"
#import "UPSRequest.h"
#import "DHLRequest.h"
#import "DPDRequest.h"
#import "GLSRequest.h"
#import "PostAtRequest.h"

static NSMutableDictionary *allProviderURL;

@implementation ProviderManager

+(NSArray*)checkTrackingNumber:(NSString*)trackingNo{
    
    NSMutableArray *providers = [[NSMutableArray alloc] initWithCapacity:1];
    
    //BOOL isExist = NO;
    for(ProviderRequest *request in [self allProviderRequest:trackingNo]){
        
        NSString *pattern = [request getRegularExpression];
        NSError* error = nil;
        
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
        NSTextCheckingResult *match = [regex firstMatchInString:trackingNo options:0 range:NSMakeRange(0, trackingNo.length)];
        
        if(match){
            [providers addObject:[request getProviderName]];
        }
                
    }
    
    return providers;
    
}

+ (NSDictionary*)findStatus:(NSString*)trackingNo forwarder:(NSString*)forwarder{
    
    ProviderRequest *request = [self getInstanceWithName:trackingNo forwarder:forwarder];
    NSMutableDictionary *dicReturn = [NSMutableDictionary dictionary];
    
    BOOL isExist = NO;
    NSDictionary *response = [request doRequest];
    NSNumber *statusCode = [response objectForKey:@"statusCode"];
    if(statusCode.intValue == 200){
        isExist = [[request getParser] parse:response];
    }
    
    if(isExist){
        
        /* key to get status --> @"keyStatus" */
        /*key to get provider name --> @"providerName" */
        NSDictionary* dataRetrieved = [[request getParser] dataReturned:response];
        [dicReturn addEntriesFromDictionary:dataRetrieved];
        if ([[dataRetrieved allKeys] count]>0) {
            [dicReturn setValue:[request getProviderName] forKey:@"providerName"];
        }
        
    }

    return dicReturn;
}

+ (ProviderRequest*)getInstanceWithName:(NSString*)trackingNo forwarder:(NSString*)forwarder{
    
    if([forwarder isEqualToString:@"Fedex"]){
        return [[[FedexRequest alloc] initWithTrackingNo:trackingNo] autorelease];
    }else if([forwarder isEqualToString:@"Hermes"]){
        return [[[HermesRequest alloc] initWithTrackingNo:trackingNo] autorelease];
    }else if([forwarder isEqualToString:@"GLS"]){
        return [[[GLSRequest alloc] initWithTrackingNo:trackingNo] autorelease];
    }else if([forwarder isEqualToString:@"TNT"]){
        return [[[TNTRequest alloc] initWithTrackingNo:trackingNo] autorelease];
    }else if([forwarder isEqualToString:@"UPS"]){
        return [[[UPSRequest alloc] initWithTrackingNo:trackingNo] autorelease];
    }else if([forwarder isEqualToString:@"DPD"]){
        return [[[DPDRequest alloc] initWithTrackingNo:trackingNo] autorelease];
    }else if([forwarder isEqualToString:@"DHL"]){
        return [[[DHLRequest alloc] initWithTrackingNo:trackingNo] autorelease];
    }else if([forwarder isEqualToString:@"PostAt"]){
        return [[[PostAtRequest alloc] initWithTrackingNo:trackingNo] autorelease];
    }
    
    return nil;
}

+ (NSArray*)allProviderRequest:(NSString*)trackingNo{
    return [NSArray arrayWithObjects:[[[FedexRequest alloc] initWithTrackingNo:trackingNo] autorelease],
                                     [[[HermesRequest alloc] initWithTrackingNo:trackingNo] autorelease],
                                     [[[GLSRequest alloc] initWithTrackingNo:trackingNo] autorelease],
                                     [[[TNTRequest alloc] initWithTrackingNo:trackingNo] autorelease],
                                     [[[UPSRequest alloc] initWithTrackingNo:trackingNo] autorelease],
                                     [[[DPDRequest alloc] initWithTrackingNo:trackingNo] autorelease],
                                     [[[DHLRequest alloc] initWithTrackingNo:trackingNo] autorelease],
                                     [[[PostAtRequest alloc] initWithTrackingNo:trackingNo] autorelease],
            nil];
}

+ (NSString*)getPoviderURL:(NSString*)provider{
    
    if(!allProviderURL){
        allProviderURL = [[NSMutableDictionary alloc] initWithCapacity:1];
        [allProviderURL setObject:@"http://www.fedex.com/Tracking?action=track&tracknumbers=%@" forKey:@"Fedex"];
        [allProviderURL setObject:@"https://tracking.hermesworld.com/?TrackID=%@" forKey:@"Hermes"];
        [allProviderURL setObject:@"http://www.tnt.de/servlet/Tracking?cons=%@&searchType=CON&genericSiteIdent=&page=1&respLang=de&respCountry=DE&sourceID=1&sourceCountry=ww&plazakey=&refs=&requestType=GEN&navigation=0" forKey:@"TNT"];
        
        [allProviderURL setObject:@"http://wwwapps.ups.com/etracking/tracking.cgi?InquiryNumber1=%@&loc=en_EN&TypeOfInquiryNumber=T" forKey:@"UPS"];
        [allProviderURL setObject:@"http://nolp.dhl.de/nextt-online-public/set_identcodes.do?lang=de&idc=%@&rfn=&extendedSearch=true" forKey:@"DHL"];
        [allProviderURL setObject:@"https://extranet.dpd.de/cgi-bin/delistrack?pknr=%@&typ=1&lang=de" forKey:@"DPD"];
        [allProviderURL setObject:@"http://www.gls-group.eu/276-I-PORTAL-WEB/content/GLS/DE03/EN/5004.htm?txtRefNo=%@&txtAction=71000" forKey:@"GLS"];
    }
    
    return [allProviderURL objectForKey:provider];
    
}

@end
