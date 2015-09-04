//
//  PharmaRequest.h
//  CRMiOS
//
//  Created by Sy Pauv on 11/3/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOAPRequest.h"
#import "PharmaResponseParser.h"

@interface PharmaRequest : SOAPRequest {
    
}
- (id)initWithListener:(NSObject <SOAPListener> *)newListener;
@end
