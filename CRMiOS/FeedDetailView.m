//
//  FeedDetailView.m
//  CRMiOS
//
//  Created by Sy Pauv on 3/29/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import "FeedDetailView.h"
#import "CommentTools.h"
#import "ShareNewFeed.h"

#define TOOLBAR_HEIGHT 60

@interface FeedDetailView ()

@end

@implementation FeedDetailView

@synthesize feedParent,listComments,compose,refreshListener,noComments,HUD;
@synthesize tableView,myToolbar,myTextView;

-(id)initWithComments:(FeedItem *)feed listener:(NSObject<RefreshInterface> *)linten{
    self.refreshListener = linten;
    self.feedParent = feed;
    return [super init];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"FEED_COMMENT_TITLE", @"title");
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.listComments = [[NSMutableArray alloc]initWithArray: [feedParent getChild]];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    childStream = [[StreamChildListViewController alloc] initWithChildComments:[feedParent getChild]];
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-TOOLBAR_HEIGHT) style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.backgroundColor = [UIColor colorWithRed:(191./255.) green:(199./255.) blue:(217./255.) alpha:1];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:self.tableView];

    
    CGRect viewFrame = [[UIScreen mainScreen] bounds];
    
    myToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, viewFrame.size.height-TOOLBAR_HEIGHT, frame.size.width, TOOLBAR_HEIGHT)];
    myToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleTopMargin;
    myToolbar.barStyle = UIBarStyleBlackOpaque;
    myToolbar.translucent = YES;
    [myToolbar sizeToFit];
    myToolbar.tintColor = [UIColor colorWithRed:(191./255.) green:(199./255.) blue:(217./255.) alpha:1];
    [self.view addSubview:myToolbar];
    
    myTextView = [[CustomTextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width-80, 30)];
    myTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    myTextView.placeholder = NSLocalizedString(@"FEED_WRITE_COMMENT", @"write a comment");
    myTextView.delegate = self;
    myTextView.scrollEnabled = NO;
    myTextView.spellCheckingType = UITextSpellCheckingTypeNo;
    myTextView.font = [UIFont systemFontOfSize:13];
    myTextView.layer.cornerRadius = 4;
    myTextView.layer.borderWidth = 0.5;
    myTextView.returnKeyType = UIReturnKeyDone;
    
    UIBarButtonItem *barComment = [[[UIBarButtonItem alloc] initWithCustomView:myTextView]autorelease];
    UIBarButtonItem *barSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]autorelease];
    UIBarButtonItem *barPost = [[[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self
                                                                action:@selector(composeComment)]autorelease];
    myToolbar.items = [NSArray arrayWithObjects:barComment,barSpace,barPost, nil] ;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

-(void)keyboardWillShow:(NSNotification *)notification{
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.25];
    
	NSDictionary *userInfo = [notification userInfo];
    NSValue* keyboardFrame = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's
    // coordinate system. The bottom of the text view's frame should align with the
    // top of the keyboard's final position.
    CGRect keyboardRect = [keyboardFrame CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    
    CGRect viewFrame = [[UIScreen mainScreen] bounds];
    float height = isPortrait?viewFrame.size.height:viewFrame.size.width;
    
	CGRect frame = self.myToolbar.frame;
	frame.origin.y = height - (keyboardRect.size.height+TOOLBAR_HEIGHT+44);
	self.myToolbar.frame = frame;
    
    CGRect rect = self.tableView.frame;
    rect.size.height = height-(keyboardRect.size.height+TOOLBAR_HEIGHT+44);
    self.tableView.frame = rect;
	[UIView commitAnimations];
    
}
-(void)keyboardWillHide:(NSNotification *)notification{
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.25];
    
	CGRect frame = self.myToolbar.frame;
	frame.origin.y = self.view.frame.size.height-44;
	self.myToolbar.frame = frame;
    
    CGRect rect = self.tableView.frame;
    rect.size.height = self.view.frame.size.height-43;
    self.tableView.frame = rect;
	
	[UIView commitAnimations];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

-(void)composeComment{
    NSString *text = self.myTextView.text;
    if ([text length] > 0) {
        ShareNewFeed *shareFeed = [[ShareNewFeed alloc] init:[feedParent getId] comment:text];
        [shareFeed doRequest:self];
        [self addTempComment:[feedParent getId] Comment:text];
        
        self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.HUD.labelText = NSLocalizedString(@"Sending...", nil);
        
    }
    [self.myTextView setText:@""];
    [self.myTextView resignFirstResponder];
}
- (void)addTempComment:(NSString *)parent Comment:(NSString *)comment{
    FeedItem *item=[[FeedItem alloc]init];
    for (NSString *field in [FeedManager getAllFields]) {
        [item.data setObject:@"" forKey:field];
    }
    item.istmpItem = [NSNumber numberWithBool:YES];
    [item.data setObject:parent forKey:@"parentid"];
    [item.data setObject:comment forKey:@"comment"];
    [item.data setObject:[NSString stringWithFormat:@"%.lf000",[[NSDate date] timeIntervalSince1970]] forKey:@"createddate"];
    [item.data setObject:[[CurrentUserManager read] objectForKey:@"Alias"] forKey:@"fullname"];
    [item.data setObject:[[CurrentUserManager read] objectForKey:@"UserId"] forKey:@"userid"];
    NSMutableArray *tmplist=[[NSMutableArray alloc]initWithArray:[FeedManager getFeed]];
    [tmplist addObject:item];
    [FeedManager writeFeed:tmplist];
    [tmplist release];
    [item release];
}

- (BOOL)isComment:(FeedItem *)feed {
    return [[feed getParentId] length] > 0 && ![[feed getParentId] isEqualToString:@"null"];
}

- (void)viewDidUnload
{
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.tableView reloadData];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

-(CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //profile image height
    float profileImageHeight = 36 + 39 + 20;
    //calculate comment area height
    float backgroundWidth = tableView.frame.size.width - 60;
    
    NSString *comment = [NSString stringWithFormat:@"%@",[feedParent getComment]];
    CGSize commentSize = [comment sizeWithFont:[UIFont fontWithName:@"GillSans" size:14]];
    //    float commentWidth = tmptext.contentSize.height + 20;
    int commentLine = [[CommentTools splitLinesWithNL:comment offset:0 width:backgroundWidth] count];
    float height = profileImageHeight + (commentLine * commentSize.height)  + childStream.totalHeight;
    
    return height;
    
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    // cleanup all the previous views
    for (UIView *view in [cell.contentView subviews]) {
        [view removeFromSuperview];
    }
    
    CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, cellRect.size.width-20, cellRect.size.height-20)];
    backgroundView.backgroundColor = [UIColor whiteColor];
    backgroundView.opaque=YES;
    [cell.contentView addSubview:backgroundView];
    [backgroundView release];

    // picture
    NSData *imageData = [FeedManager getAvatar:[feedParent getUserId]];
    UIImage *image = imageData == nil ? [UIImage imageNamed:@"no-image.jpeg"] : [UIImage imageWithData:imageData];
    UIImageView *userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(22, 18, 40, 39)];
    userImageView.image = image;
    userImageView.contentMode = UIViewContentModeScaleAspectFill;
    userImageView.opaque=YES;
    userImageView.clipsToBounds=YES;
    [cell.contentView addSubview:userImageView];
    [userImageView release];
    
    // author label
    UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(73 , 13, cellRect.size.width-70, 30)];
    authorLabel.font = [UIFont boldSystemFontOfSize:15];
    authorLabel.text = [feedParent getFullName];
    authorLabel.textColor = [UIColor colorWithRed:0.0 green:0.2 blue:0.7 alpha:1.0];
    authorLabel.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:authorLabel];
    [authorLabel release];
    
    // date
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(73 , 38, cellRect.size.width-70, 20)];
    dateLabel.font = [UIFont systemFontOfSize:13];
    dateLabel.text = [feedParent getCreatedDateFormatted];
    dateLabel.textColor = [UIColor grayColor];
    dateLabel.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:dateLabel];
    [dateLabel release];
    
    UIImageView *commentBackground = [[UIImageView alloc] initWithFrame:CGRectMake(20, 65, cellRect.size.width-40, cellRect.size.height-(80+childStream.totalHeight))];
    commentBackground.userInteractionEnabled = YES;
    commentBackground.image = [[UIImage imageNamed:@"activity-bubble-bg.png"] stretchableImageWithLeftCapWidth:40 topCapHeight:40];
