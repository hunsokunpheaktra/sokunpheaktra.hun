//
//  WebViewController.h
//  CRMiOS
//
//  Created by Sy Pauv on 8/3/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PictureManager.h"

@interface WebViewController : UIViewController<UIWebViewDelegate> {
    
    UIWebView *myWebView;
    NSDictionary *item;
    NSString *gadget_id;
    UIActivityIndicatorView *indicSync;
}
@property (nonatomic, retain) UIActivityIndicatorView *indicSync;
@property (nonatomic, retain) NSString *gadget_id;
@property (nonatomic, retain) NSDictionary *item;
@property (nonatomic, retain) UIWebView *myWebView;

- (id)initWithItem:(NSDictionary *)newItem gadgetid:(NSString *)newid;
- (void)saveImage;

@end
