//
//  RelatedListsInfo.h
//  SyncForce
//
//  Created by Gaeasys Admin on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseManager.h"
#import "InfoFactory.h"
#import "EntityInfo.h"
#import "IsNullCriteria.h"
#import "Item.h"

#define RELATEDLISTSINFO_ENTITY @"RelatedListsInfo"
@interface RelatedListsInfoManager : NSObject{
    
}

+ (void)initTable;
+ (void)insert:(Item *)item;
+ (Item *)find:(NSDictionary *)criterias;
+ (NSArray *)list:(NSDictionary *)criterias;

@end
