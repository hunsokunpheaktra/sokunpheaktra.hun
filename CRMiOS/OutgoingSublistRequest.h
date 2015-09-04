//
//  OutgoingSublistRequest.h
//  CRMiOS
//
//  Created by Arnaud Marguerat on 1/11/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOAPRequest.h"
#import "SublistManager.h"
#import "OutgoingSublistParser.h"
#import "RelationManager.h"
#import "LocalizationTools.h"

@interface OutgoingSublistRequest : SOAPRequest {
    NSString *entity;
    NSString *sublist;
    SublistItem *item;
}

@property (nonatomic, retain) NSString *entity;
@property (nonatomic, retain) NSString *sublist;
@property (nonatomic, retain) SublistItem *item;

- (id)initWithEntity:(NSString *)newEntity sublist:(NSString *)newSublist listener:(NSObject <SOAPListener> *)newListener;

@end
