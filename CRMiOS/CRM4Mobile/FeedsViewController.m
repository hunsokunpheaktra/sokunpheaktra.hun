//
//  FeedsVievController.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 2/23/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//
#import "FeedsViewController.h"
#import "CommentTools.h"

@implementation FeedsViewController

@synthesize feedData;
@synthesize errorLabel;
@synthesize activeField;
@synthesize hud=_hud;
@synthesize navigationBar;
@synthesize timeScroller;

- (id)init {
    self = [super init];
    self.title = NSLocalizedString(@"FEED_TITLE", @"Feed");
    //push refresh header init
    if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
	}
    
    //scroll loadmore footer init
    if (_loadMoreFooter == nil) {
        LoadMoreFooterView *more=[[LoadMoreFooterView alloc] initWithFrame:CGRectMake(0.0f, 0.0f , self.view.frame.size.width, 44.0f)];
        more.delegate = self;
        [more setHidden:YES];
        
        [self.tableView setTableFooterView:more];
        _loadMoreFooter = more;
        [more release];
    }
    
    self.timeScroller = nil;
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)dismissHUD:(id)arg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.hud = nil;
    
}

#pragma mark - Refreshlistener
- (void)refreshFeed{
    [[[FeedSyncProcess alloc] init] start:self];
}

