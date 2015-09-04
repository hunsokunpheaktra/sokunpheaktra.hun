//
//  FieldManagementRequest.h
//  CRMiOS
//
//  Created by Arnaud on 1/11/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOAPRequest.h"
#import "FieldManagementParser.h"

@interface FieldManagementRequest : SOAPRequest;

- (id)initWithListener:(NSObject <SOAPListener> *)newListener;

@end
