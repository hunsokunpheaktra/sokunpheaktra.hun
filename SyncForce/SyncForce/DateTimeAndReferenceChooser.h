//
//  DateTimeAndReferenceChooser.h
//  SyncForce
//
//  Created by Gaeasys on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateListener.h"

@class CustomDataGrid;

@interface DateTimeAndReferenceChooser : UITableViewController<UpdateListener>{
    
    NSString *type;
    NSString *itemSelect;
    NSArray *listItems;
    NSArray *indexRowCol;
    NSInteger tag;
    NSObject<UpdateListener> *listener;
    
}

@property (nonatomic,readwrite) NSInteger tag;
@property (nonatomic,retain) NSString *itemSelect;

- (id)initWithHeader:(NSString*)type indexRowCol:(NSArray*)arrayIndex selectValue:(NSString*)value arrItems:(NSArray*)items frame:(CGRect)rect updateListener:(NSObject<UpdateListener>*)newListener;

- (void)show:(CGRect)rect parent:(UIView*)mainView;

@end