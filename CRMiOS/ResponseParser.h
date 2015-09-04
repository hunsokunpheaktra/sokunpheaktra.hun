//
//  ResponseParser.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/9/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSXMLParser.h>
#import "ParserListener.h"

@interface ResponseParser : NSObject <NSXMLParserDelegate> {
    NSString *errorMessage;
    NSString *errorCode;
    NSObject <ParserListener> *listener;
    NSNumber *lastPage;
    NSMutableArray *tags;
    NSMutableString *currentText;  
    NSNumber *objectCount;
}

@property (nonatomic, retain) NSNumber *lastPage;
@property (nonatomic, retain) NSString *errorCode;
@property (nonatomic, retain) NSString *errorMessage;
@property (nonatomic, retain) NSObject <ParserListener> *listener;
@property (nonatomic, retain) NSMutableArray *tags;
@property (nonatomic, retain) NSMutableString *currentText;
@property (nonatomic, retain) NSNumber *objectCount;

- (void)parse:(NSData *)data;
- (void)handleTag:(NSString *)tag value:(NSString *)value level:(int)level;
- (void)handleAttributes:(NSString *)tag attributes:(NSDictionary *)attributes level:(int)level;
- (void)oneMoreItem;

@end
