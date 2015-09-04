//
//  SFRestApiListener.h
//  kba
//
//  Created by Sy Pauv on 10/3/11.
//  Copyright 2011 GAEASYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFRequest.h"
#import "SynchronizeViewInterface.h"

@protocol SyncListener <NSObject>


- (void)onSuccess:(int)objectCount request:(NSObject<SFRequest> *)newRequest again:(bool)again;
- (void)onFailure:(NSString *)errorMessage request:(NSObject<SFRequest> *)newRequest again:(bool)again;
- (NSObject<SynchronizeViewInterface> *) getSyncController;
@end

