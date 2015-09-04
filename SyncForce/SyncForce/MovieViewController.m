//
//  MovieViewController.m
//  Datagrid
//
//  Created by Gaeasys Admin on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MovieViewController.h"
#import "MoviePlayerUserPrefs.h"
#import "AppDelegate.h"

CGFloat kMovieViewOffsetX = 0.0;
CGFloat kMovieViewOffsetY = 0.0;

@interface MovieViewController (OverlayView)

-(void)addOverlayView;
-(void)removeOverlayView;
-(void)resizeOverlayWindow;

@end

@interface MovieViewController(MovieControllerInternal)
-(void)createAndPlayMovieForURL:(NSURL *)movieURL sourceType:(MPMovieSourceType)sourceType;
-(void)applyUserSettingsToMoviePlayer;
-(void)moviePlayBackDidFinish:(NSNotification*)notification;
-(void)loadStateDidChange:(NSNotification *)notification;
-(void)moviePlayBackStateDidChange:(NSNotification*)notification;
-(void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification;
-(void)installMovieNotificationObservers;
-(void)removeMovieNotificationHandlers;
-(void)deletePlayerAndNotificationObservers;
@end

@interface MovieViewController (ViewController)
-(void)removeMovieViewFromViewHierarchy;
@end

@implementation MovieViewController(ViewController)

#pragma mark View Controller

/* Sent to the view controller after the user interface rotates. */
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
	/* Size movie view to fit parent view. */
	CGRect viewInsetRect = CGRectInset ([self.view bounds],
										kMovieViewOffsetX,
										kMovieViewOffsetY );
	[[[self moviePlayerController] view] setFrame:viewInsetRect];
    
    /* Size the overlay view for the current orientation. */
	[self resizeOverlayWindow];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (void)viewDidUnload
{
    [self deletePlayerAndNotificationObservers];
    
    [super viewDidUnload];
}

/* Notifies the view controller that its view is about to be become visible. */
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    
    /* Size the overlay view for the current orientation. */
	[self resizeOverlayWindow];
    /* Update user settings for the movie (in case they changed). */
    [self applyUserSettingsToMoviePlayer];
}

/* Notifies the view controller that its view is about to be dismissed, 
 covered, or otherwise hidden from view. */
- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
    /* Remove the movie view from the current view hierarchy. */
	[self removeMovieViewFromViewHierarchy];
    /* Removie the overlay view. */
	[self removeOverlayView];
    /* Remove the background view. */
	[self.backgroundView removeFromSuperview];
    
    /* Delete the movie player object and remove the notification observers. */
    [self deletePlayerAndNotificationObservers];
}

- (void)dealloc 
{	
    [self setMoviePlayerController:nil];
    self.imageView = nil;
    self.movieBackgroundImageView = nil;
    self.backgroundView = nil;
    self.overlayController = nil;
    
    [super dealloc];
}

/* Remove the movie view from the view hierarchy. */
-(void)removeMovieViewFromViewHierarchy
{
    MPMoviePlayerController *player = [self moviePlayerController];
    
	[player.view removeFromSuperview];
}

#pragma mark Error Reporting

