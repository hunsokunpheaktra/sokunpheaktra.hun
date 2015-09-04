//
//  MyClass.m
//  testPluginStackOverflow
//
//  Created by Carlos Williams on 2/03/12.
//  Copyright (c) 2012 Devgeeks. All rights reserved.
//

#import "MyClass.h"

@implementation MyClass

@synthesize callbackID;


-(CDVPlugin*) initWithWebView:(UIWebView*)theWebView
{
    self = (MyClass*)[super initWithWebView:theWebView];
    if (self) 
	{
        originalWebViewBounds = theWebView.bounds;
        viewController = [[SynchronizeViewController alloc] init];
        viewController.parentView = self;
        navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        navController.view.frame = originalWebViewBounds;
        navController.navigationBar.tintColor = [UIColor colorWithRed:(23.0/255.0) green:(155.0/255.0) blue:(192.0/255.0) alpha:1];
        
    }
    
    
    self.webView.superview.autoresizesSubviews = YES;
	[ self.webView.superview addSubview:navController.view];    
    return self;
}

-(void)returnToParentView {
    [[self.webView.superview.subviews lastObject] removeFromSuperview];
    [super writeJavascript:@"backFromNative()"];
}
- (void) print:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
{
	NSLog(@"%@",@"Hello, from MyClass.m!");
}

@end
