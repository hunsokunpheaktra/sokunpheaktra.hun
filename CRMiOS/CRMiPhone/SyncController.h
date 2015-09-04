//
//  SyncController.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/25/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncListener.h"
#import "ListViewController.h"
#import "IphoneSynchronizationView.h"
#import "ErrorReport.h"
#import "TabTools.h"
#import "MailToFellow.h"

@class ListViewController;
@class IphoneSynchronizationView;

@interface SyncController : NSObject <SyncListener, MFMailComposeViewControllerDelegate, UIAlertViewDelegate> {
    UITabBarController *mainController;
    NSMutableArray *listControllers;
    IphoneSynchronizationView *synchronize;
}
@property(nonatomic, retain) IphoneSynchronizationView * synchronize;
@property(nonatomic, retain) NSMutableArray *listControllers;
@property(nonatomic, retain) UITabBarController *mainController;

+ (SyncController *)getInstance;
- (void)addListController:(ListViewController *)listController;
- (void)clearListControllers;

@end
