//
//  FilterManager.h
//  CRMiPad
//
//  Created by Sy Pauv Phou on 3/31/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Configuration.h"
#import "BetweenCriteria.h"
#import "NotInCriteria.h"
#import "IsNotNullCriteria.h"

@interface FilterManager : NSObject {
    
}

+ (NSString *)getFilter:(NSString *)subtype;
+ (void)setFilter:(NSString *)subtype code:(NSString *)code;
+ (NSArray *)getCriterias:(NSString *)subtype;

@end
