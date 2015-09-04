//
//  SyncController.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/25/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "SyncController.h"


@implementation SyncController

@synthesize listControllers;
@synthesize mainController;
@synthesize synchronize;

static SyncController *_sharedSingleton = nil;

+ (SyncController *)getInstance
{
	@synchronized([SyncController class])
	{
		if (!_sharedSingleton)
			[[self alloc] init];
        
		return _sharedSingleton;
	}
    
	return nil;
}

+(id)alloc
{
	@synchronized([SyncController class])
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
        listControllers = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}

- (void)syncConfig {
    [TabTools buildTabs:self.mainController];
}


- (void)syncEnd:(NSString *)error sendReport:(BOOL)sendReport {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [synchronize refresh];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if (error) {
        if ([error isEqualToString:@"Invalid License"]){
            NSString *errMessage = NSLocalizedString(@"NO_MORE_SYNC", nil);
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"SYNC_ERR", nil)
                                  message:errMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:NSLocalizedString(@"REQUEST_LICENSE", nil), Nil];
            alert.tag = 2;
            [alert show];
            [alert release];
        } else {
            UIAlertView *alert;
            if (sendReport) {
                alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SYNC_ERR", nil) message:error delegate:self cancelButtonTitle:@"OK" otherButtonTitles:NSLocalizedString(@"SEND_ERR_REPT", nil), nil];
            } else {
                alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SYNC_ERR", nil) message:error delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            }
            alert.tag = 1;
            [alert show];
            [alert release];       
        }
    }
}

- (void)syncStart {
    //when sync in progress keep app awake
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [synchronize refresh];
}

- (void)syncProgress:(NSString *)entity {

    [synchronize refresh];
    if (entity != nil) {
        for (ListViewController *controller in listControllers) {
            if ([controller.entity rangeOfString:entity].length > 0) {
                [controller refreshList:Nil scope:Nil];
            }
        }
     
    }
    
}


- (void)addListController:(ListViewController *)listController {
    [listControllers addObject:listController];

}
- (void)clearListControllers {
    [listControllers removeAllObjects];
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
