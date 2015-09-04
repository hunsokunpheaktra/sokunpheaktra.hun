//
//  AnnotationDetailViewController.h
//  CRMiOS
//
//  Created by Hun Sokunpheaktra on 8/31/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AnnotationDetailViewController : UIViewController{
    
    UIWebView *webview;
    NSString *url;
    
}

@property (nonatomic,retain) UIWebView *webview;
@property (nonatomic,retain) NSString *url;

- (id)initWithUrl:(NSString *)newUrl;

@end
