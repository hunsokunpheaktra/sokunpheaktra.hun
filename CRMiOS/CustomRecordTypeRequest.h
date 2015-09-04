//
//  CustomRecordTypeRequest.h
//  CRMiOS
//
//  Created by Sy Pauv on 6/15/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOAPRequest.h"
#import "ResponseParser.h"
#import "CustomRecordTypeResponseParser.h"


@interface CustomRecordTypeRequest : SOAPRequest {
    
}

- (id)initListener:(NSObject <SOAPListener> *)newListener;

@end
