//
//  PDFViewerVCViewController.h
//  CRMiOS
//
//  Created by Arnaud on 29/03/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITools.h"

@interface URLViewerVC : UIViewController {
    NSString *url;
    NSData *data;
    NSString *mimeType;
}

@property (nonatomic, retain) NSString *mimeType;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSData *data;

- (id)initWithURL:(NSString *)pUrl;
- (id)initWithData:(NSData *)pData extension:(NSString *)extension;

@end
