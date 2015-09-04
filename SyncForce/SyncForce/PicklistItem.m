//
//  PicklistItem.m
//  SyncForce
//
//  Created by Gaeasys Admin on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PicklistItem.h"

@implementation PicklistItem

@synthesize label,value;

- (id)init:(NSString *)plabel value:(NSString *)pvalue{
    self.label = plabel;
    self.value = pvalue;
    return self;
}

@end