//
//  PicklistRequest.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/9/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOAPRequest.h"
#import "PicklistResponseParser.h"
#import "LocalizationTools.h"

@interface PicklistRequest : SOAPRequest {
    NSString *entity;
}

@property (nonatomic, retain) NSString *entity;

- (id)initWithEntity:(NSString *)newEntity listener:(NSObject <SOAPListener> *)newListener;

@end
