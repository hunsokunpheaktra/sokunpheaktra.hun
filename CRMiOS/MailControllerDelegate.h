//
//  MailController.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/29/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MessageUI/MFMailComposeViewController.h>
#import "EntityManager.h"
#import "UpdateListener.h"
#import "Database.h"

@interface MailControllerDelegate : NSObject <MFMailComposeViewControllerDelegate> {
    Item *item;
    NSObject<UpdateListener> *listener;
}
@property (nonatomic,retain) NSObject<UpdateListener> *listener;
@property (nonatomic,retain) Item *item;

- (id)initWithItem:(Item *)newItem update:(NSObject<UpdateListener> *)update;
- (NSString *)findEmailSubject:(UIView *)view depth:(NSInteger)count;
- (NSString *)findEmailBody:(UIView *)view depth:(NSInteger)count;
- (NSString *)parseEmailBody:(UIView *)view;

@end
