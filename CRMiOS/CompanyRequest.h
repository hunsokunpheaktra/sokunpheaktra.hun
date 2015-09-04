//
//  CompanyRequest.h
//  CRMiOS
//
//  Created by Arnaud Marguerat on 8/30/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOAPRequest.h"
#import "CompanyResponseParser.h"

@interface CompanyRequest : SOAPRequest {
}

- (id)initWithListener:(NSObject <SOAPListener> *)newListener;

@end
