//
//  PDFViewController.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 3/20/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Subtype.h"
#import "Item.h"
#import <MessageUI/MessageUI.h>
#import "Configuration.h"
#import "UITools.h"

@interface PDFViewController : UIViewController<MFMailComposeViewControllerDelegate> {

    NSMutableArray *listData;
    NSObject<Subtype> *info;
    Section *section;
}

@property (nonatomic, retain) NSMutableArray *listData;
@property (nonatomic, retain) NSObject<Subtype> *info;
@property (nonatomic, retain) Section *section;

- (id)initWithData:(NSArray *)data info:(NSObject<Subtype> *)newInfo;
- (void)showPDFFile;
- (NSString*)getPDFFileName;
- (void)back;
- (void)sendMail;
- (void)drawPDF:(NSString*)fileName;
- (void)drawReportFooter:(CGFloat)maxWidth height:(CGFloat)maxHeight;
- (void)drawSeparateLine:(CGFloat)y color:(UIColor *)color;
- (CGFloat)drawTableHeader:(CGFloat)y colummWidth:(CGFloat)cWidth;
- (CGFloat)drawValue:(Item *)item colummWidth:(CGFloat)cWidth y:(CGFloat)y;
- (void)reloadData:(NSArray *)datas;


@end
