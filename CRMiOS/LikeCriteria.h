//
//  LikeCriteria.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 6/3/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Criteria.h"
#import "BaseCriteria.h"

@interface LikeCriteria : BaseCriteria <Criteria> {
    NSString *value;
}

@property (nonatomic, retain) NSString *value;

- (id)initWithColumn:(NSString *)column value:(NSString *)newValue;

@end
