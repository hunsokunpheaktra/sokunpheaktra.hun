//
//  4Test.h
//  SyncForce
//
//  Created by Gaeasys on 11/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDCServerSwitchboard.h"
#import "FDCOAuthViewController.h"
#import "SyncProcess.h"
#import "PropertyManager.h"
#import "DetailFilterPopup.h"
#import "Item.h"

@interface Preference : UITableViewController<UIAlertViewDelegate,SyncListener> {
    
    UIButton *btnTest;
    UIButton *btnReinitDB;
    NSArray  *arrayData;
    
    FDCOAuthViewController *oAuthViewController;
    FDCServerSwitchboard *connector;
}

@property (retain, nonatomic) UIButton *btnTest;
@property (retain, nonatomic) UIButton *btnReinitDB;
@property (retain, nonatomic) NSArray  *arrayData;

- (id) initWithArray:(NSArray *)tArray;
- (void) refresh;
- (void)cancelClick;

@end
