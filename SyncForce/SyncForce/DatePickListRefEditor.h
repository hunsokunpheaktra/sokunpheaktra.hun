//
//  DatePickListRefEditor.h
//  SyncForce
//
//  Created by Gaeasys on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateListener.h"
#import "AddEditViewController.h"

@interface DatePickListRefEditor : UITableViewController{
    
    NSString *valueChosen;
    NSString *fieldType;
    NSString *apiName;
    NSArray  *listItems;
    NSInteger tag;
    id       listener;
    
}

@property (nonatomic,readwrite) NSInteger tag;
@property (nonatomic,retain) NSString *valueChosen;

- (id)initWithListItems:(NSArray*)items fieldApi:(NSString*)apiName type:(NSString*)fieldtype selectValue:(NSString*)value frame:(CGRect)rect updateListener:(id)newListener;


@end


