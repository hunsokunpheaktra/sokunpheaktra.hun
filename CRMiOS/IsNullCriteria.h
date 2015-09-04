//
//  IsNullCriteria.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 6/3/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Criteria.h"
#import "BaseCriteria.h"

@interface IsNullCriteria : BaseCriteria <Criteria> {
    
}

- (id)initWithColumn:(NSString *)column;


@end
