//
//  ManualReminderInput.h
//  Parcel
//
//  Created by Sy Pauv on 12/5/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PicklistPopupShowView.h"
#import "UpdateListener.h"

@interface ManualReminderInput : UITableViewController<UpdateListener>{
    
}
@property (nonatomic, retain) NSString *option;
@property (nonatomic, retain) NSString *amount;
@property (nonatomic, retain) NSString *defalutValue;
@property (nonatomic, retain) NSObject<UpdateListener> *listener;


@end
