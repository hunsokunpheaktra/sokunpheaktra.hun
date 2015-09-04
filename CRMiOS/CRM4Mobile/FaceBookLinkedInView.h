//
//  FaceBookLinkedInView.h
//  CRMiOS
//
//  Created by Sy Pauv on 8/2/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import "Subtype.h"
#import "WebViewController.h"
#import "FacebookLinkedInTools.h"
#import "FaceBookSearch.h"
#import "FacebookListener.h"
#import "FBConnect.h"
#import "IconDownloader.h"

@interface FaceBookLinkedInView : UITableViewController<UIWebViewDelegate,FacebookListener,FBSessionDelegate,IconDownloaderDelegate> {
    NSObject<Subtype> *subtype;
    UIWebView *mywebView;
    NSArray *listResult;
    NSString *type;
    NSString *searchURL;
    Item *itemDetail;
    UIActivityIndicatorView *indicSync;
}
@property (nonatomic, retain) UIActivityIndicatorView *indicSync;
@property (nonatomic, retain) NSString *searchURL;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSObject<Subtype> *subtype;
@property (nonatomic, retain) Item *itemDetail;
@property (nonatomic, retain) NSArray *listResult;
@property (nonatomic, retain) UIWebView *mywebView;
@property (nonatomic, retain) NSDictionary *selected;
@property (nonatomic, retain) UIBarButtonItem *btsave;
@property (nonatomic, retain) NSIndexPath *lastindex;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;

- (id)initwithItem:(Item *)newItem subtype:(NSObject<Subtype> *)stype type:(NSString *)types;
- (void)saveimage;


@end
