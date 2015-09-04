//
//  CurrentUserResponseParser.m
//  CRMiOS
//
//  Created by Sy Pauv on 7/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "CurrentUserResponseParser.h"

@implementation CurrentUserResponseParser

@synthesize currentUser;

- (id)init {
    self.currentUser = [[NSMutableDictionary alloc] initWithCapacity:1];
    return [super init];
}

- (void)handleTag:(NSString *)tag value:(NSString *)value level:(int)level {
    
    if (level==6 && ([tag isEqualToString:@"UserId"] || [tag isEqualToString:@"Alias"] || [tag isEqualToString:@"UserSignInId"])) {
        [currentUser setObject:value forKey:tag];
        if ([tag isEqualToString:@"UserSignInId"]) {
            [self oneMoreItem];
            [CurrentUserManager upsert:currentUser];
        }
    }
       
}


@end
