//
//  FeedProtocol.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 11/29/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol FeedParser <NSObject>

- (void)parse:(NSData *)data;
- (void)setRequest:(NSObject *)request;

@end
