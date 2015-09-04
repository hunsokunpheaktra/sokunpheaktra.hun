//
//  AllFeedItem.m
//  CRMiOS
//
//  Created by Sy Pauv on 11/24/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "FeedManager.h"


@implementation FeedManager

static NSMutableArray *feedData;
static NSMutableDictionary *avatarData;

static NSArray *allFields;

+ (NSArray *)getAllFields {
    if (allFields == nil) {
        allFields = [[NSArray alloc]initWithObjects:@"createddate", @"comment", @"userid", @"parentid",@"fullname", @"entity", @"recordid", @"recordname", @"gid", nil];
    }
    return allFields;
}

+ (NSArray *)getFeed {
    if (feedData == nil) {
        feedData = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return feedData;
}

+ (NSArray *)getAllUserId {
    NSMutableArray *tmpuserId = [[NSMutableArray alloc] initWithCapacity:1];
    for (FeedItem *item in [FeedManager getFeed]) {
        if (![tmpuserId containsObject:[item getUserId]]) {
            [tmpuserId addObject:[item getUserId]];
        }
    }
    return tmpuserId;
}

+ (NSData *)getAvatar:(NSString *)userId {
    return [avatarData objectForKey:userId];
}

+ (NSArray *)allParentsItem {
    NSMutableArray *allparents = [[NSMutableArray alloc]initWithCapacity:1];
    NSArray *feeds=[FeedManager getFeed];
    for (FeedItem *item in feeds) {
        if ([[item getParentId] isEqualToString:@""] || [item getParentId] == nil) {
            [allparents addObject:item];
        }
    }
    return allparents;
}

+ (void)writeFeed:(NSArray *)newFeedData {
    [feedData release];
    feedData = [[NSMutableArray alloc] initWithArray:newFeedData];
}


+ (void)writeAvatar:(NSString *)data forUser:(NSString *)userId {
    if (avatarData == nil) {
        avatarData = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    if ([[data stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        return;
    }
    
    [Base64 initialize];
    NSData *imageData = [Base64 decode:data];

    //crop image
    UIImage *image = [UIImage imageWithData:imageData];
    int cropSize = 0, dx = 0, dy = 0;
    if (image.size.width > image.size.height) {
        cropSize = image.size.height;
        dx = (image.size.width - cropSize) / 2;
    } else {
        cropSize = image.size.width;
        dy = (image.size.height - cropSize) / 2;
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(dx, dy, cropSize, cropSize));
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    //resize image to a smallest size to save memory
    CGSize newSize=CGSizeMake(100, 100);
    UIGraphicsBeginImageContext( newSize );
    [croppedImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage100x100 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *dataImage = UIImagePNGRepresentation(newImage100x100);
    [avatarData setObject:dataImage forKey:userId];
    
}


@end
