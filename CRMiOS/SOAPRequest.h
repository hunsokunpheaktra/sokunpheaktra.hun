//
//  SOAPManager.h
//  CRMiPad
//
//  Created by Sy Pauv Phou on 4/6/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Configuration.h"
#import "SOAPListener.h"
#import "PropertyManager.h"
#import "LogManager.h"
#import "ResponseParser.h"
#import "ParserListener.h"
#import "SyncTask.h"


@interface SOAPRequest : NSObject <ParserListener, SyncTask> {
    NSMutableData *webData;
    NSInteger status;
    NSObject <SOAPListener> *listener;
    NSNumber *task;
    NSNumber *retryCount;
}

@property (nonatomic, retain) NSMutableData *webData;
@property (nonatomic, retain) NSNumber *task;
@property (nonatomic, retain) NSNumber *retryCount;
@property (nonatomic, retain) NSObject <SOAPListener> *listener;

- (id)init:(NSObject <SOAPListener> *)listener;
- (NSString *)generateMessage;
- (void)generateBody:(NSMutableString *)soapMessage;
- (NSString *)getSoapAction;
- (NSString *)getURLSuffix;
- (ResponseParser *)getParser;
- (NSString *)fixEntity:(NSString *)entity;


@end
