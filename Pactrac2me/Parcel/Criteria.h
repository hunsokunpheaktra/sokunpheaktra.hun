//
//  Criteria.h
//
//  Created by Sy Pauv Phou on 6/3/11.
//  Copyright 2011 Gaeasys. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol Criteria <NSObject>

- (NSString *) getCriteria;
- (NSArray *) getValues;

@end
