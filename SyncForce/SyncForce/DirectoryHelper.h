//
//  DirectoryHelper.h
//  Datagrid
//
//  Created by Gaeasys Admin on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DirectoryHelper : NSObject {
    
}

+ (NSString*) getApplicationDocumentsDirectory;
+ (BOOL)writeToFile:(NSData *)data  fileName:(NSString *)fileName extension:(NSString *)extension;
+ (NSString *) getLibrariesPath;
+ (void) initLibraryDirectory;
+ (void) createDirectory:(NSString*)newDirName atPath:(NSString*)atPath;

@end
