//
//  SublistManager.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 11/8/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Configuration.h"
#import "Subtype.h"
#import "Database.h"
#import "SublistItem.h"


@interface SublistManager : NSObject {
    
}

+ (void)insert:(SublistItem *)item locally:(BOOL)locally;
+ (void)update:(SublistItem *)item locally:(BOOL)locally;
+ (void)remove:(SublistItem *)item;
+ (SublistItem *)find:(NSString *)entity sublist:(NSString *)sublist criterias:(NSArray *)criterias;
+ (NSArray *)list:(NSString *)entity sublist:(NSString *)sublist criterias:(NSArray *)criterias;

+ (NSDictionary *)getSublists:(Item *)item;
    
+ (void)initData;
+ (void)initTables;

+ (NSString *)getTableName:(NSString *)entity sublist:(NSString *)sublist;


@end
