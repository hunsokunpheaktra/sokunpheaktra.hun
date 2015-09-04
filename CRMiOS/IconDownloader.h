//
//  IconDownloader.h
//  CRMiOS
//
//  Created by Sy Pauv on 5/21/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IconDownloaderDelegate;

@interface IconDownloader : NSObject
{
    NSIndexPath *indexPathInTableView;
    id <IconDownloaderDelegate> delegate;
    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
    NSMutableDictionary *item;
}

@property (nonatomic, retain) NSMutableDictionary *item;
@property (nonatomic, retain) NSIndexPath *indexPathInTableView;
@property (nonatomic, assign) id <IconDownloaderDelegate> delegate;
@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;

- (void)startDownload;
- (void)cancelDownload;
@end
@protocol IconDownloaderDelegate
- (void)appImageDidLoad:(NSIndexPath *)indexPath;
@end
