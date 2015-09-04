//
//  PDFCreator.h
//  Pactrac2me
//
//  Created by Hun Sokunpheaktra on 2/15/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"
#import <QuickLook/QuickLook.h>

@interface PDFCreator : NSObject<QLPreviewControllerDataSource>

@property(nonatomic,retain)Item *item;
@property(nonatomic,retain)UIViewController *parentController;
@property(nonatomic,retain)NSString *pdfFilePath;

-(id)initWithItem:(Item*)item parentController:(UIViewController*)parent;

-(void)generatePDF;

@end
