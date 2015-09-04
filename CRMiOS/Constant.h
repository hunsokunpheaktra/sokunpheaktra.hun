//
//  Constant.h
//  CRMiOS
//
//  Created by Arnaud on 1/14/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Formula.h"

@interface Constant : NSObject<Formula> {
    NSString *value;
}

@property (nonatomic, retain) NSString *value;

- (id)initWithValue:(NSString *)pValue;

@end
