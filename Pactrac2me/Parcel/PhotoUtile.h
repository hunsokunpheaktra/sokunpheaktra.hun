//
//  PhotoUtile.h
//  SMBClient4Mobile
//
//  Created by Sy Pauv Phou on 8/14/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoUtile : NSObject

+ (void)save:(NSString *)gadget_id data:(NSData *)data;
+ (NSData *)read:(NSString *)gadget_id;
+ (void)deletePicture:(NSString *)gadget_id;
+ (NSData*)resizeImage:(UIImage*)image;

@end
