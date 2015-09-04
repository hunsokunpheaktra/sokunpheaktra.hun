//
//  Constant.m
//  CRMiOS
//
//  Created by Arnaud on 1/14/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import "Constant.h"

@implementation Constant

@synthesize value;

- (id)initWithValue:(NSString *)pValue {
    self = [super init];
    self.value = pValue;
    return self;
}

- (NSString *)evaluateWithItem:(Item *)item {
    return value;
}

@end
