//
//  PictureManager.m
//  CRMiOS
//
//  Created by Sy Pauv on 10/27/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "PictureManager.h"

@implementation PictureManager

+ (void)save:(NSString *)gadget_id data:(NSData *)data{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"Picture+%@.png",gadget_id]];
    NSError * error = nil;
    
    //if file exist delete resave
    [self deletePicture:gadget_id];
    
    [data writeToFile:path options:NSDataWritingAtomic error:&error];

    if (error != nil) {
        NSLog(@"Error: %@", error);
        return;
    }
    
}
+ (NSData *)read:(NSString *)gadget_id{
    
    NSData *data;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *getImagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"Picture+%@.png",gadget_id]];
    UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
    data=UIImagePNGRepresentation(img);
    return data;

}

+(void)deletePicture:(NSString *)gadget_id{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"Picture+%@.png",gadget_id]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
	// Check if the picture has already been created in the users filesystem
	BOOL exists = [fileManager fileExistsAtPath:path];
    if (exists) {
        [fileManager removeItemAtPath:path error:nil];
    }
	[fileManager release];

}

@end
