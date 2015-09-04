//
//  LayoutViewController.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/26/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Configuration.h"
#import "LayoutDetailViewController.h"

@interface LayoutViewController : UITableViewController {
    NSMutableArray *subtypes;
}

@property(nonatomic, retain) NSMutableArray *subtypes;

- (id)init;

@end
