//
//  TutorialViewController.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 11/7/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "TutorialViewController.h"
#import "MyPageData.h"
#import "MyPageView.h"

#define kPlatformSupportsViewControllerHeirarchy ([self respondsToSelector:@selector(childViewControllers)] && [self.childViewControllers isKindOfClass:[NSArray class]])

@implementation TutorialViewController

- (id)init{
    
    self = [super init];
    self.title = @"Tutorial";
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)] autorelease];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(didClickBrowsePages:)] autorelease];
    return self;
}

-(void)done{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)didClickBrowsePages:(id)sender
{
	HGPageScrollView *pageScrollView = [self.view.subviews lastObject];
	
	if(pageScrollView.viewMode == HGPageScrollViewModePage){
		[pageScrollView deselectPageAnimated:YES];
	}else {
		[pageScrollView selectPageAtIndex:[pageScrollView indexForSelectedPage] animated:YES];
	}
	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _myPageDataArray = [[NSMutableArray alloc] initWithCapacity : kNumPages];
	
	for (int i=0; i<kNumPages; i++) {
		MyPageData *pageData = [[[MyPageData alloc] init] autorelease];
		pageData.title = [NSString stringWithFormat:@"%d: Title text", i];
		pageData.subtitle = [NSString stringWithFormat:@"%d: Subtitle text with some extra information", i];
		[_myPageDataArray addObject:pageData];
	}
    
	// now that we have the data, initialize the page scroll view
	_myPageScrollView = [[[NSBundle mainBundle] loadNibNamed:@"HGPageScrollView" owner:self options:nil] objectAtIndex:0];
	[self.view addSubview:_myPageScrollView];
}

#pragma mark -
#pragma mark HGPageScrollViewDataSource

- (NSInteger)numberOfPagesInScrollView:(HGPageScrollView *)scrollView;   // Default is 0 if not implemented
{
	return [_myPageDataArray count];
}

- (UIView *)pageScrollView:(HGPageScrollView *)scrollView headerViewForPageAtIndex:(NSInteger)index;
{
    MyPageData *pageData = [_myPageDataArray objectAtIndex:index];
    if (pageData.navController) {
        UIView *navBarCopy = [[[UINavigationBar alloc] initWithFrame:pageData.navController.navigationBar.frame] autorelease];
        return navBarCopy;
    }
    return nil;
}

- (HGPageView *)pageScrollView:(HGPageScrollView *)scrollView viewForPageAtIndex:(NSInteger)index;
{
    
    MyPageData *pageData = [_myPageDataArray objectAtIndex:index];
    if (pageData.navController) {
        
        if (kPlatformSupportsViewControllerHeirarchy) {
            // on iOS 5 use built-in view controller hierarchy support
            UIViewController *viewController = [self.childViewControllers objectAtIndex:0];
            return (HGPageView*)viewController.view;
        }else{
            return (HGPageView*)pageData.navController.topViewController.view;
        }
    }else{
        
        static NSString *pageId = @"pageId";
        MyPageView *pageView = (MyPageView*)[scrollView dequeueReusablePageWithIdentifier:pageId];
        if (!pageView) {
            // load a new page from NIB file
            pageView = [[[NSBundle mainBundle] loadNibNamed:@"MyPageView" owner:self options:nil] objectAtIndex:0];
            pageView.reuseIdentifier = pageId;
        }
        
        // configure the page
        UILabel *titleLabel = (UILabel*)[pageView viewWithTag:1];
        titleLabel.text = pageData.title;
        
        UIImageView *imageView = (UIImageView*)[pageView viewWithTag:2];
        imageView.image = pageData.image;
        
        //adjust content size of scroll view
        UIScrollView *pageContentsScrollView = (UIScrollView*)[pageView viewWithTag:10];
        pageContentsScrollView.scrollEnabled = NO; //initially disable scroll
        
        // set the pageView frame height
        CGRect frame = pageView.frame;
        frame.size.height = 420;
        pageView.frame = frame;
        
        return pageView;
    }
	
}

