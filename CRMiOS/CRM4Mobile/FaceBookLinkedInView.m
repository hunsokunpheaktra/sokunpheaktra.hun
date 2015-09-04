//
//  FaceBookLinkedInView.m
//  CRMiOS
//
//  Created by Sy Pauv on 8/2/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//


#import "FaceBookLinkedInView.h"
#import "gadgetAppDelegate.h"

@implementation FaceBookLinkedInView
@synthesize mywebView,listResult,itemDetail,subtype,type,searchURL;
@synthesize indicSync,selected,imageDownloadsInProgress;

- (id)initwithItem:(Item *)newItem subtype:(NSObject<Subtype> *)stype type:(NSString *)types{
    
    self=[super initWithStyle:UITableViewStylePlain];
    self.itemDetail=newItem;
    self.subtype=stype;
    self.type=types;
    return self;
    
}

- (void)dealloc
{
    [imageDownloadsInProgress release];
    [listResult release];
    [mywebView setDelegate:nil];
    [mywebView release];
    [super dealloc];
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
     self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    // show loading
    indicSync = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicSync setFrame:CGRectMake(0,0, 50, 50)];
    indicSync.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    indicSync.center=self.view.center;
    UILabel *loading=[[UILabel alloc]initWithFrame:CGRectMake(0,50,100, 20)];
    loading.backgroundColor=[UIColor clearColor];
    loading.font=[UIFont systemFontOfSize:14];
    loading.text= @"Loading...";
    
    [indicSync addSubview:loading];
    [self.view addSubview:indicSync];
    
    self.title=type;
    self.mywebView=[[UIWebView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.mywebView.delegate=self;
    [mywebView setScalesPageToFit:YES];
    
    NSString *searchKey;
    if ([type isEqualToString:@"Facebook"]) {
        
        searchKey = [self.subtype getDisplayText:self.itemDetail];
        searchKey =[searchKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [self searchfacebook:searchKey];
        
    }
    else{
        searchKey=[[self.subtype getDisplayText:self.itemDetail] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        self.searchURL=[FacebookLinkedInTools getSearchURL:searchKey type:type];
        [mywebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[searchURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    }
    self.listResult=[[NSArray alloc] init];
    
    if ([type isEqualToString:@"Facebook"]) {
        self.btsave=[[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveimage)];
        self.btsave.enabled=false;
        self.navigationItem.rightBarButtonItem=self.btsave;
    }
    
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

- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    [indicSync startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [indicSync stopAnimating];
    
    if ([type isEqualToString:@"Facebook"]) {
        
        self.listResult = [FacebookLinkedInTools generateFacebookResult:self.mywebView];
        
        if (![webView isLoading]) {
            [mywebView setDelegate:nil];
            if ([listResult count]==1) {
                //Facebook if result there is only one record view profile directly
                NSDictionary *item=[listResult objectAtIndex:0];
                [mywebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[item objectForKey:@"link"]]]];
                self.view=mywebView;
                self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc]initWithTitle:@"save image" style:UIBarButtonItemStyleDone target:self action:@selector(saveimage)]autorelease];
                
            }else if([listResult count]==0){
                
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"FaceBook Search"
                                      message:@"Person not found !" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil];
                [alert show];
                [alert release];
                
            }
        }
        
    }else{
        NSString *currentURL = mywebView.request.URL.absoluteString;
        if ([searchURL isEqualToString:currentURL]) {
            self.listResult=[FacebookLinkedInTools generateLinkedInResult:self.mywebView];
        }else{
            //LinkedIn if return URL difference from search URl mean that there is only one record
            [mywebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:currentURL]]];
            self.view=mywebView;
        }
        mywebView.delegate = nil;
    }
    [self.tableView reloadData];
}

