//
//  HtmlHelper.m
//  SyncForce
//
//  Created by Hun Sokunpheaktra on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HtmlHelper.h"

@implementation HtmlHelper

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)s {
    [resultString appendString:s];
}

- (NSString*)convertEntiesInString:(NSString*)s {
    resultString = [[[NSMutableString alloc] init] autorelease];
    if(s == nil) {
        NSLog(@"ERROR : Parameter string is nil");
    }
    NSString* xmlStr = [NSString stringWithFormat:@"<d>%@</d>", s];
    NSData *data = [xmlStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSXMLParser* xmlParse = [[[NSXMLParser alloc] initWithData:data] autorelease];
    xmlParse.delegate = self;
    [xmlParse parse];
    return [NSString stringWithFormat:@"%@",resultString];
}


@end
