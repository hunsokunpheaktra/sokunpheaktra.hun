//
//  DatabaseManager.m
//  kba
//
//  Created by Sy Pauv on 10/1/11.
//  Copyright 2011 GAEASYS. All rights reserved.
//

#import "DatabaseManager.h"
#import "DatabaseManager.h"
#import "EntityManager.h"
#import "PropertyManager.h"
#import "LogManager.h"
#import "FieldInfoManager.h"
#import "EntityInfoManager.h"
#import "TransactionInfoManager.h"
#import "EditLayoutSectionsInfoManager.h"
#import "DetailLayoutSectionsInfoManager.h"
#import "PicklistInfoManager.h"
#import "RecordTypeMappingInfoManager.h"
#import "PicklistForRecordTypeInfoManager.h"
#import "RelatedListsInfoManager.h"
#import "RelatedListColumnInfoManager.h"
#import "RelatedListSortInfoManager.h"
#import "ChildRelationshipInfoManager.h"
#import "FilterManager.h"
#import "DirectoryHelper.h"
#import "InfoFactory.h"
#import "FilterFieldManager.h"
#import "FilterObjectManager.h"
#import "KeyFieldInfoManager.h"

@implementation DatabaseManager


static DatabaseManager *_sharedSingleton = nil;

@synthesize database,exists;

+ (DatabaseManager *)getInstance
{
	@synchronized([DatabaseManager class])
	{
		if (!_sharedSingleton)
			[[self alloc] init];
        
		return _sharedSingleton;
	}
    
	return nil;
}

