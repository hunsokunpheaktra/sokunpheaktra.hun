//
//  ImageView.m
//  Datagrid
//
//  Created by Gaeasys Admin on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageView.h"


@implementation ImageView
@synthesize viewController;

/* Touches to the Image view will start the movie playing. */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    UITouch* touch = [touches anyObject];
    if (touch.phase == UITouchPhaseBegan)
    {
		/* play the movie! */
        [self.viewController playMovieButtonPressed:self];
    }    
}

@end
