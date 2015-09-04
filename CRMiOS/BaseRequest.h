//
//  BaseRequest.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 11/29/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedParser.h"
#import "FeedListener.h"
#import "Configuration.h"

@interface BaseRequest : NSObject {
    NSMutableData *webData;  
    NSNumber *status;
    NSObject <FeedListener> *listener;
}

@property (nonatomic, retain) NSMutableData *webData;
@property (nonatomic, retain) NSObject <FeedListener> *listener; 
@property (nonatomic, retain) NSNumber *status;

- (void)doRequest:(NSObject <FeedListener> *)listener;
- (NSString *)generateMessage;
- (NSString *)getSuffix;
- (NSObject <FeedParser> *)getParser;
-(NSString *)StringEncode:(NSString *)str;
@end
