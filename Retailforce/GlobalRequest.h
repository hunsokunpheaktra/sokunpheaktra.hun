//
//  GlobalRequest.h
//  SyncForce
//
//  Created by Hun Sokunpheaktra on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityRequest.h"

@interface GlobalRequest : EntityRequest{
    
}

- (BOOL)checkObject:(NSString*)sobjectName;

@end
