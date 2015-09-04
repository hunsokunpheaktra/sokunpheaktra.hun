//
//  ParserListener.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/6/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ParserListener <NSObject>

- (void)parserSuccess:(BOOL)lastPage objectCount:(int)objectCount;
- (void)parserFailure:(NSString *)errorCode errorMessage:(NSString *)errorMessage;

@end
