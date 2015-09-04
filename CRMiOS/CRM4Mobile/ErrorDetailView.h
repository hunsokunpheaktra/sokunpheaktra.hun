//
//  ErrorDetailView.h
//  CRMiOS
//
//  Created by Sy Pauv on 7/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogItem.h"
#import "DetailViewController.h"

@interface ErrorDetailView : UIViewController {

    LogItem *item;
    UITextView *errorLogView;
    UIButton *fixError;
    
}
@property (nonatomic, retain) UIButton *fixError;
@property (nonatomic, retain) UITextView *errorLogView;
@property (nonatomic, retain) LogItem *item;
- (id)initWithLog:(LogItem *)newlog;
- (void)goToFixError;
@end
