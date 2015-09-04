//
//  UserManager.h
//  Parcel
//
//  Created by Hun Sokunpheaktra on 11/21/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@interface UserManager : NSObject{
    
}

+ (NSDictionary*)list:(NSDictionary*)criterias;
+ (void)insert:(Item *)item;
+ (void)update:(Item *)item;

+ (void)initTable;


+ (NSArray*) find: (NSDictionary*)criterias;
+ (Item *)find:(NSString *)entity column:(NSString *)column value:(NSString *)value;
+ (Item *)find:(NSString *)entity criterias:(NSDictionary *)criterias;

@end
