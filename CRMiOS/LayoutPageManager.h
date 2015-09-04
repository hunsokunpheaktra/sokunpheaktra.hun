//
//  LayoutPageManager.h
//  CRMiOS
//
//  Created by Sy Pauv on 6/20/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Database.h"
#import "Configuration.h"

@interface LayoutPageManager : NSObject {
    
}
+ (void)initTable;
+ (void)initData;
+ (void)save:(NSString *)subtype page:(int)page name:(NSString *)name;
+ (NSArray *)read:(NSString *)subtype;
+ (BOOL)hasData;

@end
