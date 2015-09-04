//
//  MailToFellow.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/26/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "MailToFellow.h"

@implementation MailToFellow
@synthesize controller;


- (id)initWithController:(UIViewController *)newController {
    self = [super init];
    self.controller = newController;
    return self;
}
- (NSString *)getCompanyName{
    
    NSString *company=[PropertyManager read:@"Login"];
    
    if ([company rangeOfString:@"/"].location == NSNotFound) {
        company=company;
    }else{
        company=[[company componentsSeparatedByString:@"/"] objectAtIndex:0];
    }
    return [company uppercaseString];
}

- (NSString *)getDeviceName{
    
    NSString *device=@"";
    //determine device's type ipad/iphone
    BOOL iPad = NO;
#ifdef UI_USER_INTERFACE_IDIOM
    iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#endif
    device = [NSString stringWithFormat:@"CRM %@",iPad?@"ipad":@"iphone"];
    return device;
}

- (void) sendMailToFellow {
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
    NSString *url=[[PropertyManager read:@"URL"] substringWithRange:NSMakeRange(15, 9)];
    [report appendFormat:@"Company : %@ \n",[self getCompanyName]];
    [report appendFormat:@"URL : %@ \n",url];
    [report appendFormat:@"Product Name : %@ \n",[self getDeviceName]];
    
        
    MFMailComposeViewController* mailController = [[MFMailComposeViewController alloc] init];
    mailController.mailComposeDelegate = self;
    [mailController setToRecipients:[NSMutableArray arrayWithObject:@"sales@fellow-consulting.de"]];
    [mailController setSubject:@"License Activation"];
    [mailController setMessageBody:report isHTML:NO]; 
    if (mailController) [self.controller presentModalViewController:mailController animated:YES];
    [mailController release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
    [self.controller dismissModalViewControllerAnimated:YES];
}


@end
