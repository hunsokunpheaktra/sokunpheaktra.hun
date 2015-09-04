//
//  SettingManager.h
//  Parcel
//
//  Created by Hun Sokunpheaktra on 10/29/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@interface SettingManager : NSObject{
    
}

+ (int)getCount;
+ (void)insert:(Item *)item;
+ (void)update:(Item *)item;

+ (Item *)find:(NSString *)entity column:(NSString *)column value:(NSString *)value;
+ (Item *)find:(NSString *)entity criterias:(NSDictionary *)criterias;

+ (void)initTable;

+ (Item*)newSettingItem;

@end
