//
//  NSData (MBBase64).h
//  SyncForce
//
//  Created by Gaeasys Admin on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData__MBBase64_ : NSData

+ (id)dataWithBase64EncodedString:(NSString *)string;     //  Padding '=' characters are optional. Whitespace is ignored.
- (NSString *)base64Encoding;

@end
