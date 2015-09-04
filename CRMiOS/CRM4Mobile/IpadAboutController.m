//
//  IpadAboutController.m
//  CRMiOS
//
//  Created by Sy Pauv on 6/8/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "IpadAboutController.h"


@implementation IpadAboutController

@synthesize description, logo;

- (void)dealloc {
    self.description = nil;
    self.logo = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView
{
    
    self.title = NSLocalizedString(@"ABOUT", @"about");
    UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self setView:mainView];
    [mainView release];
    

    self.logo = [[[UIImageView alloc] init] autorelease];
    self.logo.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.logo];
    
    UILabel *appName = [[UILabel alloc] initWithFrame:CGRectMake(250, 70, 480, 56)];
    [appName setFont:[UIFont boldSystemFontOfSize:64]];
    [appName setShadowOffset:CGSizeMake(4, 4)];
    [appName setShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1]];
    appName.text = @"CRM4Mobile";
    appName.textAlignment = UITextAlignmentLeft;
    appName.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:appName];
    [appName release];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    UILabel *appVersion = [[UILabel alloc]initWithFrame:CGRectMake(260, 130, 480, 33)];
    [appVersion setFont:[UIFont systemFontOfSize:20]];
    appVersion.textColor = [UIColor grayColor];
    appVersion.textAlignment = UITextAlignmentLeft;
    appVersion.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    appVersion.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"VERSION", @"version"), version];
    [self.view addSubview:appVersion];
    [appVersion release];
    
    UILabel *copyright = [[UILabel alloc]initWithFrame:CGRectMake(260, 160, 480, 33)];
    [copyright setFont:[UIFont systemFontOfSize:20]];
    copyright.textColor = [UIColor grayColor];
    copyright.textAlignment = UITextAlignmentLeft;
    copyright.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    copyright.text = @"© Fellow Consulting 2012";
    [self.view addSubview:copyright];
    [copyright release];

    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 250, self.view.frame.size.width, self.view.frame.size.height - 250)];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    backgroundView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    [self.view addSubview:backgroundView];
    


    
    self.description = [[[UILabel alloc] initWithFrame:CGRectMake(30, 30, 700, 100)] autorelease];
    self.description.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.description setFont:[UIFont systemFontOfSize:20]];
    self.description.backgroundColor = [UIColor clearColor];
    self.description.numberOfLines = 0;
    self.description.textAlignment = UITextAlignmentLeft;
    self.description.textColor = [UIColor blackColor];
    [backgroundView addSubview:self.description];
    
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(30, 160, 700, 300)];
    buttonView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [backgroundView addSubview:buttonView];
    [backgroundView release];
    
    //mail to sale@fellow.de
    UIButton *linkbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    linkbutton.frame = CGRectMake(100, 0, 240, 40);
    [linkbutton setTitle:NSLocalizedString(@"FEEDBACK_EMAIL", @"Feedback email") forState:UIControlStateNormal];
    [linkbutton addTarget:self action:@selector(sendFeedback:) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:linkbutton];

    
    UIButton *btngoFellow = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btngoFellow.frame = CGRectMake(360, 0, 240, 40);
    [btngoFellow setTitle:NSLocalizedString(@"VISIT_WEBSITE", @"Visit website") forState:UIControlStateNormal];
    [btngoFellow addTarget:self action:@selector(goWebsite:) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:btngoFellow];

    [buttonView release];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)goWebsite:(id)sender {
    NSString *website = [Configuration getProperty:@"aboutWeb"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:website]];
}

- (void)sendFeedback:(id)sender {
    ErrorReport *mailing = [[ErrorReport alloc] initWithController:self];
    [mailing sendMail];
}

- (NSString *)getAboutText {
    return [EvaluateTools translateWithPrefix:[Configuration getProperty:@"aboutText"] prefix:@""];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.description setText:[self getAboutText]];
    NSData *logoData = [Configuration companyLogo];
    UIImage *logoImg = nil;
    if (logoData != nil) {
        logoImg = [UIImage imageWithData:logoData];
    } else {
        logoImg = [UIImage imageNamed:@"bigicon.png"];
    }
    int logoWidth = 175, logoHeight = 175;
    if (logoImg.size.width > logoImg.size.height) {
        logoHeight = logoImg.size.height * 175 / logoImg.size.width;
    } else {
        logoWidth = logoImg.size.width * 175 / logoImg.size.height;
    }
    [self.logo setImage:logoImg];
    [self.logo setFrame:CGRectMake(40 + (175 - logoWidth) / 2, 40 + (175 - logoHeight) / 2, logoWidth, logoHeight)];
}

@end