-(void)displayError:(NSError *)theError
{
	if (theError)
	{
		UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"ERROR", Nil)
                              message: [theError localizedDescription]
                              delegate: nil
                              cancelButtonTitle:NSLocalizedString(@"OK", Nil) 
                              otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

@end

#pragma mark -
@implementation MovieViewController (OverlayView)


/* Add an overlay view on top of the movie. This view will display movie
 play states and includes a 'Close Movie' button. */
-(void)addOverlayView
{
    MPMoviePlayerController *player = [self moviePlayerController];
    
    if (!([self.overlayController.view isDescendantOfView:self.view])
        && ([player.view isDescendantOfView:self.view])) 
    {
        // add an overlay view to the window view hierarchy
        [self.view addSubview:self.overlayController.view];
    }
}

/* Remove overlay view from the view hierarchy. */
-(void)removeOverlayView
{
	[self.overlayController.view removeFromSuperview];
}

-(void)resizeOverlayWindow
{
	CGRect frame = self.overlayController.view.frame;
	frame.origin.x = round((self.view.frame.size.width - frame.size.width) / 2.0);
	frame.origin.y = round((self.view.frame.size.height - frame.size.height) / 2.0);
	self.overlayController.view.frame = frame;
}

@end

#pragma mark -
@implementation MovieViewController

@synthesize moviePlayerController;

@synthesize imageView;
@synthesize movieBackgroundImageView;
@synthesize backgroundView;
@synthesize overlayController;

@synthesize appDelegate;

- (id)initWithFilePath:(NSString *)pfilepath{
    [super init];    
    self.appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [self playMovieFile:[NSURL fileURLWithPath:pfilepath]];
    
    return self;
}


/* Action method for the overlay view 'Close Movie' button.
 Remove the movie view and overlay view from the window,
 dispose the movie object and remove the notification
 handlers. */
-(IBAction)overlayViewCloseButtonPress:(id)sender
{
	[[self moviePlayerController] stop];
    
	[self removeMovieViewFromViewHierarchy];
    
	[self removeOverlayView];
	[self.backgroundView removeFromSuperview];
    
    [self deletePlayerAndNotificationObservers];
}

/*  
 Called by the MoviePlayerAppDelegate (UIApplicationDelegate protocol) 
 applicationWillEnterForeground when the app is about to enter
 the foreground.
 */
- (void)viewWillEnterForeground
{
	/* Set the movie object settings (control mode, background color, and so on) 
     in case these changed. */
	[self applyUserSettingsToMoviePlayer];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        NSLog(@"Portrait");
    } else if (UIInterfaceOrientationIsLandscape(orientation)){
         NSLog(@"Landscape");
    }
}

-(void)viewDidLoad{
    [self didRotateFromInterfaceOrientation:[super interfaceOrientation]];
}

#pragma mark Play Movie Actions

/* Called soon after the Play Movie button is pressed to play the local movie. */
-(void)playMovieFile:(NSURL *)movieFileURL
{
    [self createAndPlayMovieForURL:movieFileURL sourceType:MPMovieSourceTypeFile];   
    [self willRotateToInterfaceOrientation:[self interfaceOrientation] duration:1];
}

/* Returns a URL to a local movie in the app bundle. */
-(NSURL *)localMovieURL
{
	NSURL *theMovieURL = nil;
	NSBundle *bundle = [NSBundle mainBundle];
	if (bundle) 
	{
		NSString *moviePath = [bundle pathForResource:@"Movie" ofType:@"m4v"];
		if (moviePath)
		{
			theMovieURL = [NSURL fileURLWithPath:moviePath];
		}
	}
    return theMovieURL;
}

/* Button presses for the 'Play Movie' button. */
-(IBAction)playMovieButtonPressed:(id)sender
{
	/* Play the movie at the specified URL. */
   [self playMovieFile:[self localMovieURL]];
}

@end

#pragma mark -
#pragma mark Movie Player Controller Methods
#pragma mark -

@implementation MovieViewController (MovieControllerInternal)

#pragma mark Create and Play Movie URL

/*
 Create a MPMoviePlayerController movie object for the specified URL and add movie notification
 observers. Configure the movie object for the source type, scaling mode, control style, background
 color, background image, repeat mode and AirPlay mode. Add the view containing the movie content and 
 controls to the existing view hierarchy.
 */
