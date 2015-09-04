//
//  LoginRequest.h
//  CRMiOS
//
//  Created by Sy Pauv on 5/23/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PropertyManager.h"
#import "ParserListener.h"
#import "LoginListener.h"
#import "ResponseParser.h"


@interface LoginRequest : NSObject <ParserListener> {
    NSMutableData *webData;
    NSInteger status;
    NSObject <LoginListener> *listener;
}

@property (nonatomic,retain) NSObject <LoginListener> *listener;
@property (nonatomic,retain) NSMutableData *webData;

- (void)doRequest:(NSObject <LoginListener> *)newListener;
- (NSString *)getURLSuffix;
- (void)loginEnd:(NSString *)error;

@end
