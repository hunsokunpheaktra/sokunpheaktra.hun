//
//  Database.m
//  CRMiPad
//
//  Created by Sy Pauv Phou on 3/30/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "Database.h"

@implementation Database

static Database *_sharedSingleton = nil;

@synthesize database, exists, renaming;

+ (Database *)getInstance
{
	@synchronized([Database class])
	{
		if (!_sharedSingleton)
			[[self alloc] init];
        
		return _sharedSingleton;
	}
    
	return nil;
}

+(id)alloc
{
	@synchronized([Database class])
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
    self.renaming = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObject:@"Primary1"] forKeys:[NSArray arrayWithObject:@"Primary"]];
    return self;
}

- (void)reOpenDatabase{
    sqlite3_close(database);
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString *databasePath = [documentsDir stringByAppendingPathComponent:DATABASE_NAME];
    sqlite3_open([databasePath UTF8String], &database);
}

- (void)initDatabase {
    
	// Get the path to the documents directory and append the databaseName
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	NSString *databasePath = [documentsDir stringByAppendingPathComponent:DATABASE_NAME];


    
	// Create a FileManager object, we will use this to check the status
	// of the database and to copy it over if required
	NSFileManager *fileManager = [NSFileManager defaultManager];
    
	// Check if the database has already been created in the users filesystem
	exists = [fileManager fileExistsAtPath:databasePath];
    
	[fileManager release];
    
	// Open the database from the users filessytem
	if(sqlite3_open([databasePath UTF8String], &database) != SQLITE_OK) {
        NSLog(@"Error opening database");
    }
    
}

- (void)deleteDatabase {

    
    [TestFlight passCheckpoint:@"Delete Database"];
    
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
    
    // delete also the downloaded configuration file
    NSString *overridePath = [documentsDir stringByAppendingPathComponent:@"ipad.xml"];
    if ([fileManager fileExistsAtPath:overridePath]) {
        [fileManager removeItemAtPath:overridePath error:nil];
        [Configuration reload];
    }
    
	[fileManager release];
    
}

