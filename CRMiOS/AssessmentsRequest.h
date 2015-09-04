//
//  AssessmentsRequest.h
//  CRMiOS
//
//  Created by Sy Pauv on 5/21/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import "SOAPRequest.h"
#import "AssessmentsResponseParser.h"

@interface AssessmentsRequest : SOAPRequest
- (id)initWithListener:(NSObject <SOAPListener> *)newListener;
@end
