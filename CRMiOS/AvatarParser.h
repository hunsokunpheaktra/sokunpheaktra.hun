//
//  AvataParser.h
//  CRMiOS
//
//  Created by Sy Pauv on 11/24/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseParser.h"
#import "FeedManager.h"
#import "BaseFeedParser.h"

@interface AvatarParser : BaseFeedParser {
    NSString *userId;
}

@property (nonatomic, retain) NSString *userId;

- (id)initWithId:(NSString *)newUserId;

@end
