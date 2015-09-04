//
//  LayoutInfoManager.h
//  SyncForce
//
//  Created by Gaeasys Admin on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseManager.h"
#import "InfoFactory.h"
#import "EntityInfo.h"
#import "IsNullCriteria.h"
#import "Item.h"

#define EDITLAYOUTSECTIONSINFO_ENTITY @"EditLayoutSectionsInfo"

@interface EditLayoutSectionsInfoManager : NSObject
{
    
}

+ (void)initTable;
+ (void)insert:(Item *)item;
+ (void)update:(Item *)item;
+ (Item *)find:(NSDictionary *)criterias;
+ (NSArray *)list:(NSDictionary *)criterias;

@end
