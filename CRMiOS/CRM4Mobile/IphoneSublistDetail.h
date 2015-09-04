//
//  IphoneSublistDetail.h
//  CRMiOS
//
//  Created by Sy Pauv on 11/21/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import "SublistManager.h"
#import "UITools.h"
#import "Base64.h"


@interface IphoneSublistDetail : UITableViewController {
    Item *parentItem;
    SublistItem *item;
    NSArray *listFields;
}
@property (nonatomic, retain) Item *parentItem;
@property (nonatomic, retain) SublistItem *item;

- (id)initWithItem:(SublistItem *)newItem parent:(Item *)parentItem;

@end
