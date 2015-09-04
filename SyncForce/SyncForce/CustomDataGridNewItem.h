//
//  CustomDataGridNewItem.h
//  SyncForce
//
//  Created by Gaeasys on 10/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import "CustomDataGrid.h"

@interface CustomDataGridNewItem : UIViewController {
    Item   *myItem;
    NSString   *entityName;
    UIButton   *bntSave;
}


@property (nonatomic,retain) Item *myItem;
@property (nonatomic,retain) UIButton *bntSave;
@property (nonatomic,retain) NSString *entityName;
@property (nonatomic,retain) id bntTarget;

- (id) initWithObjectName:(NSString *)entityName target:(id)target;

@end
