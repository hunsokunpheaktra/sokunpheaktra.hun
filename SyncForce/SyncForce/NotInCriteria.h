//
//  NotInCriteria.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 10/5/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Criteria.h"

@interface NotInCriteria : NSObject <Criteria> {
    NSArray *values; 
}

@property (nonatomic, retain) NSArray *values;

- (id)initWithValue:(NSString *)newValue;

@end
