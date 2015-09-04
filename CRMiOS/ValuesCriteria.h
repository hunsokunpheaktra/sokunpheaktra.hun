//
//  ValuesCriteria.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 6/3/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Criteria.h"
#import "BaseCriteria.h"

@interface ValuesCriteria : BaseCriteria <Criteria> {
    NSArray *values;
}

@property (nonatomic, retain) NSArray *values;

- (id)initWithColumn:(NSString *)column values:(NSArray *)newValues;
- (id)initWithColumn:(NSString *)column value:(NSString *)value;

+ (ValuesCriteria *)criteriaWithColumn:(NSString *)column value:(NSString *)value;
+ (ValuesCriteria *)criteriaWithColumn:(NSString *)column integer:(int)value;

@end
