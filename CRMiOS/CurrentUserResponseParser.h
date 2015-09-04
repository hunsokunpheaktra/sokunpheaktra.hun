//
//  CurrentUserResponseParser.h
//  CRMiOS
//
//  Created by Sy Pauv on 7/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseParser.h"
#import "CurrentUserManager.h"

@interface CurrentUserResponseParser : ResponseParser {
    NSMutableDictionary *currentUser;
}

@property(nonatomic, retain) NSMutableDictionary *currentUser;

- (id)init;

@end