//
//  EntityStorage.h
//  SalesforceSyncModule
//
//  Created by Gaeasys Admin on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncListener.h"

@interface EntityStorage : NSObject<SFRequest> {
    NSNumber *tasknum;
    NSObject<SyncListener> *listener;
}

@property (nonatomic, retain) NSNumber *tasknum;
@property (nonatomic, retain) NSObject<SyncListener> *listener;
- (id)init:(NSObject<SyncListener>*)newListener;

@end
