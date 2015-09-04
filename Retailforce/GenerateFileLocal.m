//
//  GenerateFileLocal.m
//  SyncForce
//
//  Created by Gaeasys Admin on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GenerateFileLocal.h"
#import "EntityManager.h"
#import "TransactionInfoManager.h"
#import "InfoFactory.h"
#import "GreaterThanCriteria.h"
#import "MediaHelper.h"
#import "DirectoryHelper.h"
#import "LogManager.h"
#import "EntityRequest.h"
#import "NSData (MBBase64).h"

@implementation GenerateFileLocal

- (id)initWithEntity:(NSString *)newEntity listener:(NSObject<SyncListener>*)newListener{
    [super initWithEntity:newEntity listener:newListener level:[self level]];
    attachmentFolder = NSLocalizedString(@"ATTACHEMENTS", Nil);
    isDone = NO;
    return self;
}

- (void)doRequest{
    NSString *tmpdateFilter= [TransactionInfoManager readLastSyncDate:[self getName]];
    NSMutableDictionary *filters = [[NSMutableDictionary alloc] initWithCapacity:1];
    if(tmpdateFilter != nil) 
        [filters setValue:[[GreaterThanCriteria alloc ]initWithValue:tmpdateFilter] forKey:@"LastModifiedDate"];
    
    if([self.entity isEqualToString:FILE_DOCUMENT]){
        
        NSString *stm4FolderName = @"Select Folder.Name As 'FolderName', Document.DeveloperName As 'Title', Document.Type As 'FileType', Document.Body As 'Body' From Document Inner Join Folder On Document.FolderId = Folder.Id";
        NSMutableArray *allfields = [NSMutableArray arrayWithObjects:@"FolderName", @"Title", @"FileType",@"Body", nil]; 
        for(Item *item in [EntityManager listBySQL:FILE_DOCUMENT statement:stm4FolderName criterias:filters fields:allfields]){
            folderName = [item.fields valueForKey:@"FolderName"];
            fileName = [NSString stringWithFormat:@"%@.%@",[item.fields valueForKey:@"Title"],[ MediaHelper confFileExtension:[item.fields valueForKey:@"FileType"]]];
            
            
            NSString *data = [item.fields valueForKey:@"Body"];
            NSData *fileData = [NSData__MBBase64_ dataWithBase64EncodedString:data];
            webData = [[NSMutableData alloc] initWithBytes:[fileData bytes] length:fileData.length];
            NSString *appFile = [NSString stringWithFormat:@"%@/%@/%@", [DirectoryHelper getLibrariesPath],folderName,fileName];
            if([webData writeToFile:appFile  atomically:YES]){
                NSLog(@"DOCUMENT : Create File IN : %@",appFile);
            }
            
        }
    }
    if([self.entity isEqualToString:FILE_ATTACHMENT]){
        NSString *stm4FolderName = @"Select Name As 'Title', ContentType As 'FileType', Body As 'Body' From Attachment";
        NSMutableArray *allfields = [NSMutableArray arrayWithObjects:@"Title", @"FileType", @"Body", nil]; 
        for(Item *item in [EntityManager listBySQL:FILE_ATTACHMENT statement:stm4FolderName criterias:filters fields:allfields]){
            folderName = attachmentFolder;
            fileName = [NSString stringWithFormat:@"%@.%@",[item.fields valueForKey:@"Title"],[ MediaHelper confFileExtension:[item.fields valueForKey:@"FileType"]]];
            
            NSString *data = [item.fields valueForKey:@"Body"];
            NSData *fileData = [NSData__MBBase64_ dataWithBase64EncodedString:data];
            webData = [[NSMutableData alloc] initWithBytes:[fileData bytes] length:fileData.length];
            NSString *appFile = [NSString stringWithFormat:@"%@/%@/%@", [DirectoryHelper getLibrariesPath],folderName,fileName];
            if([webData writeToFile:appFile  atomically:YES]){
                NSLog(@"ATTACHMENT : Create File IN : %@",appFile);
            }
            
        }
    }
    if([self.entity isEqualToString:FILE_CONTENTVERSION]){
        
        NSString *stm4FolderName = @"Select ContentWorkSpace.Name As 'FolderName',ContentDocument.LatestPublishedVersionId As 'ContentVersionId'  From (ContentWorkspaceDoc Inner Join ContentWorkspace On ContentWorkspaceDoc.ContentWorkspaceId = ContentWorkspace.Id) Inner Join ContentDocument On ContentDocument.Id = ContentWorkspaceDoc.ContentDocumentId";
        NSMutableArray *allfields = [NSMutableArray arrayWithObjects:@"FolderName", @"ContentVersionId", nil]; 

        for(Item *item in [EntityManager listBySQL:FILE_CONTENTVERSION statement:stm4FolderName criterias:[[NSDictionary alloc] init] fields:allfields]){

            [filters setValue:[ValuesCriteria criteriaWithString:@"P"] forKey:@"PublishStatus"];
            [filters setValue:[ValuesCriteria criteriaWithString:[item.fields valueForKey:@"ContentVersionId"]] forKey:@"Id"];
            
            Item *contentVersion = [EntityManager find:FILE_CONTENTVERSION criterias:filters];
            if(contentVersion == nil) continue;
            
            folderName = [item.fields valueForKey:@"FolderName"];
            fileName = [NSString stringWithFormat:@"%@.%@",[contentVersion.fields valueForKey:@"Title"],[ MediaHelper confFileExtension:[contentVersion.fields valueForKey:@"FileType"]]];
            
            NSString *data = [contentVersion.fields valueForKey:@"VersionData"];
            NSData *fileData = [NSData__MBBase64_ dataWithBase64EncodedString:data];
            webData = [[NSMutableData alloc] initWithBytes:[fileData bytes] length:fileData.length];
            NSString *appFile = [NSString stringWithFormat:@"%@/%@/%@", [DirectoryHelper getLibrariesPath],folderName,fileName];
            if([webData writeToFile:appFile  atomically:YES]){
                NSLog(@"CONTENTVERSION : Create File IN : %@",appFile);
            }
        }

    }
//    [webData release];
//    [filters release];
    isDone = YES;
    [self.listener onSuccess:-1 request:self again:false];
}
- (NSString *)getName{ 
    return [NSString stringWithFormat: @"Local Files Checking for %@",self.entity];
}

