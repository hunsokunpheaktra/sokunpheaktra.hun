//
//  Bitset.m
//  SyncForce
//
//  Created by Gaeasys Admin on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Bitset.h"

@implementation Bitset


- (id)init:(NSArray *)pdata{
    data = pdata == nil ?  [[NSArray alloc] init] : pdata;
    return self;
}

- (BOOL)testBit:(int)n{
    NSInteger index = n >> 3;
    char coder1 = (char)[data objectAtIndex: index];
    char coder2 =  (0x80 >> n % 8) ;
    return (coder1 & coder2) != 0;
}

- (int)size{
    return [data count] * 8;
}

@end
