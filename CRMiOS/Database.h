//
//  Database.h
//  CRMiPad
//
//  Created by Sy Pauv Phou on 3/30/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Criteria.h"
#import "ValuesCriteria.h"
#import "DBTools.h"
#import "TestFlight.h"
#import "ZLibTools.h"

#define DATABASE_NAME @"CRM.db"

@interface Database : NSObject {
	sqlite3 *database;
    BOOL exists;
    NSDictionary *renaming;
    
}

@property (nonatomic, readwrite) sqlite3 *database;
@property (nonatomic, readwrite) BOOL exists;
@property (nonatomic, retain) NSDictionary *renaming;

+ (Database *)getInstance;

- (void)initDatabase;
- (void)deleteDatabase;
- (void)reOpenDatabase;
- (BOOL)execSql:(NSString *)sql params:(NSArray *)params;
- (NSArray *)select:(NSString *)table fields:(NSArray *)fields criterias:(NSArray *)criterias order:(NSString *)order ascending:(BOOL)ascending;
- (NSArray *)select:(NSString *)table fields:(NSArray *)fields criterias:(NSArray *)criterias order:(NSString *)order ascending:(BOOL)ascending limit:(int)limit;
- (NSArray *)select:(NSString *)table fields:(NSArray *)fields column:(NSString *)column value:(NSString *)value order:(NSString *)order ascending:(BOOL)ascending;
- (NSArray *)selectSql:(NSString *)sql params:(NSArray *)params fields:(NSArray *)fields;
- (void)insert:(NSString *)table item:(NSDictionary *)item;
- (void)update:(NSString *)table item:(NSDictionary *)item criterias:(NSArray *)criterias;
- (void)update:(NSString *)table item:(NSDictionary *)item column:(NSString *)column value:(NSString *)value;
- (void)remove:(NSString *)table criterias:(NSArray *)criterias;
- (void)remove:(NSString *)table column:(NSString *)column value:(NSString *)value;
- (void)drop:(NSString *)table;
- (BOOL)check:(NSString *)table columns:(NSArray *)columns types:(NSArray *)types;
- (BOOL)check:(NSString *)table columns:(NSArray *)columns types:(NSArray *)types dontwant:(NSArray *)toremove;
- (void)create:(NSString *)table columns:(NSArray *)columns types:(NSArray *)types;
- (void)alter:(NSString *)table column:(NSString *)column type:(NSString *)type;
- (void)createIndex:(NSString*)table columns:(NSArray *)columns unique:(BOOL)unique;
- (void)createIndex:(NSString*)table column:(NSString *)column unique:(BOOL)unique;
- (NSString *)getWhere:(NSArray *)criterias;
- (NSArray *)getParams:(NSArray *)criterias;
+ (NSString *)setParameters:(NSString *)sql params:(NSArray *)params;

@end
