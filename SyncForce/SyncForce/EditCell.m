//
//  EditCell.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/11/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "EditCell.h"
#import "EditTool.h"

@implementation EditCell


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
    
	for (int x = 0; x< [rowItems count]; x++) {
      if ([[rowItems objectAtIndex:x] isKindOfClass:[EditTool class]])     
        [self.contentView addSubview:[[rowItems objectAtIndex:x] control]];
      else [self.contentView addSubview:[rowItems objectAtIndex:x]];   
    }
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [[self subviews] lastObject];

    int nbItem;
    float start_x = 15;
    float width = self.contentView.frame.size.width/4;
    
    for (int x = 0; x< [rowItems count]; x++) {
        
        CGRect rect;
        
        if ([[rowItems objectAtIndex:x] isKindOfClass:[EditTool class]]) {     
            nbItem = [[rowItems objectAtIndex:x] index];
            rect = [[[rowItems objectAtIndex:x] control] frame];
            rect.size.width = width;
            if(nbItem==1) rect.size.width = [[[[[rowItems objectAtIndex:x] control] subviews] lastObject] isKindOfClass:[UITextField class]] ? width*2 + width/3 : width*2;
            rect.origin.x = (x==1) ? width+start_x : width *x;
            [[[rowItems objectAtIndex:x] control] setFrame:rect];

            int count = 0;
            for (UIView*view in [[[rowItems objectAtIndex:x] control] subviews]) {

                int nbOfFieldInControl = [[[[rowItems objectAtIndex:x] control] subviews] count] - [[[rowItems objectAtIndex:x] control] tag] ;
                
                CGRect frame = view.frame;
                frame.origin.x = count*(rect.size.width/nbOfFieldInControl);
                
                if(nbItem==1) { 
                    if ([view isKindOfClass:[UITextField class]])
                        rect.size.width = width*2 + width/3;
                    else rect.size.width = width*2; 
                }   
                
                if([view isKindOfClass:[UITableView class]]) {
                    frame.origin.y = -5;
                    frame.size.height = 44;
                    frame.size.width =(width/nbOfFieldInControl)+10;
                    count= count + 1;
                }else if ([view isKindOfClass:[UIButton class]]) { 
                    UIButton*bn = (UIButton*)view;
                    if(bn.tag == 0){ 
                        frame.origin.x = 10.0;
                        count= count + 1;
                    }    
                    else {
                        frame.origin.x = -5.0;
                        frame.origin.y = frame.origin.y + 1.0;
                    }   
                }   
                
                view.frame = frame;

            }
            
        }else {
            rect = [[rowItems objectAtIndex:x] frame];
            rect.origin.x = (x==0) ? start_x : width*x;
            rect.size.width = width - start_x;
            [[rowItems objectAtIndex:x] setFrame:rect];

        }
        
       
    }
    
}


@end
