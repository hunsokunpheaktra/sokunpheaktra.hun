//
//  MediaItem.m
//  Datagrid
//
//  Created by Gaeasys Admin on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MediaItem.h"


@implementation MediaItem
@synthesize filepath,filename,isMovie,iconname,extension;

-(id)init:(NSString *)pfilepath filename:(NSString *)pfilename{
    self.filepath = pfilepath;
    self.filename = pfilename;
    self.isMovie = NO;
    self.iconname = NSLocalizedString(@"unknown64", Nil);
    self.extension = [pfilename substringFromIndex:[pfilename rangeOfString:@"."].location];
    return self;
}

-(id)initAsDirectory:(NSString *)pfilepath filename:(NSString *)pfilename{
    self.filepath = pfilepath;
    self.filename = pfilename;
    self.isMovie = NO;
    self.iconname =NSLocalizedString(@"Folder64", Nil) ;
    self.extension = nil; 
    return self;
}

@end
