//
//  PictureManager.h
//  CRMiOS
//
//  Created by Sy Pauv on 10/27/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PictureManager : NSObject {
    
}

+ (void)save:(NSString *)gadget_id data:(NSData *)data;
+ (NSData *)read:(NSString *)gadget_id;
+ (void)deletePicture:(NSString *)gadget_id;

@end
