//
//  ScanViewController.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 6/23/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ZBarReaderViewController.h"

@interface ScanViewController : UIViewController/* <ZBarReaderDelegate> */{
    UITextView *textScan;
}
;
@property (nonatomic, retain) UITextView *textScan;

- (void)scanClick:(id)sender;

@end
