//
//  ListRelationViewController.h
//  CRMiOS
//
//  Created by Sy Pauv on 5/27/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntityInfo.h"
#import "Configuration.h"
#import "DetailViewController.h"
#import "UpdateListener.h"
#import "IphoneSublistDetail.h"
#import "Item.h"

@interface ListRelationViewController : UITableViewController<UpdateListener> {
    
    NSArray *relatedItems;
    NSArray *groups;
    NSString *subtype;
    
}
@property (nonatomic, retain) NSArray *relatedItems;
@property (nonatomic, retain) NSArray *groups;
@property (nonatomic, retain) NSString *subtype;

- (id)initWithRelSub:(RelationSub *)relSub refValue:(NSString *)refValue;

@end
