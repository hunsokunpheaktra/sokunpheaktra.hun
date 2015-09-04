//
//  Function.h
//  CRMiOS
//
//  Created by Arnaud on 1/14/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Formula.h"
#import "EntityManager.h"

@interface Function : NSObject<Formula> {
    NSString *name;
    NSMutableArray *parameters;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSMutableArray *parameters;

- (id)initWithName:(NSString *)pName;
- (id)initWithName:(NSString *)pName param:(NSObject<Formula> *)parameter;

@end
