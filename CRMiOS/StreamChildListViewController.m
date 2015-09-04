//
//  StreamChildListViewController.m
//  SMBClient4Mobile
//
//  Created by Hun Sokunpheaktra on 10/8/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "StreamChildListViewController.h"
#import "FeedItem.h"

@implementation StreamChildListViewController

@synthesize totalHeight,myTable;

-(id)initWithChildComments:(NSArray*)childComments{
    
    self = [super init];
    listComments = childComments;
    CGRect frame = [UIScreen mainScreen].bounds;
    
    self.view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, self.totalHeight)] autorelease];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self calculateTotalHeight:frame.size.width];
    
    myTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.totalHeight) style:UITableViewStylePlain];
    myTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    myTable.scrollEnabled = NO;
    myTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    myTable.backgroundColor = [UIColor clearColor];
    myTable.delegate = self;
    myTable.dataSource = self;
    [self.view addSubview:myTable];
    
    return self;
}

-(void)dealloc{
    [super dealloc];
    [myTable release];
}

-(void)calculateTotalHeight:(float)width{
    
    self.totalHeight = 0;
    //calculate total height
    for(FeedItem *feed in listComments){
        //profile image height
        float profileImageHeight = 16 + 39;
        
        //calculate comment area height
        float backgroundWidth = width - 40;
        CGSize commentSize = [[feed getComment] sizeWithFont:[UIFont boldSystemFontOfSize:13]];
        float commentWidth = commentSize.width + 20;
        int commentLine = ceil(commentWidth / backgroundWidth);
        
        float height = profileImageHeight + (commentLine * commentSize.height);
        
        self.totalHeight += height;
    }
    
    
}

-(void)setViewFrame:(CGRect)rect{
    
    self.view.frame = rect;
    self.myTable.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    [self.myTable reloadData];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return listComments.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FeedItem *feed = [listComments objectAtIndex:indexPath.row];
    
    //profile image height
    float profileImageHeight = 16 + 39;
    
    //calculate comment area height
    float backgroundWidth = tableView.frame.size.width - 40;
    CGSize commentSize = [[feed getComment] sizeWithFont:[UIFont boldSystemFontOfSize:13]];
    float commentWidth = commentSize.width + 20;
    int commentLine = ceil(commentWidth / backgroundWidth);
    
    float height = profileImageHeight + (commentLine * commentSize.height);
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    for(UIView *subview in cell.contentView.subviews){
        [subview removeFromSuperview];
    }
    CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
    
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cellRect.size.width, cellRect.size.height-1)];
    background.backgroundColor = [UIColor colorWithRed:(235./255.) green:(238./255.) blue:(245./255.) alpha:1];
    [cell.contentView addSubview:background];
    [background release];
    
    FeedItem *feed = [listComments objectAtIndex:indexPath.row];
    float backgroundWidth = tableView.frame.size.width - 40;
    CGSize sizeComment = [[feed getComment] sizeWithFont:[UIFont boldSystemFontOfSize:13]];
    float commentWidth = sizeComment.width + 20;
    int commentLine = ceil(commentWidth / backgroundWidth);
    
    // picture
   // NSData *dataIMG =[PhotoUtile read:[feed getContactId]];
    NSData *imageData = [FeedManager getAvatar:[feed getUserId]];
    UIImage *image = imageData == nil ? [UIImage imageNamed:@"no-image.jpeg"] : [UIImage imageWithData:imageData];
    
    UIImageView *userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 44, 44)];
    userImageView.image = image;
    userImageView.layer.cornerRadius = 4;
    userImageView.layer.borderWidth = 0.1;
    userImageView.clipsToBounds = YES;
    [cell.contentView addSubview:userImageView];
    [userImageView release];
    
    // author label
    UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(65 , 0, cellRect.size.width-70, 30)];
    authorLabel.font = [UIFont boldSystemFontOfSize:14];
    authorLabel.text = [feed getFullName];
    authorLabel.textColor = [UIColor colorWithRed:0.0 green:0.2 blue:0.7 alpha:1.0];
    authorLabel.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:authorLabel];
    [authorLabel release];
    
    // date
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(65 , 22, cellRect.size.width-70, 20)];
    dateLabel.font = [UIFont systemFontOfSize:11];
    dateLabel.text = [feed getCreatedDateFormatted];
    dateLabel.textColor = [UIColor grayColor];
    dateLabel.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:dateLabel];
    [dateLabel release];
    
    UITextView *comment = [[UITextView alloc] initWithFrame:CGRectMake(58, 34, cellRect.size.width-70, (commentLine * sizeComment.height) + 10)];
    comment.editable = NO;
    comment.backgroundColor = [UIColor clearColor];
    comment.text = [feed getComment];
    comment.font = [UIFont fontWithName:@"Arial" size:14];
    comment.scrollEnabled = NO;
    [cell.contentView addSubview:comment];
    [comment release];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
