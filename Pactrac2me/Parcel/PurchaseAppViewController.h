//
//  PurchaseAppViewController.h
//  Parcel
//
//  Created by Hun Sokunpheaktra on 12/24/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RageIAPHelper.h"

@interface PurchaseAppViewController : UITableViewController{
    
    NSArray *_products;
    NSNumberFormatter * _priceFormatter;
    
}

@property(nonatomic,retain)UIRefreshControl *refreshControl;

@end
