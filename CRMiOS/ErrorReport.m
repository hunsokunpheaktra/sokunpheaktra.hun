//
//  ErrorReport.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 6/9/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "ErrorReport.h"


@implementation ErrorReport

@synthesize controller;


- (id)initWithController:(UIViewController *)newController {
    self = [super init];
    self.controller = newController;
    return self;
}

- (void)dealloc {
    self.controller = nil;
    [super dealloc];
}

- (void) sendErrorReport {
    NSMutableString *report = [[NSMutableString alloc] initWithCapacity:1];
    NSString *versionNumber =  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

    
    //get device information
    NSString *deviceInfo;
    UIDevice* currentDevice = [UIDevice currentDevice];
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad)  {
        deviceInfo = [NSString stringWithFormat:@"iPad - IOS Version %@",currentDevice.systemVersion];
    } else if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone){
        deviceInfo = [NSString stringWithFormat:@"iPhone - IOS Version %@",currentDevice.systemVersion];
    } else {
        deviceInfo = [NSString stringWithFormat:@"iPod - IOS Version %@",currentDevice.systemVersion];
    }

    [report appendFormat:@"%@\n",deviceInfo];
    [report appendString:[NSString stringWithFormat:@"Version %@ \n", versionNumber]];
    
    for (NSDictionary *item in [LogManager read]) {
        [report appendString:[item objectForKey:@"date"]];
        [report appendString:@" - "];
        [report appendString:[item objectForKey:@"log"]];
        [report appendString:@"\n"];
    }
    MFMailComposeViewController* mailController = [[MFMailComposeViewController alloc] init];
    mailController.mailComposeDelegate = self;
    [mailController setToRecipients:[NSMutableArray arrayWithObject:@"support@crm-gadget.com"]];
    [mailController setSubject:@"Synchronization Error Report"];
    [mailController setMessageBody:report isHTML:NO]; 
    if (mailController) [self.controller presentModalViewController:mailController animated:YES];
    [mailController release];
    [report release];
}

- (void)mailComposeController:(MFMailComposeViewController*)pcontroller
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
    [pcontroller dismissModalViewControllerAnimated:YES];
}

- (void)sendMail {

    MFMailComposeViewController* mailController = [[MFMailComposeViewController alloc] init];
    mailController.mailComposeDelegate = self;
    NSString *email = [Configuration getProperty:@"aboutMail"];
    [mailController setToRecipients:[NSArray arrayWithObject:email]];
    [mailController setSubject:@"CRM4Mobile feedback"];
    if (mailController) [self.controller presentModalViewController:mailController animated:YES];
    [mailController release];

}

@end
