//
//  CustomDataGridRow.m
//  Datagrid
//
//  Created by Gaeasys on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomDataGridRow.h"
#import "DataType.h"

@implementation CustomDataGridRow

@synthesize itemPadding,scaleToFillRow,rowItems;

- (void)dealloc
{
    [rowItems release];
    [super dealloc];
}

- (NSArray *)rowItems
{
	return (rowItems);
}

- (void)setRowItems:(NSArray *)RowItems
{
	for (UIView *subview in self.contentView.subviews)
    {
		[subview removeFromSuperview];
    }
    
	[RowItems retain];
	[rowItems release];
    
	rowItems = RowItems;
    
	for (CustomDataGridRowItem *rowItem in rowItems){
        [self.contentView addSubview:rowItem.control];
    }
    
}



#pragma mark - View lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier itemPadding:(int)padding scaleToFill:(BOOL)scale;
{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
		itemPadding = padding;
		scaleToFillRow = scale;
    }
    
    return self;
}

- (void)layoutSubviews{
    int	start_x = 25;
    
	[super layoutSubviews];
	
    for (CustomDataGridRowItem *nextItem in rowItems){
        CGRect frame = nextItem.control.frame;
        
	   	frame.size.width = nextItem.baseSize.width ;
	   	frame.size.height = nextItem.baseSize.height; 
        
        frame.origin.x = start_x;
        frame.origin.y = nextItem.control.frame.origin.y;
        
        nextItem.control.frame = frame;
        
        if (!nextItem.isView) {
            start_x += (nextItem.baseSize.width + self.itemPadding +15);
        }else  start_x += (nextItem.baseSize.width + self.itemPadding);

        if (nextItem.columnType == TYPE_BOOLEAN) {
           nextItem.control.frame = CGRectMake(frame.origin.x+35 - frame.size.width/4, frame.origin.y, frame.size.width, frame.size.height);
        }
        
        
        if ((nextItem.columnType == TYPE_REFERENCE || nextItem.columnType == TYPE_PICKLIST || nextItem.columnType == TYPE_DATETIME || nextItem.columnType == TYPE_DATE) && !nextItem.isView && nextItem.updateable == YES) {
            nextItem.control.frame = CGRectMake(frame.origin.x-10, frame.origin.y, frame.size.width+20, frame.size.height);
        }
   
    }
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
