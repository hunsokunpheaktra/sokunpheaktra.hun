//
//  PadSyncController.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/27/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "PadSyncController.h"


@implementation PadSyncController

@synthesize listControllers;
@synthesize mainController;
@synthesize syncController;
@synthesize prefSyncControler;

static PadSyncController *_sharedSingleton = nil;

+ (PadSyncController *)getInstance
{
	@synchronized([PadSyncController class])
	{
		if (!_sharedSingleton)
			[[self alloc] init];
        
		return _sharedSingleton;
	}
    
	return nil;
}

+(id)alloc
{
	@synchronized([PadSyncController class])
	{
		NSAssert(_sharedSingleton == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedSingleton = [super alloc];
		return _sharedSingleton;
	}
    
	return nil;
}

- (void) dealloc
{
    [super dealloc];
}

- (id)init {
    self = [super init]; 
    if (self) {
        self.listControllers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addListController:(PadMainViewController *)controller {
    [self.listControllers addObject:controller];
}

- (void)clearListControllers {
    [self.listControllers removeAllObjects];
}


- (void)syncEnd:(NSString *)error sendReport:(BOOL)sendReport {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.syncController refresh];
    if (error) {
        if ([error isEqualToString:@"Invalid License"]){
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"SYNC_ERR", nil)
                                  message:NSLocalizedString(@"NO_MORE_SYNC", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:NSLocalizedString(@"REQUEST_LICENSE", nil), Nil];
            alert.tag = 2;
            [alert show];
            [alert release];
            
        } else {
            UIAlertView *alert;
            if (sendReport) {
                alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SYNC_ERR", nil)
                            message:error delegate:self cancelButtonTitle:@"OK" otherButtonTitles:NSLocalizedString(@"SEND_ERR_REPT", nil), nil];
            } else {
                alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SYNC_ERR", nil)
                            message:error delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            }
            alert.tag = 1;
            [alert show];
            [alert release];
        
        }
        

    } else {
        [self.prefSyncControler refresh]; 
    }
}

- (void)syncStart {
    //when sync in progress keep app awake
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.syncController refresh];

}

- (void)syncProgress:(NSString *)entity {
    [self.syncController refresh];
    
    if (entity != Nil) {
        for (PadMainViewController *listController in listControllers) {
            NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:listController.subtype];
            if ([[sinfo entity] rangeOfString:entity].length > 0) {
                [listController refresh];
            }
        }
    }
}

- (void)syncConfig {

    [PadTabTools buildTabs:self.mainController];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (alertView.tag) {
        case 1:
            if (buttonIndex == 1) {
                ErrorReport *report = [[ErrorReport alloc] initWithController:self.mainController];
                [report sendErrorReport];
            }
            break;
        case 2:
            if (buttonIndex == 1) {
                MailToFellow *report = [[MailToFellow alloc] initWithController:self.mainController];
                [report sendMailToFellow];
            }
            break;
        default:
            break;
    }
    
    
}

@end
