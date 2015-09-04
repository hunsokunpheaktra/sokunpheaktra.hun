//
//  LikeCriteria.h
//
//  Created by Sy Pauv Phou on 6/3/11.
//  Copyright 2011 Gaeasys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Criteria.h"

@interface LikeCriteria : NSObject <Criteria> {
    NSString *value;
}

@property (nonatomic, retain) NSString *value;

- (id)initWithValue:(NSString *)newValue;

@end
