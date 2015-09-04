//
//  PickListSelectController.h
//  CRMiOS
//
//  Created by Sy Pauv on 5/10/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PicklistManager.h"
#import "Configuration.h"
#import "SalesStageManager.h"
#import "UpdateListener.h"
#import "IndustryManager.h"
#import "FieldsManager.h"
#import "CurrentUserManager.h"

@interface PickListSelectController : UITableViewController {
    NSString *field;
    Item *item;
    NSArray *pickList;
    NSString *currentSelection;
    UITableViewCell *currentEditing;
    NSObject<UpdateListener> *updateListener;
    
}
@property (nonatomic,retain) NSObject<UpdateListener> *updateListener;
@property (nonatomic,retain) NSString *currentSelection;
@property (nonatomic,retain) NSArray *pickList;
@property (nonatomic,retain) NSString *field;
@property (nonatomic,retain) Item *item;

- (id)init:(NSString *)newField item:(Item *)newItem updateListener:(NSObject<UpdateListener> *)newListener;



@end
