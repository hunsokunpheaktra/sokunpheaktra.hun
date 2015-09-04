//
//  CustomRecordTypeManager.h
//  CRMiOS
//
//  Created by Sy Pauv on 6/14/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Database.h"
#import "ValuesCriteria.h"

@interface CustomRecordTypeManager : NSObject {   
}

+ (void)initTable;
+ (void)initData;
+ (NSString *)read:(NSString *)entity languageCode:(NSString *)languageCode plural:(BOOL)plural;
+ (void)insert:(NSDictionary *)record;

@end
