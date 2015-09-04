//
//  FilterElementViewController.h
//  SyncForce
//
//  Created by Hun Sokunpheaktra on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateListener.h"

@interface FilterElementViewController : UITableViewController<UpdateListener>{
    
    NSString *header;
    NSString *itemSelect;
    NSArray *listItems;
    NSString *myTitle;
    NSInteger tag;
    BOOL     displayField;
    NSObject<UpdateListener> *listener;
    
}

@property (nonatomic,readwrite) NSInteger tag;
@property (nonatomic,retain) NSString *itemSelect;

- (id)initWithHeader:(NSString*)newHeader title:(NSString*)newTitle selectValue:(NSString*)value arrItems:(NSArray*)items frame:(CGRect)rect updateListener:(NSObject<UpdateListener>*)newListener isFieldDisplay:(BOOL)isFieldDisplay;

- (void)show:(CGRect)rect parent:(UIView*)mainView;

@end
