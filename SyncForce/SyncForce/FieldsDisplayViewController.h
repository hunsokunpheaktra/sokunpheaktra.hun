//
//  FieldsDisplayViewController.h
//  SyncForce
//
//  Created by Gaeasys on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterElementViewController.h"
#import "UpdateListener.h"
#import "CustomDataGrid.h"

@interface FieldsDisplayViewController : UITableViewController<UpdateListener>{
   
    NSString                *entity;
    NSMutableArray          *listLabel;
    NSMutableArray          *arrayFieldDisplay;
    NSMutableDictionary     *arrayNameLabel;
    NSMutableArray          *allElements;
    id                      parentView;
    
}

- (id)initWithEntity:(NSString*)newEntity parentView:(id)parent;

@end
