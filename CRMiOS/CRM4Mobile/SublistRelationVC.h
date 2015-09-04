//
//  SublistRelationVC.h
//  CRMiOS
//
//  Created by Arnaud on 06/05/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntityInfo.h"
#import "Configuration.h"
#import "DetailViewController.h"
#import "UpdateListener.h"
#import "IphoneSublistDetail.h"
#import "Item.h"


@interface SublistRelationVC : UITableViewController<UpdateListener> {
    
    NSArray *related;
    NSString *sublist;
    Item *parentItem;
}

@property (nonatomic, retain) Item *parentItem;
@property (nonatomic, retain) NSString *sublist;
@property (nonatomic, retain) NSArray *related;

- (id)initWithSublist:(NSString *)sublist parent:(Item *)parentItem related:(NSArray *)related;


@end
