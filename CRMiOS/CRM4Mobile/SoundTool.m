//
//  SoundTool.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 2/8/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "SoundTool.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation SoundTool {
    SystemSoundID handle;
}

- (id) initWithPath: (NSString*) path
{
    [super init];
    NSString *const resourceDir = [[NSBundle mainBundle] resourcePath];
    NSString *const fullPath = [resourceDir stringByAppendingPathComponent:path];
    NSURL *const url = [NSURL fileURLWithPath:fullPath];
    AudioServicesCreateSystemSoundID((CFURLRef) url, &handle);
    
    return self;
}

- (void) dealloc
{
    AudioServicesDisposeSystemSoundID(handle);
    [super dealloc];
}

- (void) play
{
    AudioServicesPlaySystemSound(handle);
}

@end
