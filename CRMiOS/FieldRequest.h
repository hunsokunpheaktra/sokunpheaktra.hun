//
//  FieldRequest.h
//  CRMiOS
//
//  Created by Sy Pauv on 5/11/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOAPRequest.h"
#import "FieldResponseParser.h"
#import "LocalizationTools.h"

@interface FieldRequest : SOAPRequest {
    
    NSString *entity;
    
}

@property (nonatomic,retain) NSString *entity;

- (id)initWithEntity:(NSString *)newEntity listener:(NSObject <SOAPListener> *)newListener;

@end
