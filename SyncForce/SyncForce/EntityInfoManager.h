//
//  EntityInfoManager.h
//  SalesforceSyncModule
//
//  Created by Gaeasys Admin on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"
#import "DatabaseManager.h"

#define ENTITYINFO_ENTITY @"EntityInfo"
@interface EntityInfoManager : NSObject {
    
}

+ (void)initTable;
+ (void)insert:(Item *)item;
+ (Item *)find:(NSDictionary *)criterias;
+ (NSArray *)list:(NSDictionary *)criterias;

@end
