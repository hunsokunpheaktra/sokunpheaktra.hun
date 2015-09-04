//
//  IphoneAbout.m
//  CRMiOS
//
//  Created by Sy Pauv on 6/15/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "IphoneAbout.h"


@implementation IphoneAbout

@synthesize buttonView;
@synthesize comment;
@synthesize aboutLogo;

- (void)loadView {

    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    self.title = NSLocalizedString(@"ABOUT", @"about screen's label");
    [self setView:mainView];
    [mainView release];

    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 96)];
    [headerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [headerView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0]];
    [self.view addSubview:headerView];
    
    self.aboutLogo = [[[UIImageView alloc] init] autorelease];
    self.aboutLogo.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [headerView addSubview:self.aboutLogo];
    
    UILabel *appName = [[UILabel alloc] initWithFrame:CGRectMake(96, 12, 300, 40)];
    [appName setBackgroundColor:[UIColor clearColor]];
    [appName setFont:[UIFont boldSystemFontOfSize:34]];
    [appName setShadowOffset:CGSizeMake(2, 2)];
    [appName setShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1]];
    appName.text = @"CRM4Mobile";
    appName.textAlignment = UITextAlignmentLeft;
    appName.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [headerView addSubview:appName];
    [appName release];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    UILabel *appVersion = [[UILabel alloc]initWithFrame:CGRectMake(100, 52, 300, 20)];
    [appVersion setBackgroundColor:[UIColor clearColor]];
    [appVersion setFont:[UIFont systemFontOfSize:14]];
    appVersion.textColor = [UIColor grayColor];
    appVersion.textAlignment = UITextAlignmentLeft;
    appVersion.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    appVersion.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"VERSION", @"version"),version];
    [headerView addSubview:appVersion];
    [appVersion release];
    
    UILabel *copyright = [[UILabel alloc]initWithFrame:CGRectMake(100, 72, 300, 20)];
    [copyright setBackgroundColor:[UIColor clearColor]];
    [copyright setFont:[UIFont systemFontOfSize:14]];
    copyright.textColor = [UIColor grayColor];
    copyright.textAlignment = UITextAlignmentLeft;
    copyright.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    copyright.text = @"© Fellow Consulting 2012";
    [headerView addSubview:copyright];
    [copyright release];
    [headerView release];


    self.comment = [[[UILabel alloc] init] autorelease];
    [self.comment setFont:[UIFont systemFontOfSize:14]];
    self.comment.backgroundColor = [UIColor clearColor];
    self.comment.numberOfLines = 0;
    self.comment.textAlignment = UITextAlignmentLeft;
    self.comment.textColor = [UIColor blackColor];
    [self.view addSubview:self.comment];
    
    self.buttonView = [[[UIView alloc] initWithFrame:CGRectMake(60, 200, 200, 100)] autorelease];
    [self.view addSubview:buttonView];

    
    //mail to sale@fellow.de
    UIButton *mailButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    mailButton.frame = CGRectMake(0, 0, 200, 40);
    [mailButton setTitle:NSLocalizedString(@"FEEDBACK_EMAIL", @"Feedback email") forState:UIControlStateNormal];
    [mailButton addTarget:self action:@selector(sendFeedback:) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:mailButton];
    
    UIButton *websiteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    websiteButton.frame = CGRectMake(0, 50, 200, 40);
    [websiteButton setTitle:NSLocalizedString(@"VISIT_WEBSITE", @"Visit website") forState:UIControlStateNormal];
    [websiteButton addTarget:self action:@selector(goWebsite:) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:websiteButton];
    
    [self willRotateToInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation] duration:0];
     
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        CGSize sizeText = [[self getAboutText] sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(250, 1000)];
        [self.comment setFrame:CGRectMake(10, 100, sizeText.width, sizeText.height)];
        [self.buttonView setFrame:CGRectMake(270, 110, 200, 100)];
    } else {
        CGSize sizeText = [[self getAboutText] sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(300, 1000)];
        [self.comment setFrame:CGRectMake(10, 100, sizeText.width, sizeText.height)];
        [self.buttonView setFrame:CGRectMake(60, 110 + sizeText.height, 200, 100)];
    }
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

- (void)dealloc
{
    self.comment = nil;
    self.buttonView = nil;
    self.aboutLogo = nil;
    [super dealloc];
}

- (void)sendFeedback:(id)sender{
    ErrorReport *mailing = [[ErrorReport alloc] initWithController:self];
    [mailing sendMail];
}

- (NSString *)getAboutText {
    return [EvaluateTools translateWithPrefix:[Configuration getProperty:@"aboutText"] prefix:@""];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.comment setText:[self getAboutText]];
    NSData *logoData = [Configuration companyLogo];
    UIImage *logoImg = nil;
    if (logoData != nil) {
        logoImg = [UIImage imageWithData:logoData];
    } else {
        logoImg = [UIImage imageNamed:@"bigicon.png"];
    }
    int logoWidth = 75, logoHeight = 75;
    if (logoImg.size.width > logoImg.size.height) {
        logoHeight = logoImg.size.height * 75 / logoImg.size.width;
    } else {
        logoWidth = logoImg.size.width * 75 / logoImg.size.height;
    }
    [self.aboutLogo setImage:logoImg];
    [self.aboutLogo setFrame:CGRectMake(10 + (75 - logoWidth) / 2, 10 + (75 - logoHeight) / 2, logoWidth, logoHeight)];
}



@end
