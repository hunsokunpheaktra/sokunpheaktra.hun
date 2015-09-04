//
//  LayoutSectionManager.h
//  CRMiOS
//
//  Created by Sy Pauv on 6/20/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Database.h"
#import "Configuration.h"
#import "Section.h"

@interface LayoutSectionManager : NSObject {
    
}
+ (void)initTable;
+ (void)initData;
+ (void)save:(NSString *)subtype page:(int)page section:(int)section name:(NSString *)name isGrouping:(BOOL)isgrouping;
+ (NSArray *)read:(NSString *)subtype page:(int)page;
@end
