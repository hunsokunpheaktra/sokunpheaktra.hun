//
//  RequestFeedAvata.h
//  CRMiOS
//
//  Created by Sy Pauv on 11/23/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseRequest.h"
#import "AvatarParser.h"

@interface FeedAvatarRequest:BaseRequest {
    NSString *userId;
}

@property (nonatomic, retain) NSString *userId;

- (id)initWithUserId:(NSString *)userId;

@end
