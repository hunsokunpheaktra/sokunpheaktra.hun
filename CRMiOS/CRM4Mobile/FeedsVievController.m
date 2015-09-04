//
//  FeedsVievController.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 2/23/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//
#import "FeedsVievController.h"

@implementation FeedsVievController

@synthesize feedView;
@synthesize feedData;
@synthesize errorLabel;
@synthesize activeField;
@synthesize hud=_hud;
@synthesize navigationBar;

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
    if (_loadMOreFoodter == nil) {
        
        LoadMoreFooterView *more=[[LoadMoreFooterView alloc]initWithFrame:CGRectMake(0.0f, 0.0f , self.view.frame.size.width, 44.0f)];
        more.delegate = self;
        [more setHidden:YES];
        
        [self.tableView setTableFooterView:more];
        _loadMOreFoodter = more;
        [more release];
        
    }
    
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
    
    NSMutableArray *tmpfeed=[[NSMutableArray alloc]initWithCapacity:1];
    [tmpfeed addObject:fItem];
    [tmpfeed addObjectsFromArray:self.feedData];
    self.feedData=tmpfeed;
    [self.tableView reloadData];
    [tmpfeed release];
    
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)viewDidLoad {
    
    self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 44)];
    [self.navigationBar setTintColor:[UIColor colorWithRed:0.1 green:0.3 blue:0.5 alpha:1.0]];
    self.navigationBar.delegate=self;
    
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
    [self.feedView reloadData];
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    FeedItem *feed = [self.feedData objectAtIndex:indexPath.row];
    FeedItem *nextFeed = indexPath.row + 1 < [self.feedData count] ? [self.feedData objectAtIndex:indexPath.row + 1] : nil;
    FeedItem *previousFeed = indexPath.row > 0 ? [self.feedData objectAtIndex:indexPath.row - 1] : nil;
    
    // cleanup all the previous views
    for (UIView *view in [cell.contentView subviews]) {
        [view removeFromSuperview];
    }
    
    // adjust content view frame that sometimes bug
    CGRect tmp = [cell.contentView frame];
    tmp.size.width = tableView.frame.size.width;
    [cell.contentView setFrame:tmp];
    
    // compute some stuff
    int cx = [self isComment:feed] ? FEED_COMMENT_OFFSET : 0;
    int offset = [[feed getFullName] sizeWithFont:[UIFont boldSystemFontOfSize:14.0f]].width + FEED_MARGIN / 2;
    int imageSize = [self isComment:feed] ? FEED_COMMENT_IMAGE_SIZE : FEED_IMAGE_SIZE;
    int targetWidth = tableView.frame.size.width - cx - ([self isComment:feed] ? FEED_MARGIN : 0);
    int targetTextWidth = targetWidth - FEED_MARGIN * 3 - imageSize;
    NSArray *commentLines = [self splitLinesWithNL:[feed getComment] offset:offset width:targetTextWidth];
    int totalHeight;
    if ([feed getId] != nil) {
        totalHeight = MAX(([commentLines count] + 1) * FEED_LINE_HEIGHT + FEED_MARGIN, imageSize + FEED_MARGIN * 2);
    } else {
        totalHeight = 20 + FEED_MARGIN * 2;
    }
    
    // background for comments
    if ([self isComment:feed]) {
        UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(cx, 0, targetWidth, totalHeight)];
        commentView.backgroundColor = [UIColor colorWithRed:0.9 green:0.95 blue:1.0 alpha:1.0];
        commentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [cell.contentView addSubview:commentView];
        [commentView release];
    } else {
        // triangle, if there are some comments below
        if ([self isComment:nextFeed]) {
            TriangleView *triangleView = [[TriangleView alloc] initWithFrame:CGRectMake(FEED_COMMENT_OFFSET + 8, totalHeight - 8, 16, 8)];
            [triangleView setBackgroundColor:[UIColor clearColor]];
            [cell.contentView addSubview:triangleView];
            [triangleView release];
        } 
    }
    
    // top separator
    if ((![self isComment:feed] && ![self isComment:previousFeed]) || ([self isComment:feed] && [self isComment:previousFeed])) {
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(cx, 0, targetWidth, 1)];
        separatorView.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];
        separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [cell.contentView addSubview:separatorView];
        [separatorView release];
    }
    
    if ([feed getId] != nil) {
        // author label
        UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(cx + imageSize + FEED_MARGIN * 2 , FEED_MARGIN / 2, targetTextWidth, FEED_LINE_HEIGHT)];
        authorLabel.font = [UIFont boldSystemFontOfSize:FEED_FONT_SIZE];
        authorLabel.text = [feed getFullName];
        authorLabel.textColor = [UIColor colorWithRed:0.0 green:0.2 blue:0.7 alpha:1.0];
        authorLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:authorLabel];
        [authorLabel release];
        
        // comments
        for (int i = 0; i < [commentLines count]; i++) {
            
            if ([[feed getRecordId] length]>5) {
                
                UIButton *linkbutton=[UIButton buttonWithType:UIButtonTypeCustom];
                //                UIButton *linkbutton=[UnderLineButton underlinedButton];
                linkbutton.frame=CGRectMake((i == 0 ? offset : 0) + cx + imageSize + FEED_MARGIN * 2 , i * FEED_LINE_HEIGHT + FEED_MARGIN / 2, targetTextWidth - (i == 0 ? offset : 0), FEED_LINE_HEIGHT);
                [linkbutton setTag:indexPath.row];
                [linkbutton setTitle:[commentLines objectAtIndex:i] forState:UIControlStateNormal];
                [linkbutton.titleLabel setFont:[UIFont systemFontOfSize:FEED_FONT_SIZE]];
                [linkbutton setTitleColor: [UIColor colorWithRed:0.0 green:0.2 blue:0.7 alpha:1.0] forState:UIControlStateNormal];
                [linkbutton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
                [linkbutton addTarget:self action:@selector(linkRecord:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:linkbutton];
                continue;
                
            }else{
                
                UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake((i == 0 ? offset : 0) + cx + imageSize + FEED_MARGIN * 2 , i * FEED_LINE_HEIGHT + FEED_MARGIN / 2, targetTextWidth - (i == 0 ? offset : 0), FEED_LINE_HEIGHT)];
                commentLabel.font = [UIFont systemFontOfSize:FEED_FONT_SIZE];
                commentLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                commentLabel.text = [commentLines objectAtIndex:i];
                commentLabel.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:commentLabel];
                [commentLabel release];
                
            }
        }
        
        // date
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(cx + imageSize + FEED_MARGIN * 2, [commentLines count] * FEED_LINE_HEIGHT + FEED_MARGIN / 2, targetTextWidth, FEED_LINE_HEIGHT)];
        dateLabel.font = [UIFont systemFontOfSize:(FEED_FONT_SIZE - 2)];
        dateLabel.text = [feed getCreateDate];
        dateLabel.textColor = [UIColor grayColor];
        dateLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:dateLabel];
        [dateLabel release];
        
        // picture
        NSData *imageData = [FeedManager getAvatar:[feed getUserId]];
        UIImage *image = imageData == nil ? [UIImage imageNamed:@"no_picture.png"] : [UIImage imageWithData:imageData];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [imageView setFrame:CGRectMake(cx + FEED_MARGIN, FEED_MARGIN, imageSize, imageSize)];
        [imageView.layer setBorderColor: [[UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0] CGColor]];
        [imageView.layer setBorderWidth: 1.0];
        [cell.contentView addSubview:imageView];
        [imageView release];
    } else {
        UITextField *commentField = [[UITextField alloc] initWithFrame:CGRectMake(cx + FEED_MARGIN, FEED_MARGIN, targetWidth - FEED_MARGIN * 2, 20)];
        [commentField setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [commentField setBorderStyle:UITextBorderStyleRoundedRect];
        [commentField setPlaceholder:NSLocalizedString(@"FEED_WRITE_COMMENT", @"Write a comment...")];
        [commentField setFont:[UIFont systemFontOfSize:FEED_FONT_SIZE - 2]];
        [commentField setDelegate:self];
        [commentField setClearButtonMode:UITextFieldViewModeAlways];
        [commentField setReturnKeyType:UIReturnKeySend];
        if ([self isComment:previousFeed]) {
            [commentField setTag:[[previousFeed getParentId] intValue]];
        } else {
            [commentField setTag:[[previousFeed getId] intValue]];
        }
        [cell.contentView addSubview:commentField];
        
    }
    
    return cell;
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
    if ([feed getId] == nil) {
        return 20 + FEED_MARGIN * 2;
    }
    int cx = [self isComment:feed] ? FEED_COMMENT_OFFSET : 0;
    int imageSize = [self isComment:feed] ? FEED_COMMENT_IMAGE_SIZE : FEED_IMAGE_SIZE;
    
    int offset = [[feed getFullName] sizeWithFont:[UIFont boldSystemFontOfSize:FEED_FONT_SIZE]].width + FEED_MARGIN / 2;
    NSArray *lines = [self splitLinesWithNL:[feed getComment] offset:offset width:tableView.frame.size.width - cx - FEED_MARGIN * 3 - imageSize - ([self isComment:feed] ? FEED_MARGIN : 0)];
    return MAX(([lines count] + 1) * FEED_LINE_HEIGHT + FEED_MARGIN, imageSize + FEED_MARGIN * 2);
}