-(void)createAndConfigurePlayerWithURL:(NSURL *)movieURL sourceType:(MPMovieSourceType)sourceType 
{    
    /* Create a new movie player object. */
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    
    if (player) 
    {
        /* Save the movie object. */
        [self setMoviePlayerController:player];
        
        /* Register the current object as an observer for the movie
         notifications. */
        [self installMovieNotificationObservers];
        
        /* Specify the URL that points to the movie file. */
        [player setContentURL:movieURL];        
        
        /* If you specify the movie type before playing the movie it can result 
         in faster load times. */
        [player setMovieSourceType:sourceType];
        
        /* Apply the user movie preference settings to the movie player object. */
        [self applyUserSettingsToMoviePlayer];
        
        /* Add a background view as a subview to hide our other view controls 
         underneath during movie playback. */
        [self.view addSubview:self.backgroundView];
        
        CGRect viewInsetRect = CGRectInset ([self.view bounds],
                                            kMovieViewOffsetX,
                                            kMovieViewOffsetY );
        /* Inset the movie frame in the parent view frame. */
        [[player view] setFrame:viewInsetRect];
        
        [player view].backgroundColor = [UIColor lightGrayColor];
        
        /* To present a movie in your application, incorporate the view contained 
         in a movie player’s view property into your application’s view hierarchy. 
         Be sure to size the frame correctly. */
        [self.view addSubview: [player view]];        
    }    
}

/* Load and play the specified movie url with the given file type. */
-(void)createAndPlayMovieForURL:(NSURL *)movieURL sourceType:(MPMovieSourceType)sourceType
{
    [self createAndConfigurePlayerWithURL:movieURL sourceType:sourceType];
    
    /* Play the movie! */
    [[self moviePlayerController] play];
}

#pragma mark Movie Notification Handlers

/*  Notification called when the movie finished playing. */
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    NSNumber *reason = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey]; 
	switch ([reason integerValue]) 
	{
            /* The end of the movie was reached. */
		case MPMovieFinishReasonPlaybackEnded:
            /*
             Add your code here to handle MPMovieFinishReasonPlaybackEnded.
             */
            NSLog(@"MPMovieFinishReasonPlaybackEnded");
			break;
            
            /* An error was encountered during playback. */
		case MPMovieFinishReasonPlaybackError:
            NSLog(@"An error was encountered during playback");
            [self performSelectorOnMainThread:@selector(displayError:) withObject:[[notification userInfo] objectForKey:@"error"] 
                                waitUntilDone:NO];
            [self removeMovieViewFromViewHierarchy];
            [self removeOverlayView];
            [self.backgroundView removeFromSuperview];
            NSLog(@"MPMovieFinishReasonPlaybackError");
			break;
            
            /* The user stopped playback. */
		case MPMovieFinishReasonUserExited:
            [self removeMovieViewFromViewHierarchy];
            [self removeOverlayView];
            [self.backgroundView removeFromSuperview];
            [self.navigationController popViewControllerAnimated:true];
            NSLog(@"MPMovieFinishReasonUserExited");
			break;
            
		default:
			break;
	}
}

/* Handle movie load state changes. */
- (void)loadStateDidChange:(NSNotification *)notification 
{   
	MPMoviePlayerController *player = notification.object;
	MPMovieLoadState loadState = player.loadState;	
    
	/* The load state is not known at this time. */
	if (loadState & MPMovieLoadStateUnknown)
	{
        [self.overlayController setLoadStateDisplayString:@"n/a"];
        
        [overlayController setLoadStateDisplayString:NSLocalizedString(@"UNKNOWN", Nil)];       
	}
	
	/* The buffer has enough data that playback can begin, but it 
	 may run out of data before playback finishes. */
	if (loadState & MPMovieLoadStatePlayable)
	{
        [overlayController setLoadStateDisplayString:NSLocalizedString(@"PLAYABLE", Nil)];
	}
	
	/* Enough data has been buffered for playback to continue uninterrupted. */
	if (loadState & MPMovieLoadStatePlaythroughOK)
	{
        // Add an overlay view on top of the movie view
        [self addOverlayView];
        
        [overlayController setLoadStateDisplayString:NSLocalizedString(@"PLAYTHROUGH_OK", Nil)];
	}
	
	/* The buffering of data has stalled. */
	if (loadState & MPMovieLoadStateStalled)
	{
        [overlayController setLoadStateDisplayString:NSLocalizedString(@"STALLED", Nil)];
	}
}

