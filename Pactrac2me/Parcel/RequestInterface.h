//
//  RequestInterface.h
//  Parcel
//
//  Created by Gaeasys on 12/26/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RequestInterface

- (void)onSuccess:(id)req;
- (void)onFailure:(NSString *)errorMessage request:(id)req;

@end
