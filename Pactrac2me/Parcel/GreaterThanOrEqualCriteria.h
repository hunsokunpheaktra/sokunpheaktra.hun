//
//  GreaterThanOrEqualCriteria.h
//  SyncForce
//
//  Created by Hun Sokunpheaktra on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Criteria.h"

@interface GreaterThanOrEqualCriteria : NSObject<Criteria>{
    NSString *value;
}

- (id)initWithValue:(NSString *)newValue;

@end
