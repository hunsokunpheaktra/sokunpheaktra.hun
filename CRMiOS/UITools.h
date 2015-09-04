//
//  UITools.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/29/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "Configuration.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "MailControllerDelegate.h"
#import "RelationManager.h"
#import "FieldsManager.h"
#import "CurrentUserManager.h"
#import "MapViewController.h"
#import "PicklistManager.h"
#import "UpdateListener.h"
#import "PictureManager.h"
#import "Configuration.h"

@interface UITools : NSObject {
    
}

+ (void)setupCell:(UITableViewCell *)cell subtype:(NSString *)subtype code:(NSString *)code value:(NSString *)value 
         grouping:(BOOL)grouping item:(Item *)item iphone:(BOOL)iphone;

+ (void)handleCellClick:(UIViewController *)controller code:(NSString *)code item:(Item *)item updateListener:(NSObject<UpdateListener> *)listener;

+ (NSString *)formatDateTime:(NSString *)type value:(NSString *)value shortStyle:(BOOL)shortStyle;

+ (void)setupEditCell:(UITableViewCell *)cell subtype:(NSString *)subtype field:(CRMField *)field value:(NSString *)value tag:(int)tag delegate:(NSObject <UITextViewDelegate, UITextFieldDelegate> *)delegate item:(Item *)item iphone:(BOOL)iphone;


+ (void)initDatePicker:(UIDatePicker *)datePicker value:(NSString *)value type:(NSString *)type;

+ (BOOL)contentTypeIsImageData:(NSData *)data;
+ (void)contactPicture:(UITableView *)table item:(Item *)detail button:(UIButton *)chooseImage;

+ (UIColor *)readHexColorCode:(NSString *)hexcode;

+ (NSString *)formatPDFDisplayValue:(CRMField *)field value:(Item *)item;

+ (NSArray *)filterFields:(NSArray *)fields subtype:(NSString *)subtype;
+ (void)initCheckboxes:(Item *)detail sections:(NSArray *)sections;
+ (CGSize)computeImageSize:(UIImage *)image forSize:(int)maxSize;
+ (NSString *)getAttachmentIcon:(SublistItem *)subItem;
+ (NSString *)getAttachmentExtension:(SublistItem *)subItem;
+ (NSDateFormatter *)getDateFormatter:(NSString *)type;

@end