+(id)alloc
{
	@synchronized([DatabaseManager class])
	{
		NSAssert(_sharedSingleton == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedSingleton = [super alloc];
		return _sharedSingleton;
	}
    
	return nil;
}

- (void) dealloc
{
    if (database != NULL) {
        sqlite3_close(database);
    }
    [super dealloc];
}

- (id)init {
    self = [super init];
    
    return self;
}

- (void)reOpenDatabase{
    sqlite3_close(database);
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString *databasePath = [documentsDir stringByAppendingPathComponent:DATABASE_NAME];
    sqlite3_open([databasePath UTF8String], &database);
}

- (void)initDatabase{
    
	// Get the path to the documents directory and append the databaseName
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	NSString *databasePath = [documentsDir stringByAppendingPathComponent:DATABASE_NAME];
    
    
	// Create a FileManager object, we will use this to check the status
	// of the database and to copy it over if required
	NSFileManager *fileManager = [NSFileManager defaultManager];
    
	// Check if the database has already been created in the users filesystem
	exists = [fileManager fileExistsAtPath:databasePath];
    
    // AM
    // Don't understand what this stuff is all about, I comment it for now
    //    
    //	// Does the database exists ?
    //	if (!exists) {
    //        // If not then proceed to copy the database from the application to the users filesystem
    //        
    //        // Get the path to the database in the application package
    //        NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DATABASE_NAME];
    //        
    //        // Copy the database from the package to the users filesystem
    //        [fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
    //        
    //        //ask user to encrypt database or not
    //        //status = @"fileNotExist";
    //        
    //    }
	[fileManager release];
    
	// Open the database from the users filessytem
	if(sqlite3_open([databasePath UTF8String], &database) != SQLITE_OK) {
        NSLog(@"Error opening database");
    }
    
}

- (void)reInitDB {
    
    // Get the path to the documents directory and append the databaseName
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	NSString *databasePath = [documentsDir stringByAppendingPathComponent:DATABASE_NAME];
	// Create a FileManager object, we will use this to check the status
	// of the database and to copy it over if required
	NSFileManager *fileManager = [NSFileManager defaultManager];
    
	// Check if the database has already been created in the users filesystem
	exists = [fileManager fileExistsAtPath:databasePath];
    
    if (exists) {
        [fileManager removeItemAtPath:databasePath error:nil];
    }
    
    [[DatabaseManager getInstance] initDatabase];
    [FieldInfoManager initTable];
    [FilterManager initTable];
    [FilterObjectManager initTable];
    [PicklistInfoManager initTable];
    [EntityInfoManager initTable];
    [EditLayoutSectionsInfoManager initTable];
    [DetailLayoutSectionsInfoManager initTable];
    [RecordTypeMappingInfoManager initTable];
    [PicklistForRecordTypeInfoManager initTable];
    [RelatedListsInfoManager initTable];
    [RelatedListColumnInfoManager initTable];
    [RelatedListSortInfoManager initTable];
    [ChildRelationshipInfoManager initTable];
    [PropertyManager initTable];
    [PropertyManager initDatas];
    [LogManager initTable];
    [InfoFactory clearInfo];
    [TransactionInfoManager initTable];
    [FilterFieldManager initTable];
    [KeyFieldInfoManager initTable];
    [DirectoryHelper initLibraryDirectory];
       
}

- (BOOL)execSql:(NSString *)sql params:(NSArray *)params {
    
    //NSLog(@"SQL :[%@]", [DatabaseManager setParameters:sql params:params]);

    @synchronized([DatabaseManager class]) {
        sqlite3_stmt *compiledStatement;
        int result = sqlite3_prepare_v2(database, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &compiledStatement, NULL);
        if (result != SQLITE_OK) {
            NSLog(@"SQL Error : %i %s", result, sqlite3_errmsg(database));
            return NO;
        }   
        if (params != Nil) {
            for (int i = 0; i < [params count]; i++) {
                if ([[params objectAtIndex:i] isKindOfClass:[NSNumber class]]) {
                    sqlite3_bind_double(compiledStatement, i+1, [[params objectAtIndex:i] doubleValue]);  
                } else 
                if ([[params objectAtIndex:i] isKindOfClass:[NSNull class]]) {
                    sqlite3_bind_null(compiledStatement, i+1);
                } else {
                    //NSLog(@"Params : [ %@ ]",[params objectAtIndex:i]);
                    NSString *stringparam = nil;
                    if([[params objectAtIndex:i] isKindOfClass:[NSString class]]){
                        stringparam = [params objectAtIndex:i] ;
                    }
                    sqlite3_bind_text(compiledStatement, i+1, [stringparam cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);  
                }
                
            }
        }
        result = sqlite3_step(compiledStatement);
        if (result != SQLITE_DONE) {
            NSLog(@"SQL Error : %i %s", result, sqlite3_errmsg(database));
            return NO;
        }
        sqlite3_finalize(compiledStatement); 
    }
    return YES;
}




- (NSArray *)selectSql:(NSString *)sql params:(NSArray *)params fields:(NSArray *)fields {
    NSLog(@"SQL :%@", [DatabaseManager setParameters:sql params:params]);
    
    NSMutableArray *list = nil;
    @synchronized([DatabaseManager class]) {
        sqlite3_stmt *compiledStatement;
        int result = sqlite3_prepare_v2(database, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &compiledStatement, NULL);
        if (params != Nil) {
            for (int i = 0; i < [params count]; i++) {
                sqlite3_bind_text(compiledStatement, i+1, [[params objectAtIndex:i] cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
            }
        }
        if (result == SQLITE_OK) {
            list = [[NSMutableArray alloc] initWithCapacity:1];
            // Loop through the results and add them to the feeds array
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                NSMutableDictionary *record = [[NSMutableDictionary alloc] initWithCapacity:1];
                for (int i = 0; i < sqlite3_column_count(compiledStatement); i++) {
                    if (sqlite3_column_type(compiledStatement, i) == SQLITE_NULL) {
                        
                    } else if (sqlite3_column_type(compiledStatement, i) == SQLITE_TEXT) {   
                        
                        NSString *value = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, i)];
                        [record setObject:value forKey:[fields objectAtIndex:i]];
                        
                    } else {
                        NSString *value = [NSString stringWithFormat:@"%i", sqlite3_column_int(compiledStatement, i)];
                        [record setObject:value forKey:[fields objectAtIndex:i]];

                    }
                }
               
                
                [list addObject:record];
                [record release];
            }
        } else {
            NSLog(@"SQL Error : %i %s", result, sqlite3_errmsg(database));
            list = Nil;
        }
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
    }
    
    
    return list;
}

- (NSArray *)select:(NSString *)table fields:(NSArray *)fields criterias:(NSDictionary *)criterias order:(NSString *)order ascending:(BOOL)ascending {
    
     if ([table isEqualToString:@"Case"]) table = @"Cases";
    
    NSMutableString *sql = [NSMutableString stringWithString:@"SELECT "];
    BOOL first = YES;
    if (fields == Nil) {
        [sql appendString:@"*"];
    } else {
        
        for (NSString *field in fields) {
            if (first) {
                first = NO;
            } else {
                [sql appendString:@", "];
            }
            [sql appendString:field];
        }
    }
    [sql appendString:@" FROM "];
    [sql appendString:table];
    
    [sql appendString:[self getWhere:criterias]];
    if (order != Nil) {
        [sql appendString:@" ORDER BY "];
        [sql appendString:order];
        if (ascending == NO) {
            [sql appendString:@" DESC"];
        }
    }

    
    NSArray *params = [self getParams:criterias];
    NSArray *ret = [self selectSql:sql params:params fields:fields];
    //[sql release];
    [params release];
    
    return ret;
}

- (NSArray *)select:(NSString *)table fields:(NSArray *)fields column:(NSString *)column value:(NSString *)value order:(NSString *)order ascending:(BOOL)ascending {
    
     if ([table isEqualToString:@"Case"]) table = @"Cases";
    
    NSMutableDictionary *criterias = [[NSMutableDictionary alloc] initWithCapacity:1];
    [criterias setValue:[ValuesCriteria criteriaWithString:value] forKey:column];
    NSArray *result = [self select:table fields:fields criterias:criterias order:order ascending:ascending];
    [criterias release];
    return result;
}

- (void)insert:(NSString *)table item:(NSDictionary *)item {
    
     if ([table isEqualToString:@"Case"]) table = @"Cases";

    NSMutableString *sql = [NSMutableString stringWithString:@"INSERT INTO "];
    [sql appendString:table];
    [sql appendString:@"("];
    BOOL first = YES;
    
    for (NSString *field in [item keyEnumerator]) {
        if (first) {
            first = NO;
        } else {
            [sql appendString:@", "];
        }
        [sql appendString:field];
    }
    [sql appendString:@") VALUES ("];
    first = YES;
    NSMutableArray *params = [[NSMutableArray alloc] initWithCapacity:1];
    for (NSString *field in [item keyEnumerator]) {
        if (first) {
            first = NO;
        } else {
            [sql appendString:@", "];
        }
        [sql appendString:@"?"];
        [params addObject:[item objectForKey:field]];
    }
    [sql appendString:@")"];
    
    [self execSql:sql params:params];
    //[sql release];
    [params release];
}

- (void)update:(NSString *)table item:(NSDictionary *)item criterias:(NSDictionary *)criterias {
    
     if ([table isEqualToString:@"Case"]) table = @"Cases";
    
    NSMutableString *sql = [NSMutableString stringWithString:@"UPDATE "];
    [sql appendString:table];
    [sql appendString:@" SET "];
    BOOL first = YES;
    NSMutableArray *params = [[NSMutableArray alloc] initWithCapacity:1];
    for (NSString *field in [item keyEnumerator]) {
        if (first) {
            first = NO;
        } else {
            [sql appendString:@", "];
        }
        [sql appendString: field ];
        [sql appendString:@" = ?"];
        [params addObject:[item objectForKey:field]];
    }
    [sql appendString:[self getWhere:criterias]];
    NSArray *whereParams = [self getParams:criterias];
    [params addObjectsFromArray:whereParams];
    
   // NSLog(@"SQL update : %@", sql);
    
    [self execSql:sql params:params];
    //[sql release];
    [params release];
    [whereParams release];
}

- (void)update:(NSString *)table item:(NSDictionary *)item column:(NSString *)column value:(NSString *)value {
    
     if ([table isEqualToString:@"Case"]) table = @"Cases";
    
    NSMutableDictionary *criterias = [[NSMutableDictionary alloc] initWithCapacity:1];
    [criterias setValue:[ValuesCriteria criteriaWithString:value] forKey:column];
    [self update:table item:item criterias:criterias];
    [criterias release];
}

- (void)remove:(NSString *)table column:(NSString *)column value:(NSString *)value {
    NSMutableDictionary *criterias = [[NSMutableDictionary alloc] initWithCapacity:1];
    [criterias setValue:[ValuesCriteria criteriaWithString:value] forKey:column];
    [self remove:table criterias:criterias];
    [criterias release];
}

- (void)remove:(NSString *)table criterias:(NSDictionary *)criterias {
    
     if ([table isEqualToString:@"Case"]) table = @"Cases";
    
    NSMutableString *sql = [NSMutableString stringWithString:@"DELETE FROM "];
    [sql appendString:table];
    [sql appendString:[self getWhere:criterias]];
    NSArray *params = [self getParams:criterias];
    [self execSql:sql params:params];
    [params release];
}

- (void)drop:(NSString *)table {
    NSString *sql = [NSString stringWithFormat:@"DROP TABLE %@", table];
    [[DatabaseManager getInstance] execSql:sql params:Nil];
}

- (BOOL)check:(NSString *)table columns:(NSArray *)columns types:(NSArray *)types {
    
     if ([table isEqualToString:@"Case"]) table = @"Cases";
    
    return [self check:table columns:columns types:types dontwant:nil];
}


- (BOOL)check:(NSString *)table columns:(NSArray *)columns types:(NSArray *)types dontwant:(NSArray *)toRemove {
    
     if ([table isEqualToString:@"Case"]) table = @"Cases";
    
    // check if need to remove some columns
    if (toRemove != nil) {
        BOOL ok = YES;
        for (NSString *colToRemove in toRemove) {
            NSArray *tmp = [NSArray arrayWithObject:colToRemove];
            NSArray *rows2 = [self select:table fields:tmp criterias:Nil order:Nil ascending:YES];
            if (rows2 != nil) {
                ok = NO;
                break;
            }
        }
        if (!ok) {
            [self drop:table];
            [self create:table columns:columns types:types];
            return NO;
        }
    }
    // check if all rows are here
    NSArray *rows = [self select:table fields:columns criterias:Nil order:Nil ascending:YES];
    if (rows == Nil) {
        // some rows are missing, find out which ones
        NSMutableArray *missing = [[NSMutableArray alloc] initWithCapacity:1];
        for (int i = 0; i < [columns count]; i++) {
            NSArray *tmp = [NSArray arrayWithObject:[columns objectAtIndex:i]];
            NSArray *rows2 = [self select:table fields:tmp criterias:Nil order:Nil ascending:YES];
            if (rows2 == nil) {
                [missing addObject:[NSNumber numberWithInt:i]];
            } else {
                [rows release];
            }
        }
        if ([missing count] == [columns count]) {
            [self drop:table];
            [self create:table columns:columns types:types];
            return NO;
        } else {
            for (NSNumber *column in missing) {
                int i = [column intValue];
                [self alter:table column:[columns objectAtIndex:i] type:[types objectAtIndex:i]];
            }
            return NO;
        }
    } else {
        [rows release];
    }
    return YES;
}

- (void)create:(NSString *)table columns:(NSArray *)columns types:(NSArray *)types {
    
    if ([table isEqualToString:@"Case"]) table = @"Cases";
        
    
    NSMutableString *sql = [NSMutableString stringWithString:@"CREATE TABLE IF NOT EXISTS "];
    [sql appendString:table];
    [sql appendString:@"("];
    BOOL first = YES;
    for (int i = 0; i < [columns count]; i++) {
        if (first) {
            first = NO;
        } else {
            [sql appendString:@", "];
        }
        [sql appendString:[columns objectAtIndex:i]];
        [sql appendString:@" "];
        [sql appendString:[types objectAtIndex:i]];
    }
    [sql appendString:@")"];
    [[DatabaseManager getInstance] execSql:sql params:Nil];   
}

- (void)alter:(NSString *)table column:(NSString *)column type:(NSString *)type {
    
    if ([table isEqualToString:@"Case"]) table = @"Cases";
    
    NSMutableString *sql = [NSMutableString stringWithString:@"ALTER TABLE "];
    [sql appendString:table];
    [sql appendString:@" ADD COLUMN "];
    [sql appendString:column];
    [sql appendString:@" "];
    [sql appendString:type];
    [[DatabaseManager getInstance] execSql:sql params:Nil];   
}

- (void)createIndex:(NSString *)table column:(NSString *)column unique:(BOOL)unique {
    
    if ([table isEqualToString:@"Case"]) table = @"Cases";
    
    NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
    [columns addObject:column];
    [self createIndex:table columns:columns unique:unique];
    [columns release];
}

- (void)createIndex:(NSString *)table columns:(NSArray *)columns unique:(BOOL)unique {
    
    if ([table isEqualToString:@"Case"]) table = @"Cases";
    
    NSMutableString *sql = [NSMutableString stringWithString:@"CREATE "];
    if (unique) {
        [sql appendString:@"UNIQUE "];
    }
    [sql appendString:@"INDEX IF NOT EXISTS "];
    [sql appendString:table];
    for (NSString *column in columns) {
        [sql appendString:@"_"];
        [sql appendString:column];
    }
    [sql appendString:@" ON "];
    [sql appendString:table];
    [sql appendString:@"("];
    BOOL first = YES;
    for (int i = 0; i < [columns count]; i++) {
        if (first) {
            first = NO;
        }else {
            [sql appendString:@", "];
        }
        [sql appendString:[columns objectAtIndex:i]];
    }
    [sql appendString:@")"];
    NSLog(@"Create Table %@",sql);
    [[DatabaseManager getInstance] execSql:sql params:Nil];   
}

- (NSArray *)getParams:(NSDictionary *)criterias {
    NSMutableArray *params = [[NSMutableArray alloc] initWithCapacity:1];
    NSArray *sortedColumns = [[[criterias keyEnumerator] allObjects] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *column in sortedColumns) {
        
        NSObject <Criteria> *criteria = [criterias objectForKey:column];
        NSArray *values = [criteria getValues];
        if (values != Nil && [values count] > 0) {
            [params addObjectsFromArray:values];
        }
    }
    return params;
}

- (NSString *)getWhere:(NSDictionary *)criterias {
    if (criterias == Nil || [criterias count] == 0) {
        return @"";
    }
    NSMutableString *sql = [NSMutableString stringWithString:@" WHERE "];
    BOOL firstCriteria = YES;
    NSArray *sortedColumns = [[[criterias keyEnumerator] allObjects] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *column in sortedColumns) {
        if (firstCriteria) {
            firstCriteria = NO;
        } else {
            [sql appendString:@" AND "];
        }
        [sql appendString:column];
        [sql appendString:@" "];
        NSObject <Criteria> *criteria = [criterias objectForKey:column];
        [sql appendString:[criteria getCriteria]];
    }
    return sql;
}

- (BOOL)checkTable:(NSString*)tableName{
    
    if ([tableName isEqualToString:@"Case"]) tableName = @"Cases";
    
    sqlite3_stmt *statementChk;
    NSString *sql = [NSString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type='table' AND name='%@';",tableName];
    sqlite3_prepare_v2(database, [sql UTF8String], -1, &statementChk, nil);
    
    BOOL boo = NO;
    
    if (sqlite3_step(statementChk) == SQLITE_ROW) {
        boo = YES;
    }
    sqlite3_finalize(statementChk);
    return boo;
}

+ (NSString *)setParameters:(NSString *)sql params:(NSArray*)params {
    NSMutableString *ms = [[[NSMutableString alloc] initWithString:sql] autorelease];
    for (NSString *param in params) {
        //NSLog(@" Execute Param : [%@]",param);
        NSRange range = [ms rangeOfString:@"?"];
        if (range.location != NSNotFound) {
            [ms replaceCharactersInRange:range withString:[NSString stringWithFormat:@"'%@'", param]];
        }
    }
    return ms;
}


@end
