//
//  GenerateFileLocal.h
//  SyncForce
//
//  Created by Gaeasys Admin on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityRequest.h"

#define FILE_DOCUMENT @"Document"
#define FILE_ATTACHMENT @"Attachment"
#define FILE_CONTENTVERSION @"ContentVersion"

@interface GenerateFileLocal : EntityRequest {
    NSString *attachmentFolder;
    NSString *fileName;
    NSString *folderName;
    NSMutableData *webData;
    BOOL isDone;
}

- (id)initWithEntity:(NSString *)newEntity listener:(NSObject<SyncListener>*)newListener;

@end
