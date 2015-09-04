//
//  RecordTypeChooserViewController.h
//  SyncForce
//
//  Created by Gaeasys on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordTypeListViewController.h"

@interface RecordTypeChooserViewController : UITableViewController
{
    NSArray *listItems;
    NSString *entityName;
    id  parentCon;
}
@property (nonatomic,retain) NSString *entityName;

- (id)initWIthListItems:(NSArray*)items parent:(id)parent entityName:(NSString*)entity;

@end