//
//  SFRestApiListener.h
//  kba
//
//  Created by Sy Pauv on 10/3/11.
//  Copyright 2011 GAEASYS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SyncListener <NSObject>
- (void)onSuccess:(id)req;
- (void)onFailure:(NSString *)errorMessage request:(id)req;

@end

