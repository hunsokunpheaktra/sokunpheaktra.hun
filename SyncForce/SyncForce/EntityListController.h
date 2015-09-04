//
//  EntityListController.h
//  SyncForce
//
//  Created by Hun Sokunpheaktra on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateListener.h"

@interface EntityListController : UITableViewController{
    
    NSArray *listItems;
    UIPopoverController *popover;
    NSString *entity;
    
}
@property (nonatomic,retain) NSObject<UpdateListener> *updateListener;
@property (nonatomic,retain) NSString *entity;
@property (nonatomic,retain) UIPopoverController *popover;

- (void)showPopup:(UIBarButtonItem*)barItem parentView:(UIView*)mainView;
- (id)initWithEntity:(NSString*)newEntity listener:(NSObject<UpdateListener>*)updateLis;

@end
