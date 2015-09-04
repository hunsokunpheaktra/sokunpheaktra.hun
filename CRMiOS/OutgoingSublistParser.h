//
//  OutgoingSublistParser.h
//  CRMiOS
//
//  Created by Arnaud Marguerat on 1/11/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseParser.h"
#import "SublistManager.h"

@interface OutgoingSublistParser : ResponseParser {
    NSString *entity;  
    NSString *sublist;
    SublistItem *item;
    NSMutableDictionary *currentItem;
}


@property (nonatomic, retain) NSString *entity;
@property (nonatomic, retain) NSString *sublist;
@property (nonatomic, retain) Item *item;
@property (nonatomic, retain) NSMutableDictionary *currentItem;

- (id)initWithEntity:(NSString *)newEntity sublist:(NSString *)newSublist item:(SublistItem *)newItem;

@end
