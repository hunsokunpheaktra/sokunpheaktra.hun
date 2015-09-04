//
//  ValuesCriteria.h
//
//  Created by Sy Pauv Phou on 6/3/11.
//  Copyright 2011 Gaeasys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Criteria.h"


@interface ValuesCriteria : NSObject <Criteria> {
    NSArray *values;
}

@property (nonatomic, retain) NSArray *values;

- (id)initWithValues:(NSArray *)newValues;
- (id)initWithString:(NSString *)value;

+ (ValuesCriteria *)criteriaWithString:(NSString *)value;
+ (ValuesCriteria *)criteriaWithInt:(int)value;

@end
