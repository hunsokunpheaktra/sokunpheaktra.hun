//
//  AttachmentEntitymanager.h
//  Pactrac2me
//
//  Created by Sy Pauv on 1/24/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@interface AttachmentEntitymanager : NSObject
+ (void)initTable;
+ (Item *)find:(NSString *)entity column:(NSString *)column value:(NSString *)value;
+ (Item *)find:(NSString *)entity criterias:(NSDictionary *)criterias;
+ (void)insert:(Item *)item modifiedLocally:(BOOL)modifiedLocally;
+ (void)update:(Item *)item modifiedLocally:(BOOL)modifiedLocally;
+ (NSArray *)list:(NSString *)entity criterias:(NSDictionary *)criterias;
+ (NSMutableDictionary *)findAttachmentByParentId:(NSString *)pId;
+ (NSMutableDictionary *)newAttachment;
@end
