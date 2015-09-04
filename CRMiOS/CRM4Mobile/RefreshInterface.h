//
//  RefreshInterface.h
//  CRMFeed
//
//  Created by Sy Pauv Phou on 2/15/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedItem.h"

@protocol RefreshInterface <NSObject>
- (void)refresh;
- (void)addNewStatus:(FeedItem *)fItem;
@end