- (void)saveimage{
    
    //save facebook user email
    NSString *mail = [self.itemDetail.fields objectForKey:@"ContactEmail"];
    if ((mail == nil || [[mail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])&& [selected objectForKey:@"email"]!=nil) {
        [self.itemDetail.fields setObject:[selected objectForKey:@"email"] forKey:@"ContactEmail"];
        [EntityManager update:self.itemDetail modifiedLocally:YES];
    }
    
    if ([type isEqualToString:@"Facebook"]) {
        NSString *image=[[[selected objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
        UIImage *picture = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:image]]];
        [PictureManager save:[itemDetail.fields objectForKey:@"gadget_id"]  data:UIImageJPEGRepresentation(picture, 0.5)];
    }else{
        NSString *image=[[listResult objectAtIndex:0] objectForKey:@"image"];
        UIImage *picture = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:image]]];
        [PictureManager save:[itemDetail.fields objectForKey:@"gadget_id"] data:UIImagePNGRepresentation(picture)];
    }
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Image Saving" message:@"Image Saved." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alert show];
    [alert release];
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [indicSync stopAnimating];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [listResult count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    NSDictionary *item=[self.listResult objectAtIndex:indexPath.row];
    cell.textLabel.text = [item objectForKey:@"name"];
    
    if ([type isEqualToString:@"LinkedIn"]) {
        cell.detailTextLabel.text=[item objectForKey:@"title"];
    }else{
        cell.detailTextLabel.text=nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (selected!=nil && [[selected objectForKey:@"id"] isEqualToString:[item objectForKey:@"id"]]) {
            cell.accessoryType=UITableViewCellAccessoryCheckmark;
        }
    }
    
    cell.imageView.image = [UIImage imageNamed:@"no_picture50x50.png"];
    if ([item objectForKey:@"image"]==nil)
    {
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
        {
            [self startIconDownload:(NSMutableDictionary *)item forIndexPath:indexPath];
        }
    }
    else
    {
        cell.imageView.image = [item objectForKey:@"image"];
    }
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([type isEqualToString:@"Facebook"]) {
        if (self.lastindex!=nil) {
            [[self.tableView cellForRowAtIndexPath:self.lastindex] setAccessoryType:UITableViewCellAccessoryNone];
        }
        NSDictionary *item=[self.listResult objectAtIndex:indexPath.row];
        selected=item;
        self.lastindex=indexPath;
        self.btsave.enabled=TRUE;
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else{
        WebViewController *webview=[[WebViewController alloc]initWithItem:[listResult objectAtIndex:indexPath.row] gadgetid:[self.itemDetail.fields objectForKey:@"gadget_id"]];
        [self.navigationController pushViewController:webview animated:YES];
        [webview release];
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return [type isEqualToString:@"LinkedIn"]? 90:70;
//}

-(void)searchfacebook:(NSString *)key{
    [self.indicSync startAnimating];
    gadgetAppDelegate *appDelegate = (gadgetAppDelegate *)[[UIApplication sharedApplication]delegate];
    if (appDelegate.facebook.isSessionValid) {
        // valid account UI is shown whenever the session is open
        NSString *url=[NSString stringWithFormat:@"https://graph.facebook.com/search?q=%@&fields=id,name,picture,email&type=user&access_token=%@",key,
                       appDelegate.facebook.accessToken];
        
        FaceBookSearch *search = [[FaceBookSearch alloc]init];
        [search doRequest:self :url];
        [search release];
        
    } else {
        appDelegate.facebook = [[Facebook alloc] initWithAppId:FB_appId andDelegate:self];
        [appDelegate.facebook authorize:[NSArray arrayWithObjects:@"email", nil]];
    }
}

#pragma mark - FacebookSession Delegate

/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin{
    gadgetAppDelegate *appDelegate = (gadgetAppDelegate *)[[UIApplication sharedApplication]delegate];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:appDelegate.facebook.accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:appDelegate.facebook.expirationDate forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    NSString *searchKey = [self.subtype getDisplayText:self.itemDetail];
    searchKey =[searchKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self searchfacebook:searchKey];
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled{
    [self.indicSync startAnimating];
}
- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt{
    
}
- (void)fbDidLogout{
}
- (void)fbSessionInvalidated{}

#pragma mark- Facebook search delete
-(void)field:(NSString *)error{
    
}
-(void)complete:(NSArray *)list{
    [self.indicSync stopAnimating];
    if ([list count]==0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Facebook" message:@"Person Not found!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    self.listResult=list;
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark Table cell image support

- (void)startIconDownload:(NSMutableDictionary *)appRecord forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.item = appRecord;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
        [iconDownloader release];
    }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([self.listResult count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            NSMutableDictionary *appRecord = [self.listResult objectAtIndex:indexPath.row];
            
            if ([appRecord objectForKey:@"image"]==nil) // avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:appRecord forIndexPath:indexPath];
            }else{
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                // Display the newly loaded image
                cell.imageView.image = [appRecord objectForKey:@"image"];
            }
        }
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        // Display the newly loaded image
        cell.imageView.image = [iconDownloader.item objectForKey:@"image"];
    }
    
    // Remove the IconDownloader from the in progress list.
    // This will result in it being deallocated.
    [imageDownloadsInProgress removeObjectForKey:indexPath];
}


#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}


@end
