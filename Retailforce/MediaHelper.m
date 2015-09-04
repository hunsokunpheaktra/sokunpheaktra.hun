//
//  MediaHelper.m
//  Datagrid
//
//  Created by Gaeasys Admin on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MediaHelper.h"

@implementation MediaHelper

static NSArray* supportMovieFiles = nil;

+ (BOOL) checkMovieFile:(NSString *)extension{
    //check nil produces runtime error
    //if(supportMovieFiles == nil){
    supportMovieFiles = [NSArray arrayWithObjects:@".mov", @".mp4", @".m4v", nil]; 
    //}  
    return [supportMovieFiles containsObject:extension];
}

+ (void) putMediaItemIcon:(MediaItem *)mediaItem{
    if(mediaItem.isMovie){
        mediaItem.iconname = @"wmp64";
    }else{
        if([mediaItem.extension isEqualToString:@".png"] 
           || [mediaItem.extension isEqualToString: @".jpg"] 
           || [mediaItem.extension isEqualToString: @".jpeg"]
           || [mediaItem.extension isEqualToString: @".gif"]){
            mediaItem.iconname = @"Img64";
        }
        else if([mediaItem.extension isEqualToString: @".pdf"] ){
            mediaItem.iconname = @"Pdf64";
        }
        else if([mediaItem.extension isEqualToString: @".xls"] 
                || [mediaItem.extension isEqualToString: @".xlsx"] ){
            mediaItem.iconname = @"Excel64";
        }
        else if([mediaItem.extension isEqualToString: @".ppt"] 
                || [mediaItem.extension isEqualToString: @".pptx"]){
            mediaItem.iconname = @"PowerPoint64";
        }
        else if([mediaItem.extension isEqualToString: @".doc"] 
                || [mediaItem.extension isEqualToString: @".docx"]){
            mediaItem.iconname = @"Word64";
        }
    }
}

+ (NSString* ) confFileExtension:(NSString*)fileType{
    fileType = [fileType lowercaseString];
    if([fileType isEqualToString:@"power_point"]){
        fileType = @"ppt";
    }else if([fileType isEqualToString:@"word"]){
        fileType = @"doc";
    }else if([fileType isEqualToString:@"excel"]){
        fileType = @"xls";
    }else if([fileType isEqualToString:@"power_point_x"]){
        fileType = @"pptx";
    }else if([fileType isEqualToString:@"word_x"]){
        fileType = @"docx";
    }else if([fileType isEqualToString:@"excel_x"]){
        fileType = @"xlsx";
    }
    return fileType;
}

@end
