//
//  OutgoinShareNewFeed.h
//  CRMiOS
//
//  Created by Sy Pauv on 11/28/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOAPListener.h"
#import "ParserListener.h"
#import "FeedItem.h"
#import "ShareNewFeedParser.h"
#import "BaseRequest.h"
#import "CurrentUserManager.h"

@interface ShareNewFeed : BaseRequest {
    NSString *parentId;
    NSString *comment;
}
@property (nonatomic, retain) NSString *parentId;
@property (nonatomic, retain) NSString *comment;

- (id)init:(NSString *)newParentId comment:(NSString *)newComment;

@end
