//
//  TakePictureController.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 1/9/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TakePictureController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{

    UIImagePickerController *imgPicker;
    UIPopoverController *popoverController;
}

@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) UIImagePickerController *imgPicker;

- (void)showCameraParent:(UIView *)parentView;
@end
