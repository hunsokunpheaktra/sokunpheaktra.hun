//
//  RecordTypeListViewController.h
//  SyncForce
//
//  Created by Gaeasys on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateListener.h"

@class CustomDataGrid;

@interface RecordTypeListViewController : UITableViewController<UpdateListener>{
    
    NSArray *listItems;
    NSObject<UpdateListener> *listener;
    NSString* recordTypeSelected;
    id  parentCon;
    
}

- (id)initWithframe:(CGRect)rect listItems:(NSArray*)listItems updateListener:(id)listener;
- (void)show:(CGRect)rect parent:(UIView*)mainView;

@end