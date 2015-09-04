//
//  BaseFeedParser.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 11/29/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "BaseFeedParser.h"


@implementation BaseFeedParser

@synthesize currentText;
@synthesize level;
@synthesize currentAttributes;
@synthesize request;

- (void)parse:(NSData *)content {
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    self.currentText = [[NSMutableString alloc] init];   
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:content];
    self.level = [NSNumber numberWithInt:0];
    [parser setDelegate:self];
    [parser parse];
    [parser release];
    [self.currentText release];
    //[pool release];
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self.currentText appendString:string];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    self.level = [NSNumber numberWithInt:[self.level intValue] + 1];
    self.currentAttributes = attributeDict;
    [self.currentText release];
    self.currentText = [[NSMutableString alloc] init];
    
    [self beginTag:elementName];

    
}

- (void)beginTag:(NSString *)tag {
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  
    [self endTag:elementName];
    [self.currentText release];
    self.currentText = [[NSMutableString alloc] init];
    self.level = [NSNumber numberWithInt:[self.level intValue] - 1];
}

- (void)endTag:(NSString *)tag {
    
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    [((BaseRequest *)request).listener feedFailure:(BaseRequest *)request errorCode:[NSString stringWithFormat:@"%i", [parseError code]] errorMessage:[parseError description]];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [self endDocument];
    [((BaseRequest *)request).listener feedSuccess:(BaseRequest *)request];
}


- (void)endDocument {
    
}

- (void) dealloc
{
    [self.currentText release];
    [super dealloc];
}

@end
