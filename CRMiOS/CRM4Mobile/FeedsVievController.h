//
//  FeedsVievController.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 2/23/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "FeedSyncProcess.h"
#import "FeedManager.h"
#import "TriangleView.h"
#import "ShareNewFeed.h"
#import "FeedTableView.h"
#import "MBProgressHUD.h"
#import "EGORefreshTableHeaderView.h"
#import "LoadMoreFooterView.h"
#import "AddNewStatusController.h"
#import "DetailViewController.h"
#import "PadMainViewController.h"


#define FEED_LINE_HEIGHT 20
#define FEED_MARGIN 8
#define FEED_IMAGE_SIZE 48
#define FEED_COMMENT_IMAGE_SIZE 32
#define FEED_COMMENT_OFFSET 32
#define FEED_FONT_SIZE 14


@interface FeedsVievController : UITableViewController <RefreshInterface, SyncListener, UITextFieldDelegate, FeedListener , UIActionSheetDelegate,EGORefreshTableHeaderDelegate,LoadMoreFooterDelegate>  {
    UITableView *feedView;
    UILabel *errorLabel;
    UITextField *activeField;
    NSMutableArray *feedData;
    
    MBProgressHUD *_hud;
    UINavigationBar *navigationBar;
    UIActionSheet *asheet;
    
    //pull refresh
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
    
    //loading footer
    LoadMoreFooterView *_loadMOreFoodter;
    
}

@property (nonatomic, retain) UINavigationBar *navigationBar;
@property (retain) MBProgressHUD *hud;
@property (nonatomic, retain) UILabel *errorLabel;
@property (nonatomic, retain) UITableView *feedView;
@property (nonatomic, retain) NSMutableArray *feedData;
@property (nonatomic, retain) UITextField *activeField;

- (NSArray *)splitLines:(NSString *)text offset:(int)offset width:(int)width;
- (NSArray *)splitLinesWithNL:(NSString *)text offset:(int)offset width:(int)width;
- (BOOL)isComment:(FeedItem *)feed;
- (void)refreshFeed;
- (void)showNewFeedView:(id)sender;
- (void)addTempComment:(NSString *)parent Comment:(NSString *)comment;
- (void)rebuildFeedView;


// pull refresh method
- (void)doneLoadingTableViewData;
- (void)finishloadingMoreFeed;
- (void)linkRecord:(id)sender;

@end
