//
//  DeletedSublistRequest.h
//  CRMiOS
//
//  Created by Arnaud Marguerat on 8/28/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOAPRequest.h"
#import "SublistManager.h"
#import "DeletedSublistParser.h"
#import "RelationManager.h"
#import "LocalizationTools.h"

@interface DeletedSublistRequest : SOAPRequest {
    NSString *entity;
    NSString *sublist;
    SublistItem *item;
}

@property (nonatomic, retain) NSString *entity;
@property (nonatomic, retain) NSString *sublist;
@property (nonatomic, retain) SublistItem *item;

- (id)initWithEntity:(NSString *)newEntity sublist:(NSString *)newSublist listener:(NSObject <SOAPListener> *)newListener;

@end
