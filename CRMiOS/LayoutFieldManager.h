//
//  LayoutFieldManager.h
//  CRMiOS
//
//  Created by Sy Pauv on 6/20/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Database.h"
#import "Configuration.h"
#import "ValuesCriteria.h"
#import "ConfigLoader.h"
#import "LayoutPageManager.h"
#import "LayoutSectionManager.h"
#import "PropertyManager.h"

@class Configuration;

@interface LayoutFieldManager : NSObject {
    
}
+ (void)initTable;
+ (void)initData;
+ (void)insert:(NSString *)subtype page:(int)page section:(int)section row:(int)row field:(NSString *)field;
+ (void)save:(NSString *)subtype page:(int)page section:(int)section fields:(NSArray *)fields;
+ (NSArray *)read:(NSString *)subtype page:(int)page section:(int)section;
+ (void)apply:(Configuration *)configuration;

@end
