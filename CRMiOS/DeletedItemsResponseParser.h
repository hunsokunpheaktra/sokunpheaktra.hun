//
//  DeletedItemsResponseParser.h
//  CRMiOS
//
//  Created by Sy Pauv on 7/13/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseParser.h"
#import "Database.h"


@interface DeletedItemsResponseParser : ResponseParser {
    NSMutableDictionary *currentItem;
}

@property (nonatomic ,retain)  NSMutableDictionary *currentItem;
-(id)init;

@end
