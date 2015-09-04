//
//  Bitset.h
//  SyncForce
//
//  Created by Gaeasys Admin on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
//helper class to decode a "validFor" bitset

#import <Foundation/Foundation.h>

@interface Bitset : NSObject{
    NSArray *data;
}

- (id)init:(NSArray *)pdata;
- (BOOL)testBit:(int) n;
- (int)size;

@end
