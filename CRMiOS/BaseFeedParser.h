//
//  BaseFeedParser.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 11/29/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedParser.h"
#import "BaseRequest.h"

@interface BaseFeedParser : NSObject<FeedParser, NSXMLParserDelegate> {
    
    NSMutableString *currentText;  
    NSNumber *level;
    NSDictionary *currentAttributes;
    NSObject *request;   
}


@property (nonatomic, retain) NSObject *request;
@property (nonatomic, retain) NSMutableString *currentText;
@property (nonatomic, retain) NSNumber *level;
@property (nonatomic, retain) NSDictionary *currentAttributes;

- (void)endTag:(NSString *)tag;
- (void)beginTag:(NSString *)tag;
- (void)endDocument;

@end
