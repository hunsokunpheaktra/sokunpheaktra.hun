//
//  ListRequest.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/6/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOAPRequest.h"
#import "SOAPListener.h"
#import "EntityResponseParser.h"
#import "CurrentUserManager.h"
#import "LocalizationTools.h"

@interface EntityRequest : SOAPRequest {
    NSString *entity;
    NSNumber *startRow;
    NSString *ownerFilter;
    NSString *dateFilter;
    BOOL idFilter;
    BOOL partnerFilter;
}

@property (nonatomic, retain) NSString *entity;
@property (nonatomic, retain) NSNumber *startRow;
@property (nonatomic, retain) NSString *ownerFilter;
@property (nonatomic, retain) NSString *dateFilter;
@property (assign) BOOL idFilter;
@property (assign) BOOL partnerFilter;

- (id)initWithEntity:(NSString *)newEntity listener:(NSObject <SOAPListener> *)newListener;

@end
