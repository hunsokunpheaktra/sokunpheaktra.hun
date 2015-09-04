//
//  Configuration.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 6/24/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfigLoader.h"
#import "EntityInfo.h"
#import "Subtype.h"
#import "ConfigSubtype.h"
#import "ConfigEntity.h"
#import "ConfigSublist.h"
#import "Base64.h"

@class ConfigSublist;

@interface Configuration : NSObject {
    NSMutableDictionary *properties;
    NSMutableArray *entities;
    NSMutableArray *subtypes;
    NSNumber *level;
    NSString *version;
    NSNumber *licensed;
}


@property (nonatomic, retain) NSMutableDictionary *properties;
@property (nonatomic, retain) NSMutableArray *subtypes;
@property (nonatomic, retain) NSMutableArray *entities;
@property (nonatomic, retain) NSNumber *level;
@property (nonatomic, retain) NSString *version;
@property (nonatomic, retain) NSNumber *licensed;

+ (Configuration *)getInstance;
+ (void)reload;
+ (NSObject <EntityInfo> *)getInfo:(NSString *)entity;
+ (NSObject <Subtype> *)getSubtypeInfo:(NSString *)subtype entity:(NSString *)entity;
+ (NSObject <Subtype> *)getSubtypeInfo:(NSString *)subtype;
+ (NSArray *)getEntities;
+ (NSString *)getSubtype:(Item *)item;
+ (BOOL)isYes:(NSString *)property;
+ (NSData *)companyLogo;
+ (NSString *)getProperty:(NSString *)property;
+ (void)writeLicense:(NSString *)lic;
+ (BOOL)isLicensed;

@end
