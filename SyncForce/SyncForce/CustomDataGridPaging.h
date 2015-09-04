//
//  CustomDataGridPaging.h
//  Datagrid
//
//  Created by Gaeasys on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomDataGridRow.h"

@interface CustomDataGridPaging : UIViewController {
    
    UIToolbar       *myToolbar;
    UIBarButtonItem *bntPrev;
    UIBarButtonItem *bntNext;
    UIBarButtonItem *record;
    
}

@property (nonatomic, retain) id bntTarget;

@property (nonatomic, retain) UIBarButtonItem *record;
@property (nonatomic, retain) UIBarButtonItem *bntPrev;
@property (nonatomic, retain) UIBarButtonItem *bntNext;

-(id)initWithPopulate:(id)target frame:(CGRect)rect;

@end
