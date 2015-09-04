//
//  EntityRequestDeleted.h
//  SyncForce
//
//  Created by Gaeasys Admin on 10/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityRequest.h"

@interface EntityRequestDeleted : EntityRequest {
    NSDate *startdate;
    BOOL isDone;
}
@property (nonatomic, retain) NSDate *startdate;

- (id)init:(NSString *)pentity listener:(NSObject<SyncListener>*)plistener;

@end
