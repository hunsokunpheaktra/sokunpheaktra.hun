//
//  WebViewController.m
//  CRMiOS
//
//  Created by Sy Pauv on 8/3/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController (PrivateMethods)
- (void)hideGradientBackground:(UIView*)theView;
@end

@implementation WebViewController
@synthesize item,myWebView,gadget_id,indicSync;

- (id)initWithItem:(NSDictionary *)newItem gadgetid:(NSString *)newid{
    self.gadget_id=newid;
    self.item = newItem;
    return  [super init];
}

- (void)dealloc
{
    [myWebView setDelegate:nil];
    [myWebView release];
    [super dealloc];
}
- (void)saveImage{

     NSString *image=[item objectForKey:@"image"];
     UIImage *picture = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:image]]];
    [PictureManager save:gadget_id data:UIImageJPEGRepresentation(picture, 0.5)];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Image Saving" message:@"Image Saved." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alert show];
    [alert release];
    
}

- (void) hideGradientBackground:(UIView*)theView
{
    for (UIView * subview in theView.subviews)
    {
        if ([subview isKindOfClass:[UIImageView class]])
            subview.hidden = YES;
        
        [self hideGradientBackground:subview];
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
       
    self.myWebView=[[UIWebView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.myWebView.delegate=self;
    [myWebView setBackgroundColor:[UIColor clearColor]];
    [self hideGradientBackground:self.myWebView];
    self.title=[item objectForKey:@"name"];
    
    [myWebView setScalesPageToFit:YES];
    
    [myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[item objectForKey:@"link"]]]];
    
    NSLog(@"sme %@",[self.item objectForKey:@"image"]);
    
    if([self.item objectForKey:@"image"]!=nil && ![[self.item objectForKey:@"image"] isEqualToString:@""])self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc]initWithTitle:@"save image" style:UIBarButtonItemStyleDone target:self action:@selector(saveImage)]autorelease];
    
    self.view = myWebView;
    
    // show loading 
    indicSync = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicSync setFrame:CGRectMake(0,0, 50, 50)];
    indicSync.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    indicSync.center=self.view.center;
    UILabel *loading=[[UILabel alloc]initWithFrame:CGRectMake(0,50,100, 20)];
    loading.backgroundColor=[UIColor clearColor];
    loading.font=[UIFont systemFontOfSize:14];
    loading.text= @"Loading...";
    
    [indicSync addSubview:loading];
    [self.view addSubview:indicSync];
    
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
    [self.indicSync startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.indicSync stopAnimating];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self.indicSync stopAnimating];
}

@end
