//
//  PhotoUtile.m
//  SMBClient4Mobile
//
//  Created by Sy Pauv Phou on 8/14/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "PhotoUtile.h"

@implementation PhotoUtile

//reize image size to max 200KB
+ (NSData*)resizeImage:(UIImage*)image{
    
    float resize = 1;
    NSData *imageData = UIImagePNGRepresentation(image);
    float imageSizeKB = (CGFloat)imageData.length / (CGFloat)1024;
    
    while(imageSizeKB > 200){
        resize -= 0.1;
        imageData = UIImageJPEGRepresentation(image, resize);
        imageSizeKB = (CGFloat)imageData.length / (CGFloat)1024;
        if(resize == 0) break;
    }
    return imageData;
}

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
    data = UIImagePNGRepresentation(img);
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
    
}

+ (void)renameFile:(NSString*)oldId newId:(NSString*)newId{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *oldPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"Picture+%@.png",oldId]];
    NSString *newPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"Picture+%@.png",newId]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
	// Check if the picture has already been created in the users filesystem
	BOOL exists = [fileManager fileExistsAtPath:oldPath];
    if (exists) {
        [fileManager moveItemAtPath:oldPath toPath:newPath error:nil];
    }
    
}

@end
