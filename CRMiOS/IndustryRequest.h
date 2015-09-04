//
//  IndustryRequest.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 7/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOAPRequest.h"
#import "IndustryResponseParser.h"

@interface IndustryRequest : SOAPRequest {
    
}

- (id)initWithListener:(NSObject <SOAPListener> *)newListener;

@end
