//
//  IphoneAbout.h
//  CRMiOS
//
//  Created by Sy Pauv on 6/15/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ErrorReport.h"

@interface IphoneAbout : UIViewController {
    UILabel *comment;
    UIView *buttonView;
    UIImageView *aboutLogo;
}

@property (nonatomic, retain) UIView *buttonView;
@property (nonatomic, retain) UILabel *comment;
@property (nonatomic, retain) UIImageView *aboutLogo;

- (void)goWebsite:(id)sender;
- (void)sendFeedback:(id)sender;

@end
