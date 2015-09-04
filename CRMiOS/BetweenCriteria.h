//
//  GreaterThanCriteria.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 10/5/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EvaluateTools.h"
#import "Criteria.h"
#import "BaseCriteria.h"

@interface BetweenCriteria : BaseCriteria <Criteria> {
    NSString *start;
    NSString *end;
}

@property (nonatomic, retain) NSString *start;
@property (nonatomic, retain) NSString *end;

- (id)initWithColumn:(NSString *)column start:(NSString *)newStart end:(NSString *)newEnd;

@end
