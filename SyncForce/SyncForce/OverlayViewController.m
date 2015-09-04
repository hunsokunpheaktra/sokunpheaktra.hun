//
//  OverlayViewController.m
//  Datagrid
//
//  Created by Gaeasys Admin on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OverlayViewController.h"


@implementation OverlayViewController
@synthesize moviePlaybackStateText, movieLoadStateText;

#pragma mark -
#pragma mark Display Movie Status Strings

/* Movie playback state display string. */
-(void)setPlaybackStateDisplayString:(NSString *)playBackText
{
	self.moviePlaybackStateText.text = playBackText;
}
//
/* Movie load state display string. */
-(void)setLoadStateDisplayString:(NSString *)loadStateText;
{
	self.movieLoadStateText.text = loadStateText;
}

@end
