//
//  IpadAboutController.h
//  CRMiOS
//
//  Created by Sy Pauv on 6/8/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ErrorReport.h"

@interface IpadAboutController : UIViewController {
    UILabel *description;
    UIImageView *logo;
    
}

@property (nonatomic, retain) UILabel *description;
@property (nonatomic, retain) UIImageView *logo;

- (void)goWebsite:(id)sender;
- (void)sendFeedback:(id)sender;

@end
