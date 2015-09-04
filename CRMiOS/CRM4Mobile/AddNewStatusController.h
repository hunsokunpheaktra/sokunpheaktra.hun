//
//  AddNewStatusController.h
//  CRMFeed
//
//  Created by Sy Pauv Phou on 2/22/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareNewFeed.h"
#import "FeedListener.h"
#import "RefreshInterface.h"
#import "FeedItem.h"

@interface AddNewStatusController : UIViewController<UITextViewDelegate>{
UITextView *textFeed;
NSObject<FeedListener> *feedlistener;
}
@property (nonatomic ,retain) NSObject<FeedListener> *feedlistener;
@property (nonatomic ,retain) UITextView *textFeed;

- (id)initWithListener:(NSObject <FeedListener> *)listener;
- (void)close;
- (void)shareFeed;
@end