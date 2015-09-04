//
//  FieldsManager.h
//  CRMiOS
//
//  Created by Sy Pauv on 5/11/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Database.h"
#import "ValuesCriteria.h"
#import "CRMField.h"



@interface FieldsManager : NSObject {
    
}
+ (void)initTable;
+ (void)initData;
+ (void)insert:(NSDictionary *)fields;
+ (void)purge:(NSString *)entity;
+ (CRMField *)read:(NSString *)entity field:(NSString *)field;
+ (CRMField *)read:(NSString *)entity display:(NSString *)display;
+ (NSDictionary *)list:(NSString *)entity;
+ (NSString *)getSublistCode:(NSString *)entity sublist:(NSString *)sublist;

@end
