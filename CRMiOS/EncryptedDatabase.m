//
//  EncryptedDatabase.m
//  CRMiOS
//
//  Created by Hun Sokunpheaktra on 9/13/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "EncryptedDatabase.h"

@implementation EncryptedDatabase

+ (BOOL)canQuery:(sqlite3*)db{
    
    return sqlite3_exec(db, (const char*) "SELECT count(*) FROM sqlite_master;", NULL, NULL, NULL) == SQLITE_OK;
    
}
+ (void)executeEncrypt:(sqlite3*)db encryptKey:(NSString*)key{
    
    sqlite3_exec(db, [[NSString stringWithFormat:@"PRAGMA key = '%@';" , key] UTF8String], NULL, NULL, NULL);
    
}
+ (BOOL)executeOpen:(sqlite3*)db openKey:(NSString*)key{
    
    sqlite3_exec(db, [[NSString stringWithFormat:@"PRAGMA key = '%@';" , key] UTF8String], NULL, NULL, NULL);
    
    return [self canQuery:db];
}

@end
