//
//  EntityLevel.h
//  RetailForce
//
//  Created by Gaeasys on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EntityLevel : NSObject

+ (void)initTable;
+ (void)save:(NSDictionary *)item;
+ (NSArray*)readEntities;
+ (NSString *)readLevel:(NSString *)entityname;


@end
