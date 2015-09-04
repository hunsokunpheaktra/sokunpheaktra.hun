//
//  GroupManager.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/28/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "GroupManager.h"


@implementation GroupManager

+ (NSArray *)getGroups:(NSString *)subtype items:(NSArray *)items {
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:subtype];
    NSMutableArray *groups = [[NSMutableArray alloc] initWithCapacity:1];
    for (Item *item in items) {
        NSString *groupId = [sinfo getGroupName:item];
        Group *group = nil;
        for (Group *tmp in groups) {
            if ([tmp.name isEqualToString:groupId]) {
                group = tmp;
                break; 
            }
        }
        if (group == nil) {
            group = [[Group alloc] init];
            group.name = groupId;
            group.shortName = [sinfo getGroupShortName:item];
            [groups addObject:group];
            [group release];
        }
        [group.items addObject:item];
    }
    
    // RSK: revers records in group to the right order of time for activity object
    if ([sinfo.entity isEqualToString:@"Activity"]) {
        for (Group *tmp in groups) {
            if ([tmp.items count]>0) {
                NSArray* reversed = [[tmp.items reverseObjectEnumerator] allObjects];
                tmp.items = [NSMutableArray arrayWithArray:reversed];

            }
        }
    }    
    return groups;
}

@end
