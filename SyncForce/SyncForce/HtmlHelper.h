//
//  HtmlHelper.h
//  SyncForce
//
//  Created by Hun Sokunpheaktra on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

@interface HtmlHelper : NSObject<NSXMLParserDelegate>{
    NSMutableString *resultString;
}

- (NSString*)convertEntiesInString:(NSString*)s;

@end
