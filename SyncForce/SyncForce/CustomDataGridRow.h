//
//  CustomDataGridRow.h
//  Datagrid
//
//  Created by Gaeasys on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomDataGridRowItem.h"

@interface CustomDataGridRow : UITableViewCell {
    
    int     itemPadding;			
	BOOL    scaleToFillRow;	
    NSArray *rowItems;
}

@property (nonatomic, retain) NSArray *rowItems;
@property (nonatomic, assign, readonly) int itemPadding;
@property(nonatomic, assign, readonly) BOOL scaleToFillRow;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier itemPadding:(int)padding scaleToFill:(BOOL)scale;

@end

