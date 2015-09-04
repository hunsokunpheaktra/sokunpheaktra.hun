//
//  MainMediaViewer.h
//  Datagrid
//
//  Created by Gaeasys Admin on 10/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSplitViewController.h"
#import "MediasViewer.h"

@class DirectoryListViewController;
@interface MainMediaViewer :MGSplitViewController {
    DirectoryListViewController *directoryListViewController;
    MediasViewer *mediasViewer;
}

@property (nonatomic, retain) DirectoryListViewController *directoryListViewController;
@property (nonatomic, retain) MediasViewer *mediasViewer;


- (id)init:(NSString *)prootPath;

@end
