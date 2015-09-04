//
//  DirectoryListViewController.h
//  Datagrid
//
//  Created by Gaeasys Admin on 10/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaItem.h"
#import "MainMediaViewer.h"

@interface DirectoryListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    MediaItem *selectedItem;
    MainMediaViewer *mainmediaviewer;
    NSArray *directoryList;
    UITableView *listView;
}

@property (nonatomic, retain) MediaItem *selectedItem;
@property (nonatomic, retain) MainMediaViewer *mainmediaviewer;
@property (nonatomic, retain) NSArray *directoryList;
@property (nonatomic, retain) UITableView *listView;

- (id)initWithRootPath:(NSString *)prootPath mainmediaviewer:(MainMediaViewer *)pmainmediaviewer;

@end