//    commentBackground.layer.shadowOffset = CGSizeMake(0, -1);
//    commentBackground.layer.shadowColor = [UIColor blackColor].CGColor;
//    commentBackground.layer.shadowOpacity = 0.5;
//    commentBackground.layer.shadowRadius = 3;
//    commentBackground.layer.shadowOffset = CGSizeMake(1.0, 1.0);
    [cell.contentView addSubview:commentBackground];
    [commentBackground release];
    
    UITextView *commentView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, commentBackground.frame.size.width-20, commentBackground.frame.size.height)];
    commentView.opaque=YES;
    commentView.tag = indexPath.row;
    commentView.font= [UIFont fontWithName:@"GillSans" size:14];
    commentView.scrollEnabled = NO;
    commentView.backgroundColor = [UIColor clearColor];
    commentView.opaque = NO;
    commentView.editable = NO;
    commentView.text = [feedParent getComment];
    [commentBackground addSubview:commentView];
  
    float y = commentView.frame.origin.y + commentView.frame.size.height + 10;
    
    UIImageView *postImg = [[UIImageView alloc] initWithFrame: CGRectMake(15, y, commentBackground.frame.size.width-30, 190)];
    postImg.contentMode = UIViewContentModeScaleToFill;
    if(postImage){
        [postImg setImage:postImage];
    }
    postImg.tag = indexPath.row;
    postImg.contentMode = UIViewContentModeScaleAspectFill;
    postImg.clipsToBounds=YES;
    
    [commentBackground addSubview:postImg];
    
    y =  commentBackground.frame.origin.y + commentBackground.frame.size.height+1;
    
    [childStream setViewFrame:CGRectMake(0, y, cellRect.size.width-20, childStream.totalHeight)];
    [backgroundView addSubview:childStream.view];
    
    return cell;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    BOOL isPort = UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
    float width = isPort ? frame.size.width : frame.size.height;
    [childStream calculateTotalHeight:width];
}

