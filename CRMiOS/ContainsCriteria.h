//
//  ContainsCriteria.h
//  CRMiOS
//
//  Created by Arnaud Marguerat on 8/21/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Criteria.h"
#import "BaseCriteria.h"

@interface ContainsCriteria : BaseCriteria <Criteria> {
    NSString *value;
}

@property (nonatomic, retain) NSString *value;

- (id)initWithColumn:(NSString *)column value:(NSString *)newValue;

@end
