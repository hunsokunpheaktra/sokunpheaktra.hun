//
//  Mediaviewer.h
//  Datagrid
//
//  Created by Gaeasys Admin on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import "MGSplitViewController.h"

@class MainMediaViewer;
@interface MediasViewer : UIViewController <UITableViewDelegate, UITableViewDataSource,QLPreviewControllerDataSource,MGSplitViewControllerDelegate>
{
	NSArray *arrayOfDocuments;
    UITableView *tableview;
    MainMediaViewer *mainMediaViewer;
    UIPopoverController *popoverController;
}

@property(nonatomic , retain) UITableView *tableview;
@property (nonatomic, retain) MainMediaViewer *mainMediaViewer;
@property (nonatomic, retain) UIPopoverController *popoverController;

-(id)initWithFolder:(NSString*)folderName typeFilters:(NSArray*)filters;
- (void)fileFilter:(NSString *)folderName typeFilters:(NSArray *) filters;

@end