- (BOOL)prepare{
    if(self.entity != FILE_DOCUMENT && self.entity != FILE_CONTENTVERSION && self.entity != FILE_ATTACHMENT){
        return NO;
    }
    //Create sub directory  
    if([self.entity isEqualToString:FILE_DOCUMENT]){
        for(Item *item in [EntityManager list:@"Folder" criterias:[[NSDictionary alloc] init]]){
            if(![self.entity isEqualToString:[item.fields valueForKey:@"Type"]]) continue;
            NSString *foldername = [item.fields valueForKey:@"Name"];
            if(foldername == nil) continue;
            [DirectoryHelper createDirectory:foldername atPath:[DirectoryHelper getLibrariesPath]];
        }
    }
    else if([self.entity isEqualToString:FILE_ATTACHMENT]){
        [DirectoryHelper createDirectory:attachmentFolder atPath:[DirectoryHelper getLibrariesPath]];
    }
    else if([self.entity isEqualToString:FILE_CONTENTVERSION]){
        NSString *stm = @"Select ContentWorkSpace.Name From ContentWorkspaceDoc Inner Join ContentWorkspace On ContentWorkspaceDoc.ContentWorkspaceId = ContentWorkspace.Id ";
        NSMutableArray *allfields = [NSMutableArray arrayWithObjects:@"Name",nil];
        NSArray * rows = [EntityManager listBySQL:self.entity statement:stm criterias:[[NSDictionary alloc] init] fields:allfields];
        for(Item *item in rows){
            NSString *foldername = [item.fields valueForKey:@"Name"];
            if(foldername == nil) continue;
            [DirectoryHelper createDirectory:foldername atPath:[DirectoryHelper getLibrariesPath]];
        }
    }
    //return YES;
    
    return !isDone;
}

@end