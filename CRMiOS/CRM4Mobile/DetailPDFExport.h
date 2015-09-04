//
//  DetailPDFExport.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/2/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Item.h"
#import "Subtype.h"
#import "Section.h"
#import "EvaluateTools.h"
#import "UITools.h"
#import "Configuration.h"

@interface DetailPDFExport : UIViewController<MFMailComposeViewControllerDelegate>{

    Item *item;
    NSObject<Subtype> *info;
    NSArray *sections;
    
}
@property (nonatomic,retain) NSObject<Subtype> *info;
@property (nonatomic, retain) NSArray *sections;
@property (nonatomic,retain) Item *item;

- (id)initWithDetail:(Item *)newItem Layout:(NSArray *)detail type:(NSObject<Subtype> *) type;
- (void)sendMail;
- (NSString*)getPDFFileName;
- (void)drawPDFLayout;
- (void)showPDFFile;
- (void)back;
- (void)drawReportFooter:(CGFloat)maxWidth height:(CGFloat)maxHeight;
- (void)drawCompanyLogo;

@end
