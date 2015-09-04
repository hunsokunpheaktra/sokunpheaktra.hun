//
//  ProviderRequest.h
//  Parcel
//
//  Created by Hun Sokunpheaktra on 1/9/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProviderRequest.h"

@interface ProviderManager : NSObject{
    
}

+ (NSArray*)checkTrackingNumber:(NSString*)trackingNo;
+ (NSArray*)allProviderRequest:(NSString*)trackingNo;
+ (NSString*)getPoviderURL:(NSString*)provider;
+ (NSDictionary*)findStatus:(NSString*)trackingNo forwarder:(NSString*)forwarder;
+ (ProviderRequest*)getInstanceWithName:(NSString*)trackingNo forwarder:(NSString*)forwarder;

@end
