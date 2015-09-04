//
//  LoadMoreFooterView.h
//  CRMFeed
//
//  Created by Sy Pauv Phou on 2/21/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LoadMoreFooterDelegate;
@interface LoadMoreFooterView : UIView{
    id _delegate;
    UIActivityIndicatorView *_activityView;
    BOOL _isLoadingShow;
}
@property(nonatomic,assign) id <LoadMoreFooterDelegate> delegate;

- (void)showLoadingFooter:(UIScrollView *)scrollView;
- (void)hideLoadingFooter:(UIScrollView *)scrollView;

- (id)initWithFrame:(CGRect)frame;
@end

@protocol LoadMoreFooterDelegate
- (void)startLoadMoreFeed:(LoadMoreFooterView*)view;
@end

