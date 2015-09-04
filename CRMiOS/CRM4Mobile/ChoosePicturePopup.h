//
//  PictureManager.h
//  CRMiOS
//
//  Created by Sy Pauv on 10/27/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Item.h"
#import "PictureManager.h"


@interface ChoosePicturePopup : UIViewController <UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    
    UIImagePickerController *imgPicker;
    UIPopoverController *popoverController;
    UIButton *newButton;
    Item *item;
    UIView *parent;
    
}
@property (nonatomic, retain) UIView *parent;
@property (nonatomic, retain) Item *item;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) UIImagePickerController *imgPicker;

- (id)initWithItem:(Item *)newItem;
- (void)showPopup:(id)sender parent:(UIView *)parentView;
- (void)deletePhoto;

@end
