//
//  StreamChildListViewController.h
//  SMBClient4Mobile
//
//  Created by Hun Sokunpheaktra on 10/8/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface StreamChildListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    NSArray *listComments;
    UITableView *myTable;
    float totalHeight;
}

@property(nonatomic,retain)UITableView *myTable;
@property(nonatomic,readwrite)float totalHeight;

-(id)initWithChildComments:(NSArray*)childComments;
-(void)setViewFrame:(CGRect)rect;
-(void)calculateTotalHeight:(float)width;

@end
