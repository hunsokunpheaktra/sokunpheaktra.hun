//
//  ResponseParser.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/9/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "ResponseParser.h"


@implementation ResponseParser

@synthesize errorMessage;
@synthesize errorCode;
@synthesize listener;
@synthesize lastPage;
@synthesize tags;
@synthesize currentText;
@synthesize objectCount;

- (void)parse:(NSData *)data {
    // we need an autorelease pool because we create a separate thread for parsing
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];
    [pool release];
}

- (id)init {
    self = [super init];
    self.errorCode = Nil;
    self.errorMessage = Nil;
    self.lastPage = [NSNumber numberWithBool:YES];
    self.currentText = [[NSMutableString alloc] init];
    self.tags = [[NSMutableArray alloc] initWithCapacity:1];
    self.objectCount = [NSNumber numberWithInt:0];
    return self;
}


- (void)parserEnd {
    if (self.errorMessage != Nil || self.errorCode != Nil) {
        [self.listener parserFailure:self.errorCode errorMessage:self.errorMessage];
    } else {
        [self.listener parserSuccess:[self.lastPage boolValue] objectCount:[self.objectCount intValue]];
    }
}



- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [self performSelectorOnMainThread:@selector(parserEnd) 
                           withObject:nil 
                        waitUntilDone:false];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    NSArray *parts = [elementName componentsSeparatedByString:@":"];
    [self.tags addObject:[parts lastObject]];
    [self handleAttributes:[parts lastObject] attributes:attributeDict level:[self.tags count]];

    [self.currentText release];
    self.currentText = [[NSMutableString alloc] init];
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    NSString *currentTag = [self.tags lastObject];
    if ([currentTag isEqualToString:@"errormsg"] || [currentTag isEqualToString:@"ErrorMessage"] || [currentTag isEqualToString:@"faultstring"]) {
        self.errorMessage = self.currentText;
    }
    if ([currentTag isEqualToString:@"ErrorCode"] || [currentTag isEqualToString:@"faultcode"]) {
        self.errorCode = self.currentText;
    }
    [self handleTag:currentTag value:self.currentText level:[self.tags count]];
    [self.currentText release];
    self.currentText = [[NSMutableString alloc] init];
    [self.tags removeLastObject];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self.currentText appendString:string];
}


- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    self.errorCode = [NSString stringWithFormat:@"%i", [parseError code]];
    self.errorMessage = [parseError description];
    [self performSelectorOnMainThread:@selector(parserEnd) 
                           withObject:nil 
                        waitUntilDone:false];
}

- (void)handleTag:(NSString *)tag value:(NSString *)value level:(int)level {
    
}

- (void)handleAttributes:(NSString *)tag attributes:(NSDictionary *)attributes level:(int)level {
    
}

- (void)dealloc
{
    [self.tags release];
    [super dealloc];
}

- (void)oneMoreItem {
    self.objectCount = [NSNumber numberWithInt:[self.objectCount intValue] + 1];
}


@end
