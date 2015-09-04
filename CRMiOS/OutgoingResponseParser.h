//
//  OutgoingResponseParser.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/12/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseParser.h"
#import "EntityManager.h"
#import "ValuesCriteria.h"
#import "IsNotNullCriteria.h"

@interface OutgoingResponseParser : ResponseParser {
    NSString *entity;  
    Item *item;
    NSMutableDictionary *currentItem;
    NSNumber *isDelete;
    NSNumber *incomplete;
}

@property (nonatomic, retain) NSString *entity;
@property (nonatomic, retain) Item *item;
@property (nonatomic, retain) NSMutableDictionary *currentItem;
@property (nonatomic, retain) NSNumber *isDelete;
@property (nonatomic, retain) NSNumber *incomplete;

- (id)initWithEntity:(NSString *)newEntity item:(Item *)item isDelete:(BOOL)isDelete incomplete:(BOOL)incomplete;

@end
