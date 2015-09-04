//
//  GroupManager.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/28/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityManager.h"
#import "Group.h"

@interface GroupManager : NSObject {
    
}

+ (NSArray *)getGroups:(NSString *)subtype items:(NSArray *)items;

@end
