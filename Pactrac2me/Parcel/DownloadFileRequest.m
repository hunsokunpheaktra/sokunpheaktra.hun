//
//  DownloadFileRequest.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 12/19/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "DownloadFileRequest.h"
#import "JSON.h"

@implementation DownloadFileRequest

-(id)initWithImageURL:(NSString*)imgUrl parent:(NSString*)parentID{
    
    self = [super init];
    self.imageURL = imgUrl;
    self.parentId = parentID;
    return self;
    
}

-(void)doRequest:(NSObject<SyncListener> *)listen{
    
    self.synListener = listen;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.imageURL]];
    self.theConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

-(NSString *)getProccessName{
    return @"Download";
}

-(NSString *)getMethod{
    return @"POST";
}

@end
