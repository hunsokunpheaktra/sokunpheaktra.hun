//
//  MediaItem.h
//  Datagrid
//
//  Created by Gaeasys Admin on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MediaItem : NSObject {
    
    NSString *filepath;
    NSString *filename;
    BOOL isMovie;
    NSString *iconname;
    NSString *extension;
    
}

@property (nonatomic,retain) NSString *filepath;
@property (nonatomic,retain) NSString *filename;
@property (nonatomic,retain) NSString *iconname;
@property (nonatomic,retain) NSString *extension;

@property (nonatomic) BOOL isMovie;

-(id)init:(NSString *)pfilepath filename:(NSString *)pfilename;
-(id)initAsDirectory:(NSString *)pfilepath filename:(NSString *)pfilename;

@end
