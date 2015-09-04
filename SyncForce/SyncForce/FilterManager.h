//
//  FilterManager.h
//  SyncForce
//
//  Created by Hun Sokunpheaktra on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"
#import "DatabaseManager.h"
#import "InfoFactory.h"

@interface FilterManager : NSObject{
    
}

+ (void)insert:(Item *)item modifiedLocally:(BOOL)modifiedLocally;
+ (void)update:(Item *)item modifiedLocally:(BOOL)modifiedLocally;
+ (void)remove:(Item *)item;

+ (void)initData;
+ (void)initTable;

+ (NSArray *)list:(NSMutableDictionary*)criteria;
+ (Item *)find:(NSString *)entity;

@end
