//
//  MetadataChangeRequest.h
//  CRMiOS
//
//  Created by Sy Pauv on 7/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOAPRequest.h"
#import "MetadataChangeResponseParser.h"

@interface MetadataChangeRequest : SOAPRequest {
    
}

- (id)initWithListener:(NSObject<SOAPListener> *)Newlistener;

@end