- (BOOL)execSql:(NSString *)sql params:(NSArray *)params {
    
    NSLog(@"SQL :%@", [Database setParameters:sql params:params]);
    @synchronized([Database class]) {
        sqlite3_stmt *compiledStatement;
        int result = sqlite3_prepare_v2(database, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &compiledStatement, NULL);
        if (result != SQLITE_OK) {
            NSLog(@"SQL Error : %i %s", result, sqlite3_errmsg(database));
            return NO;
        }   
        if (params != Nil) {
            for (int i = 0; i < [params count]; i++) {
                if ([[params objectAtIndex:i] isKindOfClass:[NSNumber class]]) {
                    sqlite3_bind_int(compiledStatement, i+1, [[params objectAtIndex:i] intValue]);  
                } else if ([[params objectAtIndex:i] isKindOfClass:[NSData class]]) {
                    NSData *data = [params objectAtIndex:i];
                    sqlite3_bind_blob(compiledStatement, i+1, [data bytes], [data length], SQLITE_TRANSIENT);
                } else if ([[params objectAtIndex:i] isKindOfClass:[NSNull class]]) {
                    sqlite3_bind_null(compiledStatement, i+1);
                } else {
                    sqlite3_bind_text(compiledStatement, i+1, [[params objectAtIndex:i] cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);  
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
    NSLog(@"SQL :%@", [Database setParameters:sql params:params]);
    NSMutableArray *list = nil;
    @synchronized([Database class]) {
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
            while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                NSMutableDictionary *record = [[NSMutableDictionary alloc] initWithCapacity:1];
                for (int i = 0; i < sqlite3_column_count(compiledStatement); i++) {
                    NSString *field = [self unrenameField:[fields objectAtIndex:i]];
                    if (sqlite3_column_type(compiledStatement, i) == SQLITE_NULL) {

                    } else if (sqlite3_column_type(compiledStatement, i) == SQLITE_TEXT || sqlite3_column_type(compiledStatement, i) == SQLITE_BLOB) {
                        if ([[fields objectAtIndex:i] isEqualToString:@"Attachment"]) {
                            NSData *zippedData = [NSData dataWithBytes:sqlite3_column_blob(compiledStatement, i) length:sqlite3_column_bytes(compiledStatement, i)];
                            NSData *data = [ZLibTools zlibInflate:zippedData];
                            if (data != nil) {
                                NSString* tmp = [[[NSString alloc] initWithData:data
                                                                          encoding:NSUTF8StringEncoding] autorelease];
                                if (tmp != nil) {
                                    [record setObject:tmp forKey:field];
                                }
                            }
                        } else {
                            NSString *value = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, i)];
                            [record setObject:value forKey:field];
                        }
                    } else {
                        NSString *value = [NSString stringWithFormat:@"%i", sqlite3_column_int(compiledStatement, i)];
                        [record setObject:value forKey:field];
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



- (NSString *)unrenameField:(NSString *)field {
    NSArray *unrenamed = [self.renaming allKeysForObject:field];
    if ([unrenamed count] > 0) {
        return [unrenamed objectAtIndex:0];
    }
    return field;
}

- (NSString *)renameField:(NSString *)field {
    NSString *renamed = [self.renaming objectForKey:field];
    if (renamed != nil) {
        return renamed;
    }
    return field;
}

- (NSArray *)select:(NSString *)table fields:(NSArray *)fields criterias:(NSArray *)criterias order:(NSString *)order ascending:(BOOL)ascending limit:(int)limit {
    NSMutableString *sql = [NSMutableString stringWithString:@"SELECT "];
    BOOL first = YES;
    if (fields == nil) {
        [sql appendString:@"*"];
    } else {
        for (NSString *field in fields) {
            if (first) {
                first = NO;
            } else {
                [sql appendString:@", "];
            }
            [sql appendString:[self renameField:field]];
        }
    }
    [sql appendString:@" FROM "];
    [sql appendString:table];
    [sql appendString:[self getWhere:criterias]];
    if (order != Nil) {
        [sql appendString:@" ORDER BY "];
        [sql appendString:order];
        if (!ascending) {
            [sql appendString:@" DESC"];
        }
    }
    if (limit != 0) {
        [sql appendFormat:@" LIMIT %d", limit];
    }
    NSArray *params = [self getParams:criterias];
    NSArray *ret = [self selectSql:sql params:params fields:fields];
    //[sql release];
    [params release];
    return ret;
}

- (NSArray *)select:(NSString *)table fields:(NSArray *)fields criterias:(NSArray *)criterias order:(NSString *)order ascending:(BOOL)ascending {
    return [self select:table fields:fields criterias:criterias order:order ascending:ascending limit:0];
}

- (NSArray *)select:(NSString *)table fields:(NSArray *)fields column:(NSString *)column value:(NSString *)value order:(NSString *)order ascending:(BOOL)ascending {
    NSMutableArray *criterias = [[NSMutableArray alloc] initWithCapacity:1];
    [criterias addObject:[ValuesCriteria criteriaWithColumn:column value:value]];
    NSArray *result = [self select:table fields:fields criterias:criterias order:order ascending:ascending limit:0];
    [criterias release];
    return result;
}

- (void)insert:(NSString *)table item:(NSDictionary *)item {
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
        [sql appendString:[self renameField:field]];
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
        if ([field isEqualToString:@"Attachment"]) {
            NSData* data = [[item objectForKey:field] dataUsingEncoding:NSUTF8StringEncoding];
            [params addObject:[ZLibTools zlibDeflate:data]];
        } else {
            [params addObject:[item objectForKey:field]];
        }
    }
    [sql appendString:@")"];
    [self execSql:sql params:params];
    //[sql release];
    [params release];
}

- (void)update:(NSString *)table item:(NSDictionary *)item criterias:(NSArray *)criterias {
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
        [sql appendString:[self renameField:field]];
        [sql appendString:@" = ?"];
        if ([field isEqualToString:@"Attachment"]) {
            NSData* data = [[item objectForKey:field] dataUsingEncoding:NSUTF8StringEncoding];
            [params addObject:[ZLibTools zlibDeflate:data]];
        } else {
            [params addObject:[item objectForKey:field]];
        }
    }
    [sql appendString:[self getWhere:criterias]];
    NSArray *whereParams = [self getParams:criterias];
    [params addObjectsFromArray:whereParams];
    [self execSql:sql params:params];
    //[sql release];
    [params release];
    [whereParams release];
}

- (void)update:(NSString *)table item:(NSDictionary *)item column:(NSString *)column value:(NSString *)value {
    NSMutableArray *criterias = [[NSMutableArray alloc] initWithCapacity:1];
    [criterias addObject:[ValuesCriteria criteriaWithColumn:column value:value]];
    [self update:table item:item criterias:criterias];
    [criterias release];
}

- (void)remove:(NSString *)table column:(NSString *)column value:(NSString *)value {
    NSMutableArray *criterias = [[NSMutableArray alloc] initWithCapacity:1];
    [criterias addObject:[ValuesCriteria criteriaWithColumn:column value:value]];
    [self remove:table criterias:criterias];
    [criterias release];
}

- (void)remove:(NSString *)table criterias:(NSArray *)criterias {
    NSMutableString *sql = [NSMutableString stringWithString:@"DELETE FROM "];
    [sql appendString:table];
    [sql appendString:[self getWhere:criterias]];
    NSArray *params = [self getParams:criterias];
    [self execSql:sql params:params];
    [params release];
}

- (void)drop:(NSString *)table {
    NSString *sql = [NSString stringWithFormat:@"DROP TABLE %@", table];
    [[Database getInstance] execSql:sql params:Nil];
}

- (BOOL)check:(NSString *)table columns:(NSArray *)columns types:(NSArray *)types {
    return [self check:table columns:columns types:types dontwant:nil];
}


- (BOOL)check:(NSString *)table columns:(NSArray *)columns types:(NSArray *)types dontwant:(NSArray *)toRemove {
    // check if need to remove some columns
    if (toRemove != nil) {
        BOOL ok = YES;
        for (NSString *colToRemove in toRemove) {
            NSArray *tmp = [NSArray arrayWithObject:colToRemove];
            NSArray *rows2 = [self select:table fields:tmp criterias:nil order:nil ascending:YES limit:1];
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
    NSArray *rows = [self select:table fields:columns criterias:nil order:nil ascending:YES limit:1];
    if (rows == nil) {
        // some rows are missing, find out which ones
        NSMutableArray *missing = [[NSMutableArray alloc] initWithCapacity:1];
        for (int i = 0; i < [columns count]; i++) {
            NSArray *tmp = [NSArray arrayWithObject:[columns objectAtIndex:i]];
            NSArray *rows2 = [self select:table fields:tmp criterias:nil order:nil ascending:YES];
            if (rows2 == nil) {
                [missing addObject:[NSNumber numberWithInt:i]];
            } else {
                [rows2 release];
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
        [sql appendString:[self renameField:[columns objectAtIndex:i]]];
        [sql appendString:@" "];
        [sql appendString:[types objectAtIndex:i]];
    }
    [sql appendString:@")"];
    [[Database getInstance] execSql:sql params:Nil];   
}

- (void)alter:(NSString *)table column:(NSString *)column type:(NSString *)type {
    NSMutableString *sql = [NSMutableString stringWithString:@"ALTER TABLE "];
    [sql appendString:table];
    [sql appendString:@" ADD COLUMN "];
    [sql appendString:[self renameField:column]];
    [sql appendString:@" "];
    [sql appendString:type];
    [[Database getInstance] execSql:sql params:Nil];   
}

- (void)createIndex:(NSString *)table column:(NSString *)column unique:(BOOL)unique {
    NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:1];
    [columns addObject:column];
    [self createIndex:table columns:columns unique:unique];
    [columns release];
}

- (void)createIndex:(NSString *)table columns:(NSArray *)columns unique:(BOOL)unique {
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
        } else {
            [sql appendString:@", "];
        }
        [sql appendString:[self renameField:[columns objectAtIndex:i]]];
    }
    [sql appendString:@")"];
    [[Database getInstance] execSql:sql params:Nil];   
}

- (NSArray *)getParams:(NSArray *)criterias {
    NSMutableArray *params = [[NSMutableArray alloc] initWithCapacity:1];
    for (NSObject <Criteria> *criteria in criterias) {
        NSArray *values = [criteria getValues];
        if (values != Nil && [values count] > 0) {
            [params addObjectsFromArray:values];
        }
    }
    return params;
}

- (NSString *)getWhere:(NSArray *)criterias {
    if (criterias == Nil || [criterias count] == 0) {
        return @"";
    }
    NSMutableString *sql = [NSMutableString stringWithString:@" WHERE "];
    BOOL firstCriteria = YES;
    for (NSObject <Criteria> *criteria in criterias) {
        if (firstCriteria) {
            firstCriteria = NO;
        } else {
            [sql appendString:@" AND "];
        }
        [sql appendString:[criteria getCriteria]];
    }
    return sql;
}

+ (NSString *)setParameters:(NSString *)sql params:(NSArray *)params {
    NSMutableString *ms = [[[NSMutableString alloc] initWithString:sql] autorelease];
    for (NSObject *param in params) {
        NSRange range = [ms rangeOfString:@"?"];
        if (range.location != NSNotFound) {
            if ([param isKindOfClass:[NSString class]]) {
                [ms replaceCharactersInRange:range withString:[NSString stringWithFormat:@"'%@'", param]];
            } else if ([param isKindOfClass:[NSData class]]) {
                [ms replaceCharactersInRange:range withString:[NSString stringWithFormat:@"'%@'", @"[BLOB]"]];
                NSLog(@"BLOB %d", [((NSData *)param) length]);
            } else {
                [ms replaceCharactersInRange:range withString:[NSString stringWithFormat:@"'%@'", @"?"]];
            }
        }
    }
    return ms;
}

@end
