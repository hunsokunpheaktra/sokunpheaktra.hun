//
//  FeedDetailView.h
//  CRMiOS
//
//  Created by Sy Pauv on 3/29/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedItem.h"
#import "RefreshInterface.h"
#import "MBProgressHUD.h"
#import "StreamChildListViewController.h"
#import "CustomTextView.h"
#import "FeedListener.h"

@interface FeedDetailView : UIViewController<FeedListener,RefreshInterface,UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UIAlertViewDelegate,UIWebViewDelegate>{

    UITableView *tableView;
    NSMutableArray *listComments;
    FeedItem *feedParent;
    UIBarButtonItem *compose;
    NSObject<RefreshInterface> *refreshListener;
    UILabel *noComments;
    MBProgressHUD *HUD;
    UIImage *postImage;
    UIToolbar *myToolbar;
    CustomTextView *myTextView;
    StreamChildListViewController *childStream;

}

-(id)initWithComments:(FeedItem *)feed listener:(NSObject<RefreshInterface> *)linten;
-(void)composeComment;
-(void)keyboardWillShow:(NSNotification *)notification;
-(void)keyboardWillHide:(NSNotification *)notification;

@property (nonatomic , retain) UIToolbar *myToolbar;
@property (nonatomic , retain) UITableView *tableView;
@property (nonatomic , retain) MBProgressHUD*HUD;
@property (nonatomic , retain) UILabel *noComments;
@property (nonatomic , retain) NSObject<RefreshInterface> *refreshListener;
@property (nonatomic , retain) UIBarButtonItem *compose;
@property (nonatomic , retain) FeedItem *feedParent;
@property (nonatomic , retain) NSMutableArray *listComments;
@property (nonatomic , retain) CustomTextView *myTextView;
@end
