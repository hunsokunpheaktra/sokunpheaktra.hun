//
//  PopupErrorDetailView.h
//  CRMiOS
//
//  Created by Sy Pauv on 7/18/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogItem.h"
#import "PadMainViewController.h"

@interface PopupErrorDetailView : UIViewController {
    UIPopoverController *popoverController;
    LogItem *item;
    UITextView *errorLogView;
    
}
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) UITextView *errorLogView;
@property (nonatomic, retain) LogItem *item;
- (id)initWithLog:(LogItem *)newlog;
- (void) show:(CGRect)rect parentView:(UIView *)parentView;
- (void)goToFixError;

@end