- (void)addNewStatus:(FeedItem *)fItem{
    
    NSMutableArray *tmpfeed = [[NSMutableArray alloc]initWithCapacity:1];
    [tmpfeed addObject:fItem];
    [tmpfeed addObjectsFromArray:self.feedData];
    self.feedData = tmpfeed;
    [self.tableView reloadData];
    [tmpfeed release];
    
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)viewDidLoad {
    
    self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 44)];
    [self.navigationBar setTintColor:[UIColor colorWithRed:0.1 green:0.3 blue:0.5 alpha:1.0]];
    self.navigationBar.delegate=self;
    
    self.tableView.backgroundColor = [UIColor colorWithRed:(191./255.) green:(199./255.) blue:(217./255.) alpha:1];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    UIImage* image = [UIImage imageNamed:@"feed.png"];
    UIButton* feedShare = [UIButton buttonWithType:UIButtonTypeCustom];
    feedShare.frame=CGRectMake(0, 0, 30, 30);
    [feedShare setImage:image forState:UIControlStateNormal];
    [feedShare setShowsTouchWhenHighlighted:YES];
    [feedShare addTarget:self action:@selector(showNewFeedView:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc]initWithCustomView:feedShare] autorelease];
    [feedShare release];
    [self refreshFeed];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if (self.timeScroller != nil) {
        [self.timeScroller removeFromSuperview];
        self.timeScroller.delegate = nil;
        [self.timeScroller release];
        self.timeScroller = nil;
    }
    self.timeScroller = [[TimeScroller alloc] initWithDelegate:self];
    [self.tableView reloadData];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellId = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId] autorelease];
    }
    
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    FeedItem *feed = [self.feedData objectAtIndex:indexPath.row];
    
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
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, backgroundView.frame.size.height-36, cellRect.size.width-20, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:(221/255.) green:(221/255.) blue:(221/255.) alpha:1];
    lineView.opaque=YES;
    [backgroundView addSubview:lineView];
    [lineView release];
    
    // picture
    
    NSData *imageData = [FeedManager getAvatar:[feed getUserId]];
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
    authorLabel.text = [feed getFullName];
    authorLabel.textColor = [UIColor colorWithRed:0.0 green:0.2 blue:0.7 alpha:1.0];
    authorLabel.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:authorLabel];
    [authorLabel release];
    
    // date
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(73 , 38, cellRect.size.width-70, 20)];
    dateLabel.font = [UIFont systemFontOfSize:13];
    dateLabel.text = [feed getCreatedDateFormatted];
    dateLabel.textColor = [UIColor grayColor];
    dateLabel.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:dateLabel];
    [dateLabel release];
    
    //content comment blog
    UIImageView *commentBackground = [[UIImageView alloc] initWithFrame:CGRectMake(20, 65, cellRect.size.width-40, cellRect.size.height-120)];
    commentBackground.opaque=YES;
    commentBackground.userInteractionEnabled = YES;
    commentBackground.image = [[UIImage imageNamed:@"activity-bubble-bg.png"] stretchableImageWithLeftCapWidth:40 topCapHeight:40];
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
    commentView.text = [feed getComment];
    [commentBackground addSubview:commentView];
    
    //action bottom bar bloc
    UIView *actionView = [[UIView alloc] initWithFrame:CGRectMake(0, backgroundView.frame.size.height-35, cellRect.size.width-20, 35)];
    actionView.backgroundColor = [UIColor colorWithRed:(235./255.) green:(238./255.) blue:(245./255.) alpha:1];
    actionView.opaque=YES;
    [backgroundView addSubview:actionView];
    [actionView release];
    
    UIButton *commentSizeIcon = [UIButton buttonWithType:UIButtonTypeCustom];
    commentSizeIcon.frame = CGRectMake(actionView.frame.size.width-55, 9 , 22, 22);
    [commentSizeIcon setImage:[UIImage imageNamed:@"commentSize.png"] forState:UIControlStateNormal];
    commentSizeIcon.tag = indexPath.row;
    [commentSizeIcon addTarget:self action:@selector(addComment:) forControlEvents:UIControlEventTouchUpInside];
    [actionView addSubview:commentSizeIcon];
    
    UILabel *commentSize = [[UILabel alloc]initWithFrame:CGRectMake(actionView.frame.size.width-25, 9 , 20, 20)];
    commentSize.text = [NSString stringWithFormat:@"%i",[[feed getChild] count]];
    commentSize.backgroundColor=[UIColor clearColor];
    commentSize.textColor=[UIColor colorWithRed:0.0 green:0.2 blue:0.7 alpha:1.0];
    commentSize.font = [UIFont systemFontOfSize:14];
    [actionView addSubview:commentSize];
    [commentSize release];
    
    UIButton *commentButtonicon = [UIButton buttonWithType:UIButtonTypeCustom];
    commentButtonicon.tag = indexPath.row;
    commentButtonicon.frame = CGRectMake(7, 9, 22, 22);
    [commentButtonicon setBackgroundImage:[UIImage imageNamed:@"cmdAdd.png"] forState:UIControlStateNormal];
    [commentButtonicon addTarget:self action:@selector(addComment:) forControlEvents:UIControlEventTouchUpInside];
    [actionView addSubview:commentButtonicon];
    
    UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    commentButton.tag = indexPath.row;
    commentButton.frame = CGRectMake(24, 9, 80, 20);
    commentButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [commentButton setTitleColor:[UIColor colorWithRed:(87./255.) green:(107./255.) blue:(149./255.) alpha:1.0] forState:UIControlStateNormal];
    [commentButton setTitle:@"Comment" forState:UIControlStateNormal];
    [commentButton addTarget:self action:@selector(addComment:) forControlEvents:UIControlEventTouchUpInside];
    [actionView addSubview:commentButton];

    return cell;
}

-(void)addComment:(UIButton*)button{
    
    FeedItem *selected = [self.feedData objectAtIndex:button.tag];
    FeedDetailView *detail = [[FeedDetailView alloc] initWithComments:selected listener:nil];
    [self.navigationController pushViewController:detail animated:YES];
    [detail release];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [feedData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedItem *feed = [self.feedData objectAtIndex:indexPath.row];
    //profile image height
    float profileImageHeight = 36 + 39;
    //action bar bottom height;
    float actionHeight = 60.0;
    //calculate comment area height
    float backgroundWidth = tableView.frame.size.width - 60;
    
    NSString *comment = [NSString stringWithFormat:@"%@",[feed getComment]];
    CGSize commentSize = [comment sizeWithFont:[UIFont fontWithName:@"GillSans" size:14]];
//    float commentWidth = tmptext.contentSize.height + 20;
    int commentLine = [[CommentTools splitLinesWithNL:comment offset:0 width:backgroundWidth] count];
    float height = profileImageHeight + (commentLine * commentSize.height)  + actionHeight;
    return height;
    
}

- (void)syncEnd:(NSString *)error sendReport:(BOOL)sendReport {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self doneLoadingTableViewData];
    [self finishloadingMoreFeed];
    if (error != nil && [self.feedData count] == 0) {
        [self.errorLabel setHidden:NO];
    }
}