- (NSString *)pageScrollView:(HGPageScrollView *)scrollView titleForPageAtIndex:(NSInteger)index;
{
    id<PageHeaderInfo> headerInfo = (id<PageHeaderInfo>)[self headerInfoForPageAtIndex:index];
    return [headerInfo pageTitle];
    
}

- (NSString *)pageScrollView:(HGPageScrollView *)scrollView subtitleForPageAtIndex:(NSInteger)index;
{
    id<PageHeaderInfo> headerInfo = (id<PageHeaderInfo>)[self headerInfoForPageAtIndex:index];
    return [headerInfo pageSubtitle];
}

- (UIViewController*) headerInfoForPageAtIndex : (NSInteger) index
{
    MyPageData *pageData = [_myPageDataArray objectAtIndex:index];
    if (pageData.navController) {
        // in this sample project, the page at index 0 is a navigation controller.
        return pageData.navController.topViewController;
    }else{
        return [_myPageDataArray objectAtIndex:index];
    }
}

#pragma mark -
#pragma mark HGPageScrollViewDelegate

- (void)pageScrollView:(HGPageScrollView *)scrollView willSelectPageAtIndex:(NSInteger)index;
{
    MyPageData *pageData = [_myPageDataArray objectAtIndex:index];
    
    if (!pageData.navController) {
        MyPageView *page = (MyPageView*)[scrollView pageAtIndex:index];
        UIScrollView *pageContentsScrollView = (UIScrollView*)[page viewWithTag:10];
        
        if (!page.isInitialized) {
    
            // asjust text box height to show all text
            UITextView *textView = (UITextView*)[page viewWithTag:3];
            CGFloat margin = 12;
            CGSize size = [textView.text sizeWithFont:textView.font
                                    constrainedToSize:CGSizeMake(textView.frame.size.width, 2000) //very large height
                                        lineBreakMode:UILineBreakModeWordWrap];
            CGRect frame = textView.frame;
            frame. size.height = size.height + 4*margin;
            textView.frame = frame;
            
            // adjust content size of scroll view
            pageContentsScrollView.contentSize = CGSizeMake(pageContentsScrollView.frame.size.width, frame.origin.y + frame.size.height);
            
            page.isInitialized = YES;
        }
        
        // enable scroll
        pageContentsScrollView.scrollEnabled = YES;
        
    }else{
        if(kPlatformSupportsViewControllerHeirarchy) {
            UIViewController *childViewController = [self.childViewControllers objectAtIndex:0];
            [pageData.navController pushViewController:childViewController animated:NO];
        }
    }
    
}

- (void) pageScrollView:(HGPageScrollView *)scrollView didSelectPageAtIndex:(NSInteger)index
{
    MyPageData *pageData = [_myPageDataArray objectAtIndex:index];
    if (pageData.navController) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:pageData.navController animated:NO];
    }
    
}

- (void)pageScrollView:(HGPageScrollView *)scrollView willDeselectPageAtIndex:(NSInteger)index;
{
    MyPageData *pageData = [_myPageDataArray objectAtIndex:index];
    if (!pageData.navController) {
        // disable scroll of the contents page to avoid conflict with horizonal scroll of the pageScrollView
        HGPageView *page = [scrollView pageAtIndex:index];
        UIScrollView *scrollContentView = (UIScrollView*)[page viewWithTag:10];
        scrollContentView.scrollEnabled = NO;
        
    }else{
        if([self respondsToSelector:@selector(addChildViewController:)]) {
            
            UIViewController *viewController = pageData.navController.topViewController;
            [self addChildViewController:viewController];
        }
    }
    
}

- (void)pageScrollView:(HGPageScrollView *)scrollView didDeselectPageAtIndex:(NSInteger)index{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