- (void)syncEnd:(NSString *)error {
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
    
    NSArray *currentFeed = [FeedManager getFeed];
    for (int i = 0; i < [currentFeed count]; i++) {
        FeedItem *feed = [currentFeed objectAtIndex:i];
        [self.feedData addObject:feed];
        FeedItem *nextFeed = i + 1 < [currentFeed count] ? [currentFeed objectAtIndex:i + 1] : nil;
        if (nextFeed == nil || ![self isComment:nextFeed]) {
            FeedItem *commentItem = [[FeedItem alloc] init];
            [commentItem.data setObject:[feed getId] forKey:@"parentid"];
            [self.feedData addObject:commentItem];
        }
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


- (NSArray *)splitLinesWithNL:(NSString *)text offset:(int)offset width:(int)width {
    NSMutableArray *lines = [NSMutableArray arrayWithCapacity:1];
    if (text == nil) {
        return lines;
    }
    while (YES) {
        NSRange rNewline = [text rangeOfCharacterFromSet: [NSCharacterSet newlineCharacterSet]];
        if (rNewline.location == NSNotFound) {
            break;
        }
        [lines addObjectsFromArray:[self splitLines:[text substringToIndex:rNewline.location] offset:offset width:width]];
        text = [text substringFromIndex:rNewline.location + 1];
    }
    [lines addObjectsFromArray:[self splitLines:text offset:(int)offset width:width]];
    return lines;
}

- (NSArray *)splitLines:(NSString *)text offset:(int)offset width:(int)width {
    NSMutableArray *lines = [NSMutableArray arrayWithCapacity:1];
    if (text == nil) {
        return lines;
    }
    NSCharacterSet *wordSeparators = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSRange rPrevious = NSMakeRange(0, 0);
    while (YES) {
        // determine the next whitespace word separator position
        NSRange rWhitespace = [text rangeOfCharacterFromSet: wordSeparators options:NSCaseInsensitiveSearch range:NSMakeRange(rPrevious.location + rPrevious.length, [text length] - rPrevious.location - rPrevious.length)];
        NSString *textTest;
        if (rWhitespace.location == NSNotFound) {
            textTest = text;
        } else {
            textTest = [[text substringToIndex:rWhitespace.location] stringByTrimmingCharactersInSet:wordSeparators];
        }
        CGSize sizeTest = [textTest sizeWithFont:[UIFont systemFontOfSize:FEED_FONT_SIZE] forWidth: 4000 lineBreakMode: UILineBreakModeWordWrap];
        if (sizeTest.width + offset > width) {
            if (rPrevious.length == 0) {
                // case of a very long word that has to be cut
                while (YES) {
                    textTest = [textTest substringToIndex:[textTest length] - 1];
                    sizeTest = [textTest sizeWithFont:[UIFont systemFontOfSize:FEED_FONT_SIZE] forWidth: 4000 lineBreakMode: UILineBreakModeWordWrap];
                    if (sizeTest.width + offset <= width || [textTest length] == 0) {
                        [lines addObject:textTest];
                        text = [text substringFromIndex:[textTest length]];
                        rPrevious = NSMakeRange(0, 0);
                        offset = 0;
                        break;
                    }
                }
            } else {
                [lines addObject:[[text substringToIndex:rPrevious.location] stringByTrimmingCharactersInSet:wordSeparators]];
                text = [[text substringFromIndex:rPrevious.location] stringByTrimmingCharactersInSet:wordSeparators];
                rPrevious = NSMakeRange(0, 0);
                offset = 0;
            }
        } else {
            rPrevious = rWhitespace;
        }
        if (rPrevious.location == NSNotFound) {
            break;
        }
    }
    
    [lines addObject: [text stringByTrimmingCharactersInSet:wordSeparators]];
    
    return lines;
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
    
    [_loadMOreFoodter setHidden:YES];
    [_loadMOreFoodter hideLoadingFooter:self.tableView];
    
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    if ( [[FeedManager allParentsItem] count]>=20) {
        [_loadMOreFoodter showLoadingFooter:scrollView];  
    }      
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
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
        
    }else{
        DetailViewController *detail=[[DetailViewController alloc]initWithItem:item listener:nil];
        [self.navigationController pushViewController:detail animated:YES];
        [detail release];
    }
}


@end