/* Called when the movie playback state has changed. */
- (void) moviePlayBackStateDidChange:(NSNotification*)notification
{
	MPMoviePlayerController *player = notification.object;
    
	/* Playback is currently stopped. */
	if (player.playbackState == MPMoviePlaybackStateStopped) 
	{
        [overlayController setPlaybackStateDisplayString:NSLocalizedString(@"STOPPED", Nil)];
	}
	/*  Playback is currently under way. */
	else if (player.playbackState == MPMoviePlaybackStatePlaying) 
	{
        [overlayController setPlaybackStateDisplayString:NSLocalizedString(@"PLAYING", Nil)];
	}
	/* Playback is currently paused. */
	else if (player.playbackState == MPMoviePlaybackStatePaused) 
	{
        [overlayController setPlaybackStateDisplayString:NSLocalizedString(@"PAUSED", Nil)];
	}
	/* Playback is temporarily interrupted, perhaps because the buffer 
	 ran out of content. */
	else if (player.playbackState == MPMoviePlaybackStateInterrupted) 
	{
        [overlayController setPlaybackStateDisplayString:NSLocalizedString(@"INTERRUPTED", Nil)];
	}
}

/* Notifies observers of a change in the prepared-to-play state of an object 
 conforming to the MPMediaPlayback protocol. */
- (void) mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
	// Add an overlay view on top of the movie view
    [self addOverlayView];
}

#pragma mark Install Movie Notifications

/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
    MPMoviePlayerController *player = [self moviePlayerController];
    
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(loadStateDidChange:) 
                                                 name:MPMoviePlayerLoadStateDidChangeNotification 
                                               object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(moviePlayBackDidFinish:) 
                                                 name:MPMoviePlayerPlaybackDidFinishNotification 
                                               object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(mediaIsPreparedToPlayDidChange:) 
                                                 name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification 
                                               object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(moviePlayBackStateDidChange:) 
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification 
                                               object:player];        
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationHandlers
{    
    MPMoviePlayerController *player = [self moviePlayerController];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:player];
}

/* Delete the movie player object, and remove the movie notification observers. */
-(void)deletePlayerAndNotificationObservers
{
    [self removeMovieNotificationHandlers];
    [self setMoviePlayerController:nil];
}

#pragma mark Movie Settings

/* Apply user movie preference settings (these are set from the Settings: iPhone Settings->Movie Player)
 for scaling mode, control style, background color, repeat mode, application audio session, background
 image and AirPlay mode. 
 */
-(void)applyUserSettingsToMoviePlayer
{
    MPMoviePlayerController *player = [self moviePlayerController];
    if (player) 
    {
        
        player.scalingMode = [MoviePlayerUserPrefs scalingModeUserSetting];
        player.controlStyle =[MoviePlayerUserPrefs controlStyleUserSetting];	
        player.backgroundView.backgroundColor = [MoviePlayerUserPrefs backgroundColorUserSetting];
        player.repeatMode = [MoviePlayerUserPrefs repeatModeUserSetting];
        player.useApplicationAudioSession = [MoviePlayerUserPrefs audioSessionUserSetting];
        if ([MoviePlayerUserPrefs backgroundImageUserSetting] == YES)
        {
            [self.movieBackgroundImageView setFrame:[self.view bounds]];
            [player.backgroundView addSubview:self.movieBackgroundImageView];
        }
        else
        {
            [self.movieBackgroundImageView removeFromSuperview];
        }
        
        /* Indicate the movie player allows AirPlay movie playback. */
        //player.allowsAirPlay = YES;        
    }
}

@end
