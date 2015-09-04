//
//  MailToFellow.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/26/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "LogManager.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface MailToFellow : NSObject <MFMailComposeViewControllerDelegate> {
    UIViewController *controller;
}

@property (nonatomic, retain) UIViewController *controller;

- (id)initWithController:(UIViewController *)newController;
- (void) sendMailToFellow;

@end
