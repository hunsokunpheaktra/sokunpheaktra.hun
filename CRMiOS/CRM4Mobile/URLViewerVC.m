//
//  PDFViewerVCViewController.m
//  CRMiOS
//
//  Created by Arnaud on 29/03/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import "URLViewerVC.h"


@implementation URLViewerVC

@synthesize url, data, mimeType;

- (id)initWithURL:(NSString *)pUrl {
    self = [super init];
    if (self) {
        self.url = pUrl;
        self.data = nil;
        self.mimeType = nil;
    }
    return self;
}


- (id)initWithData:(NSData *)pData extension:(NSString *)extension {
    self = [super init];
    if (self) {
        self.url = nil;
        self.data = pData;
        extension = [extension lowercaseString];
        if ([extension hasSuffix:@"pdf"]) {
            self.mimeType = @"application/pdf";
        } else if ([extension hasSuffix:@"png"]) {
            self.mimeType = @"image/png";
        } else if ([extension hasSuffix:@"jpg"]) {
            self.mimeType = @"image/jpg";
        } 
    }
    return self;
}

- (void)loadView {
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss)] autorelease];
    [self.navigationController.navigationBar setTintColor:[UITools readHexColorCode:[Configuration getProperty:@"headerColor"]]];
    
    UIWebView *webView = [[UIWebView alloc] init];
    if (self.url != nil) {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        [webView loadRequest:request];
    } else if (self.data != nil) {
        [webView loadData:self.data MIMEType:mimeType textEncodingName:@"UTF-8" baseURL:nil];
        [webView setContentMode:UIViewContentModeCenter];
    }

    [self setView:webView];
}

- (void)dismiss {
    [self dismissModalViewControllerAnimated:YES];
}


@end