- (void)syncStart {
    [self.errorLabel setHidden:YES];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.labelText = NSLocalizedString(@"UPDATING", nil);
}

- (void)syncProgress:(NSString *)entity {
    [self rebuildFeedView];
}

- (void)rebuildFeedView{
    if(feedData != nil)[self.feedData release];
    self.feedData = [[NSMutableArray alloc] initWithCapacity:1];
    NSArray *currentFeed = [FeedManager allParentsItem];
    for (int i = 0; i < [currentFeed count]; i++) {
        FeedItem *feed = [currentFeed objectAtIndex:i];
        [self.feedData addObject:feed];
    }
    [self.tableView reloadData];
    [self.tableView setHidden:NO];
    [self.errorLabel setHidden:YES];
}
- (void)syncConfig {
    
}
- (BOOL)isComment:(FeedItem *)feed {
    return [[feed getParentId] length] > 0 && ![[feed getParentId] isEqualToString:@"null"];
}


- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [textField performSelector:@selector(resignFirstResponder) withObject:nil afterDelay:0.1];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    if ([[textField text] length] > 0) {
        ShareNewFeed *shareFeed;
        shareFeed = [[ShareNewFeed alloc] init:[NSString stringWithFormat:@"%d", [textField tag]] comment:[textField text]];
        [shareFeed doRequest:self];
        [self addTempComment:[NSString stringWithFormat:@"%d", [textField tag]] Comment:[textField text]];
    }
    [textField setText:@""];
    return YES;
}

- (void)addTempComment:(NSString *)parent Comment:(NSString *)comment{
    FeedItem *item=[[FeedItem alloc]init];
    for (NSString *field in [FeedManager getAllFields]) {
        [item.data setObject:@"" forKey:field];
    }
    item.istmpItem=[NSNumber numberWithBool:YES];
    [item.data setObject:parent forKey:@"parentid"];
    [item.data setObject:comment forKey:@"comment"];
    [item.data setObject:[NSString stringWithFormat:@"%.lf000",[[NSDate date] timeIntervalSince1970]] forKey:@"createddate"];
    [item.data setObject:[[CurrentUserManager read] objectForKey:@"Alias"] forKey:@"fullname"];
    [item.data setObject:[[CurrentUserManager read] objectForKey:@"UserId"] forKey:@"userid"];
    
    NSMutableArray *tmpfeedData = [[NSMutableArray alloc] initWithCapacity:1];
    NSArray *currentFeed = [FeedManager getFeed];
    for (int i = 0; i < [currentFeed count]; i++) {
        FeedItem *feed = [currentFeed objectAtIndex:i];
        [tmpfeedData addObject:feed];
        FeedItem *nextFeed = i + 1 < [currentFeed count] ? [currentFeed objectAtIndex:i + 1] : nil;
        
        //current and next are both parent 
        if(nextFeed!=nil){
            
            if (![self isComment:feed] && ![self isComment:nextFeed] && [[feed getId] isEqualToString:parent]) {
                [tmpfeedData addObject:item];
                continue;
            }
            if (  ![self isComment:nextFeed] && [self isComment:feed] && [[feed getParentId]isEqualToString:parent]) {
                [tmpfeedData addObject:item];
                continue;
            }
            
        }
        //current feed is comment or parant and next feed is null
        if (nextFeed == nil) {
            if ([self isComment:feed] && [[feed getParentId]isEqualToString:parent]) {
                [tmpfeedData addObject:item];
                continue;
            }
            if (![self isComment:feed] && [[feed getId]isEqualToString:parent]) {
                [tmpfeedData addObject:item];
                continue;
            }
        }    
        
    }
    [FeedManager writeFeed:tmpfeedData];
    [tmpfeedData release];
    [item release];
}

- (void)feedSuccess:(NSObject *)request {
    [self rebuildFeedView];
}

