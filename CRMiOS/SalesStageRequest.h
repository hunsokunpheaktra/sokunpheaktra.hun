//
//  SalesStageRequest.h
//  CRMiOS
//
//  Created by Sy Pauv on 5/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOAPRequest.h"
#import "SalesStageResponseParser.h"

@interface SalesStageRequest : SOAPRequest {
    
}
- (id)initWithListener:(NSObject <SOAPListener> *)newListener;
- (NSString *)getName;
@end
