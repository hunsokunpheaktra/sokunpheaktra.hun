//
//  ErrorReport.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 6/9/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogManager.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface ErrorReport : NSObject <MFMailComposeViewControllerDelegate> {
    UIViewController *controller;
}

@property (nonatomic, retain) UIViewController *controller;

- (id)initWithController:(UIViewController *)newController;
- (void)sendErrorReport;
- (void)sendMail;

@end
