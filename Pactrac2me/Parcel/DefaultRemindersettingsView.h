//
//  DefaultDemindersettingsView.h
//  Parcel
//
//  Created by Sy Pauv on 12/4/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReminderListener.h"
#import "ManualReminderInput.h"
#import "UpdateListener.h"
#import "Item.h"

@interface DefaultRemindersettingsView : UITableViewController<UpdateListener>
@property (nonatomic,retain) NSArray *settings;
@property (nonatomic,retain) NSString *defaultsetting;
@property (nonatomic,retain) NSObject<ReminderListener> *listener;
@property (nonatomic, assign) BOOL isCustom;
@property (nonatomic, retain) NSString *customValue;
@property (nonatomic, retain) Item *workItem;

-(id)inithWithItem:(Item *)item;

@end
