//
//  MovieViewController.h
//  Datagrid
//
//  Created by Gaeasys Admin on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaPlayer/MediaPlayer.h"

#import "OverlayViewController.h"
#import "AppDelegate.h"
#import "MediasViewer.h"

@class ImageView;
@interface MovieViewController : UIViewController {
@private
    MPMoviePlayerController *moviePlayerController;
    
    IBOutlet AppDelegate *appDelegate;
    
	IBOutlet ImageView *imageView;
	IBOutlet UIImageView *movieBackgroundImageView;
	IBOutlet UIView *backgroundView;	
	IBOutlet OverlayViewController *overlayController;
}
@property (nonatomic, retain) IBOutlet ImageView *imageView;
@property (nonatomic, retain) IBOutlet UIImageView *movieBackgroundImageView;
@property (nonatomic, retain) IBOutlet UIView *backgroundView;
@property (nonatomic, retain) IBOutlet OverlayViewController *overlayController;

@property (nonatomic, retain) IBOutlet AppDelegate *appDelegate;

@property (retain) MPMoviePlayerController *moviePlayerController;

- (id)initWithFilePath:(NSString *)pfilepath;
- (IBAction)overlayViewCloseButtonPress:(id)sender;
- (void)viewWillEnterForeground;
- (void)playMovieFile:(NSURL *)movieFileURL;

-(IBAction)playMovieButtonPressed:(id)sender;

@end