- (void)feedFailure:(NSObject *)request errorCode:(NSString *)errorCode errorMessage:(NSString *)errorMessage {
    
}


- (void)refresh{
    [self refreshFeed];
}

- (void)showNewFeedView:(id)sender{
    
    AddNewStatusController *feed=[[AddNewStatusController alloc]initWithListener:self];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:feed];
    [feed release];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    nav.navigationBar.tintColor = [UIColor colorWithRed:0.1 green:0.3 blue:0.5 alpha:1.0];
    [self.navigationController presentModalViewController:nav animated:YES];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        CGRect rect = nav.view.superview.frame;
        rect.size = CGSizeMake(500, 250);
        rect.origin.x += 30;
        rect.origin.y += 90;
        nav.view.superview.frame = rect;
    }
    [nav release];
}


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
}

- (void)finishloadingMoreFeed{
    
    [_loadMoreFooter setHidden:YES];
    [_loadMoreFooter hideLoadingFooter:self.tableView];
    
}



#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {	
    [timeScroller scrollViewDidScroll];
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    if ( [[FeedManager allParentsItem] count]>=20) {
        [_loadMoreFooter showLoadingFooter:scrollView];  
    }      
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    if (!decelerate) {
        [timeScroller scrollViewDidEndDecelerating];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [timeScroller scrollViewDidEndDecelerating];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [timeScroller scrollViewWillBeginDragging];
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    //if user pull refresh reload feed data from offset 0
    NSMutableArray *emtyFeedData=[[[NSMutableArray alloc]initWithCapacity:1]autorelease];
    [FeedManager writeFeed:emtyFeedData];
	[self refreshFeed];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return _reloading; // should return if data source model is reloading
}

#pragma mark -
#pragma mark LoadMOreFooterDelegate Methods
- (void)startLoadMoreFeed:(LoadMoreFooterView *)view{
    //call load more
    [[[FeedSyncProcess alloc] init] start:self];
}

- (void)linkRecord:(id)sender{
    
    UIButton *button=(UIButton *)sender;
    FeedItem *feedItem=[feedData objectAtIndex:button.tag];
    Item *item=[EntityManager find:[feedItem getEntity] column:@"Id" value:[feedItem getRecordId]];
    
    if(item==nil){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Record Not Found!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        [alert release];
        return;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        gadgetAppDelegate *delegate = (gadgetAppDelegate*)[[UIApplication sharedApplication] delegate];
        UITabBarController *tab = (UITabBarController*)delegate.window.rootViewController;
        PadMainViewController *main;
        
        for(UIViewController *con in tab.viewControllers){
            if([con isKindOfClass:[UINavigationController class]]){
                UINavigationController *nav = (UINavigationController*)con;
                if([nav.topViewController isKindOfClass:[PadMainViewController class]]){
                    main = (PadMainViewController*)nav.topViewController;
                    if([main.subtype isEqualToString:[feedItem getEntity]]) break;
                }
            }
        }
        
        [main.listViewController selectItem:[item.fields objectForKey:@"gadget_id"]];
        [tab setSelectedViewController:main.navigationController];
        
    } else {
        DetailViewController *detail = [[DetailViewController alloc] initWithItem:item listener:nil];
        [self.navigationController pushViewController:detail animated:YES];
        [detail release];
    }
}


- (UITableView *)tableViewForTimeScroller:(TimeScroller *)timeScroller {
    return self.tableView;
}

//The date for a given cell
- (NSDate *)dateForCell:(UITableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    int row = indexPath.row;
    FeedItem *feed = nil;
    while (YES) {
        feed = [self.feedData objectAtIndex:row];
        if ([feed getId] != nil) break;
        row--;
        if (row == -1) break;
    }
    return [feed getCreatedDate];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.timeScroller != nil) {
        [self.timeScroller removeFromSuperview];
        self.timeScroller.delegate = nil;
        [self.timeScroller release];
        self.timeScroller = nil;
    }
    self.timeScroller = [[TimeScroller alloc] initWithDelegate:self];
    [self.tableView reloadData];
}

@end