-(void)dealloc{
    [super dealloc];
    //if(childStream!=nil) [childStream release];
    [noComments release];
    [listComments release];
    [compose release];
    [tableView release];
    tableView=nil;
    [myToolbar release];
    myToolbar = nil;
    [myTextView release];
    myTextView = nil;
}

-(void)refresh{
    [refreshListener refresh];
    [self.tableView reloadData];
}
- (void)addNewStatus:(FeedItem *)fItem{}
- (void)feedSuccess:(NSObject *)request{
    self.listComments = [[NSMutableArray alloc]initWithArray: [feedParent getChild]];
    if (childStream) {
        [childStream release];
    }
    childStream = [[StreamChildListViewController alloc] initWithChildComments:[feedParent getChild]];
    [self.tableView reloadData];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
- (void)feedFailure:(NSObject *)request errorCode:(NSString *)errorCode errorMessage:(NSString *)errorMessage{
    [self cleartmpComment];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)cleartmpComment{

    NSMutableArray *tmplist=[[NSMutableArray alloc]initWithCapacity:1];

    for (FeedItem *item in [FeedManager getFeed]) {
        if (!item.istmpItem) {
            [tmplist addObject:item];
        }
    }
    [FeedManager writeFeed:tmplist];
    [tmplist release];

}
- (void)dismissHUD:(id)arg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.HUD = nil;
    
}


@end
