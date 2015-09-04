//
//  SFRestApiRequest.h
//  kba
//
//  Created by Sy Pauv on 10/3/11.
//  Copyright 2011 GAEASYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@protocol SFRequest

- (void)doRequest;
- (NSString *)getName;
- (void)setTask:(NSNumber *)taskNum;
- (NSNumber *)getTasknum;
- (NSString *)getEntity;
- (Item*) getCurrentitem;
- (BOOL)prepare;


@end
