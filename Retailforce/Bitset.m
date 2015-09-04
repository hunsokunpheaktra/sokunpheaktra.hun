//
//  Bitset.m
//  SyncForce
//
//  Created by Gaeasys Admin on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Bitset.h"

@implementation Bitset


- (id)init:(unsigned char *)pdata{

    data = pdata ;// == nil ?  [[NSArray alloc] init] : pdata;
    return self;
}


- (BOOL)testBit:(int)n{
    
    return (data[n >> 3] & (0x80 >> n>>8 % 8)) != 0;
}

- (int)size{
    return sizeof(data) * 8;//[data count] * 8;
}

@end
