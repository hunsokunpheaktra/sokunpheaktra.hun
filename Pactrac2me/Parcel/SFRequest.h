//
//  SFRequest.h
//  Parcel
//
//  Created by Gaeasys on 12/27/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SFRequest

- (void)doRequest;
- (NSString *)getName;
- (NSString *)getEntity;
- (BOOL)prepare;

@end
