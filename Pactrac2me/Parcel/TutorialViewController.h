//
//  TutorialViewController.h
//  Parcel
//
//  Created by Hun Sokunpheaktra on 11/7/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HGPageScrollView.h"

#define kNumPages 10

@interface TutorialViewController : UIViewController<HGPageScrollViewDelegate, HGPageScrollViewDataSource>{
    
    HGPageScrollView *_myPageScrollView;
    NSMutableArray   *_myPageDataArray;
    
}

-(void)done;
-(void)didClickBrowsePages:(id)sender;

@end
