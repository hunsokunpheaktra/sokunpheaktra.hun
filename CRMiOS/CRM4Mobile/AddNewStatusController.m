//
//  AddNewStatusController.m
//  CRMFeed
//
//  Created by Sy Pauv Phou on 2/22/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "AddNewStatusController.h"
@implementation AddNewStatusController
@synthesize textFeed,feedlistener;

- (id)initWithListener:(NSObject <FeedListener> *)listener {
    self=[super init];
    if (self) {
        self.feedlistener=listener;
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=NSLocalizedString(@"FEED_WORKING_ON", @"title");
    self.textFeed=[[UITextView alloc]initWithFrame:self.view.frame];
    self.view=self.textFeed;
    self.textFeed.delegate=self;
    [self.textFeed setFont:[UIFont boldSystemFontOfSize:16]];
    self.navigationItem.leftBarButtonItem=[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close)]autorelease];
    
    self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc]initWithTitle:@"Share" style:UIBarButtonItemStyleDone target:self action:@selector(shareFeed)]autorelease];
    self.navigationItem.rightBarButtonItem.enabled=NO;
}

- (void)close{
    
    [self dismissModalViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self.textFeed becomeFirstResponder];
    
}

- (void)textViewDidChange:(UITextView *)textView{
    
    self.navigationItem.rightBarButtonItem.enabled=![textView text].length==0;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)shareFeed{
    
    NSString *comment=[self.textFeed text];
    
    FeedItem *item=[[FeedItem alloc]init];
    for (NSString *field in [FeedManager getAllFields]) {
        [item.data setObject:@"" forKey:field];
    }
    [item.data setObject:comment forKey:@"comment"];
    [item.data setObject:[NSString stringWithFormat:@"%.lf000",[[NSDate date] timeIntervalSince1970]] forKey:@"createddate"];
    [item.data setObject:[[CurrentUserManager read] objectForKey:@"Alias"] forKey:@"fullname"];
    [item.data setObject:[[CurrentUserManager read] objectForKey:@"UserId"] forKey:@"userid"];
    item.istmpItem=[NSNumber numberWithBool:YES];
    
    NSMutableArray *tmpfeeddata=[[NSMutableArray alloc]initWithCapacity:1];
    [tmpfeeddata addObject:item];
    for (FeedItem *item in [FeedManager getFeed]) {
        [tmpfeeddata addObject:item];
    }
    [FeedManager writeFeed:tmpfeeddata];
    [tmpfeeddata release];
    
    ShareNewFeed *shareFeed;
    shareFeed = [[ShareNewFeed alloc] init:nil comment:comment];
    [shareFeed doRequest:self.feedlistener];
    
    [self close];
}

@end