//
//  AttachmentManager.h
//  Parcel
//
//  Created by Gaeasys on 1/7/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@interface Attachment : NSObject

+ (void)remove:(Item *)item;
+ (int)getCount:(NSString *)entity;

+ (Item *)find:(NSString *)entity column:(NSString *)column value:(NSString *)value;
+ (Item *)find:(NSString *)entity criterias:(NSDictionary *)criterias;
+ (void)insert:(Item *)item modifiedLocally:(BOOL)modifiedLocally;
+ (void)update:(Item *)item modifiedLocally:(BOOL)modifiedLocally;
+ (NSArray *)list:(NSString *)entity criterias:(NSDictionary *)criterias;
+ (void)initTable;

@end
