//
//  BypassInRequest.m
//  SyncForce
//
//  Created by Gaeasys Admin on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BypassInRequest.h"

@implementation BypassInRequest


+ (NSArray *) getBypass{
    return [NSArray arrayWithObjects: @"Folder" , @"Document" , @"Attachment" , @"ContentWorkspaceDoc" , @"ContentWorkspace" , @"ContentVersion" , @"ContentDocument" , @"User", @"RecordType" ,nil];
}

@end
