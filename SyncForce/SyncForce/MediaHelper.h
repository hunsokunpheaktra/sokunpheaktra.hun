//
//  MediaHelper.h
//  Datagrid
//
//  Created by Gaeasys Admin on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaItem.h"

@interface MediaHelper : NSObject {
    
}

+ (BOOL) checkMovieFile:(NSString *) extension;
+ (void) putMediaItemIcon:(MediaItem*) mediaItem;
+ (NSString* ) confFileExtension:(NSString*)fileType;

@end
