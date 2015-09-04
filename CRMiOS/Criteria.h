//
//  Criteria.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 6/3/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol Criteria <NSObject>

- (NSString *) column;
- (NSString *) getCriteria;
- (NSArray *) getValues;

@end
