//
//  EntityRequestCreate.h
//  kba
//
//  Created by Gaeasys Admin on 10/4/11.
//  Copyright 2011 GAEASYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityRequest.h"
#import "Criteria.h"


@interface EntityRequestCreate : EntityRequest {

}

- (id)init:(NSString *)pentity listener:(NSObject<SyncListener>*)plistener;

@end
