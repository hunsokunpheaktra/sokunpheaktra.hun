//
//  ResponseParser.h
//  Parcel
//
//  Created by Hun Sokunpheaktra on 1/10/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLParser.h"
#import "HTMLNode.h"

@interface ResponseParser : NSObject

-(BOOL)parse:(NSDictionary*)jsonData;
-(NSDictionary*)dataReturned:(NSDictionary*)jsonData;


@end
