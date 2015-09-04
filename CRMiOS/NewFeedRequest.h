//
//  FeedSoupRequest.h
//  CRMiOS
//
//  Created by Sy Pauv on 11/23/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CurrentUserManager.h"
#import "NewFeedResponseParser.h"
#import "FeedManager.h"
#import "BaseRequest.h"

@interface NewFeedRequest : BaseRequest { 
    
    NSNumber *offset;
    
}

@property (nonatomic ,retain) NSNumber *offset;

- (id)initWithOffset:(NSNumber *)newOffset;


@end
