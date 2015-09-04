//
//  EncryptedDatabase.h
//  CRMiOS
//
//  Created by Hun Sokunpheaktra on 9/13/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface EncryptedDatabase : NSObject {
    
}

+ (BOOL)canQuery:(sqlite3*)db;
+ (void)executeEncrypt:(sqlite3*)db encryptKey:(NSString*)key;
+ (BOOL)executeOpen:(sqlite3*)db openKey:(NSString*)key;

@end
