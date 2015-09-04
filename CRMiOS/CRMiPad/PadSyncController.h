//
//  PadSyncController.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/27/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncListener.h"
#import "SyncInterface.h"
#import "LogManager.h"
#import "ErrorReport.h"
#import "PadMainViewController.h"
#import "PadTabTools.h"
#import "MailToFellow.h"

@class PadMainViewController;

@interface PadSyncController : NSObject <SyncListener, UIAlertViewDelegate> {
    UITabBarController *mainController;
    NSMutableArray *listControllers;
    NSObject <SyncInterface> *syncController;
    NSObject <SyncInterface> *prefSyncControler;
}
@property (nonatomic, retain) UITabBarController *mainController;
@property (nonatomic, retain) NSMutableArray *listControllers;
@property (nonatomic, retain) NSObject <SyncInterface> *syncController;
@property (nonatomic, retain) NSObject <SyncInterface> *prefSyncControler;

+ (PadSyncController *)getInstance;
- (void)addListController:(PadMainViewController *)controller;
- (void)clearListControllers;

@end
