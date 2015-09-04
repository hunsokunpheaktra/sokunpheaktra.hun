//
//  BasicPreviewItem.h
//  Pactrac2me
//
//  Created by Hun Sokunpheaktra on 3/1/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>

@interface BasicPreviewItem : NSObject<QLPreviewItem>

@property (atomic, retain) NSURL * previewItemURL;
@property (atomic, retain) NSString* previewItemTitle;

@end
