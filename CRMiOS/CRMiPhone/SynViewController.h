//
//  SynViewController.h
//  CRMiOS
//
//  Created by Sy Pauv on 5/16/11.
//  Copyright 2011 Gaeasys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SyncController.h"

@interface SynViewController : UIViewController {
    
    IBOutlet UIButton *btnSyn;
    IBOutlet UIActivityIndicatorView *m_activity;

}

@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *m_activity;
- (id)init;
-(IBAction)startSyn:(id)sender;
-(void)updateSynButton:(BOOL)animated;
@end
