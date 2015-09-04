//
//  FeedResponseParser.h
//  CRMiOS
//
//  Created by Sy Pauv on 11/24/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedManager.h"
#import "FeedItem.h"
#import "FeedParser.h"
#import "FeedListener.h"
#import "BaseRequest.h"
#import "BaseFeedParser.h"

@interface NewFeedResponseParser : BaseFeedParser {
    
    NSMutableArray *allFeed;

}

@property (nonatomic, retain) NSMutableArray *allFeed;


@end
