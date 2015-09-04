//
//  OtherPicklistRequest.h
//  CRMiOS
//
//  Created by Sy Pauv on 6/10/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOAPRequest.h"
#import "OtherPicklistResponseParser.h"

@interface OtherPicklistRequest : SOAPRequest {
    NSString *entity;
    NSString *field;
}
@property (nonatomic, retain) NSString *field;
@property (nonatomic, retain) NSString *entity;

- (id)initWithEntity:(NSString *)newEntity field:(NSString *)newField listener:(NSObject <SOAPListener> *)newListener;

@end
