//
//  ServerTimeRequest.h
//  CRMiOS
//
//  Created by Sy Pauv on 7/13/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOAPRequest.h"
#import "ServerTimeResponseParser.h"

@interface ServerTimeRequest : SOAPRequest {
}


- (id)initWithListener:(NSObject <SOAPListener> *)newListener;

@end
