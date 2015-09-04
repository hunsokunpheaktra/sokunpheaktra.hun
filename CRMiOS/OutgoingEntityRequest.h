//
//  OutgoingEntityRequest.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/12/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOAPRequest.h"
#import "EntityManager.h"
#import "OutgoingResponseParser.h"
#import "IsNotNullCriteria.h"
#import "IsNullCriteria.h"
#import "CurrentUserManager.h"
#import "RelationManager.h"
#import "LocalizationTools.h"

@interface OutgoingEntityRequest : SOAPRequest {
    NSString *entity;
    Item *item;
    NSNumber *isDelete;
    NSNumber *incomplete;
}

@property (nonatomic, retain) NSString *entity;
@property (nonatomic, retain) Item *item;
@property (nonatomic, retain) NSNumber *isDelete;
@property (nonatomic, retain) NSNumber *incomplete;

- (id)initWithEntity:(NSString *)newEntity listener:(NSObject <SOAPListener> *)newListener isDelete:(BOOL)deleteItem ;
- (NSString *)getAction;

@end
