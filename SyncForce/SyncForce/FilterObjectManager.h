//
//  FilterObjectManager.h
//  SyncForce
//
//  Created by Hun Sokunpheaktra on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@interface FilterObjectManager : NSObject{
    
}

+ (void)insert:(Item *)item modifiedLocally:(BOOL)modifiedLocally;
+ (void)update:(Item *)item modifiedLocally:(BOOL)modifiedLocally;
+ (void)remove:(NSString*)entity;

+ (void)initData;
+ (void)initTable;

+ (NSArray *)list:(NSString*)entity;
+ (Item *)find:(NSString *)entity;

@end
