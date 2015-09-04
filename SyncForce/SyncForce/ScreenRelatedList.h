//
//  ScreenRelatedList.h
//  SyncForce
//
//  Created by Gaeasys on 11/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ObjectDetailViewController.h"
#import "CustomDataGrid.h"

@class ObjectDetailViewController;

@class CustomDataGrid;

@interface ScreenRelatedList : UIViewController {
    
    NSString* pType;
    NSString* pId;
    NSString* cType;
    NSArray* relatedList;
    
    ObjectDetailViewController *parent;
    CustomDataGrid *dataGrid;
    
}

@property (retain, nonatomic) CustomDataGrid *dataGrid;
@property (retain, nonatomic) ObjectDetailViewController *parent;
@property (retain, nonatomic) NSString* pType;
@property (retain, nonatomic) NSString* pId;
@property (retain, nonatomic) NSString* cType;
@property (retain, nonatomic) NSArray* relatedList;

-(id)initWithData:(NSString*) parentType childType:(NSString *)cType parentId:(NSString*)parentId parentController:(ObjectDetailViewController*)newParent;

- (void)initView;

@end
