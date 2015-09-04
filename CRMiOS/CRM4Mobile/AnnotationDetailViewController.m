//
//  AnnotationDetailViewController.m
//  CRMiOS
//
//  Created by Hun Sokunpheaktra on 8/31/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "AnnotationDetailViewController.h"


@implementation AnnotationDetailViewController

@synthesize webview,url;

- (id)initWithUrl:(NSString *)newUrl{
    
    self = [super init];
    
    self.url = newUrl;
        
    return self;
    
}

-(void)dealloc{
    
    [webview release];
    [url release];
    [super dealloc];
    
}

-(void)viewDidLoad{
    
    self.webview = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.webview setScalesPageToFit:YES];
    self.view = webview;
    
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    [super viewDidLoad];
}

@end
