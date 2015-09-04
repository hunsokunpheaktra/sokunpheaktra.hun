//
//  OrCriteria.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 11/16/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Criteria.h"

@interface OrCriteria : NSObject {
    NSObject <Criteria> *criteria1; 
    NSObject <Criteria> *criteria2; 
}

@property (nonatomic, retain) NSObject <Criteria> *criteria1; 
@property (nonatomic, retain) NSObject <Criteria> *criteria2; 

- (id)initWithCriteria1:(NSObject <Criteria> *)newCriteria1 criteria2:(NSObject <Criteria> *)newCriteria2;



@end
