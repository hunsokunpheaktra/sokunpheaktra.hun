//
//  DatabaseManager.h
//
//  Created by Sy Pauv on 10/1/11.
//  Copyright 2011 GAEASYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Criteria.h"
#import "ValuesCriteria.h"



#define DATABASE_NAME @"RetailForceDB.db"

@interface DatabaseManager : NSObject {
	sqlite3 *database;
    BOOL exists;
    
}

@property (nonatomic,readwrite)sqlite3 *database;
@property (nonatomic,readwrite)BOOL exists;

+ (DatabaseManager *)getInstance;

- (void)initDatabase;
- (void)reInitDB;
- (void)reOpenDatabase;
- (BOOL)execSql:(NSString *)sql params:(NSArray *)params;
- (NSArray *)select:(NSString *)table fields:(NSArray *)fields criterias:(NSDictionary *)criterias order:(NSString *)order ascending:(BOOL)ascending;
- (NSArray *)select:(NSString *)table fields:(NSArray *)fields column:(NSString *)column value:(NSString *)value order:(NSString *)order ascending:(BOOL)ascending;
- (NSArray *)selectSql:(NSString *)sql params:(NSArray *)params fields:(NSArray *)fields;
- (void)insert:(NSString *)table item:(NSDictionary *)item;
- (void)update:(NSString *)table item:(NSDictionary *)item criterias:(NSDictionary *)criterias;
- (void)update:(NSString *)table item:(NSDictionary *)item column:(NSString *)column value:(NSString *)value;
- (void)remove:(NSString *)table criterias:(NSDictionary *)criterias;
- (void)remove:(NSString *)table column:(NSString *)column value:(NSString *)value;
- (void)drop:(NSString *)table;
- (BOOL)check:(NSString *)table columns:(NSArray *)columns types:(NSArray *)types;
- (BOOL)check:(NSString *)table columns:(NSArray *)columns types:(NSArray *)types dontwant:(NSArray *)toremove;
- (void)create:(NSString *)table columns:(NSArray *)columns types:(NSArray *)types;
- (void)alter:(NSString *)table column:(NSString *)column type:(NSString *)type;
- (void)createIndex:(NSString*)table columns:(NSArray *)columns unique:(BOOL)unique;
- (void)createIndex:(NSString*)table column:(NSString *)column unique:(BOOL)unique;
- (NSString *)getWhere:(NSDictionary *)criterias;
- (NSArray *)getParams:(NSDictionary *)criterias;
- (BOOL)checkTable:(NSString*)tableName;
+ (NSString *)setParameters:(NSString *)sql params:(NSArray*)params;


@end
