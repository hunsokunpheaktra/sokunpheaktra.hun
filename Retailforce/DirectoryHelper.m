//
//  DirectoryHelper.m
//  Datagrid
//
//  Created by Gaeasys Admin on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DirectoryHelper.h"

@implementation DirectoryHelper

+ (NSString*) getApplicationDocumentsDirectory{
    static NSString* documentsDirectory = nil;
    if (documentsDirectory == nil) {
        documentsDirectory = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)
            objectAtIndex:0] retain];
    }
    return documentsDirectory;
}

+ (BOOL)writeToFile:(NSData *)data  fileName:(NSString *)fileName extension:(NSString *)extension
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *appFile = [NSString stringWithFormat:@"%@/%@.%@", [self getApplicationDocumentsDirectory],fileName,extension];
    
    if (!appFile)  // if file doesn't exist, create it
    {
        NSLog(@"File %@ doesn't exist, so we create it", appFile);
        return ([fm createFileAtPath:appFile contents:data attributes:nil]);
    }
    else
        return ([data writeToFile:appFile atomically:YES]); 	
}

+ (NSString *) getLibrariesPath{
    return [NSString stringWithFormat:@"%@/Libraries",self.getApplicationDocumentsDirectory];
}

+ (void) createDirectory:(NSString*)newDirName atPath:(NSString*)atPath {
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL success = [manager createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",atPath,newDirName] withIntermediateDirectories:YES attributes:nil error:nil];
    [manager release];
    if (success)
    {
        NSLog(@"New Directory created");
    }
}

+ (void) initLibraryDirectory{
    [self createDirectory:@"Libraries" atPath:self.getApplicationDocumentsDirectory];
}











@end
