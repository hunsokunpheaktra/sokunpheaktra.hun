//
//  TakePictureViewController.h
//  Parcel
//
//  Created by Hun Sokunpheaktra on 12/4/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Item.h"

@interface TakePictureViewController : UITableViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate>{
    
    UIButton *imageView1;
    UIButton *imageView2;
    UIImagePickerController *imagePicker;
    UIPopoverController *popover;
    
    UIImage* imageChosen1;
    UIImage* imageChosen2;
    
    Item *currentItem;
    
    int bntSelected;
    
}

-(id)initWithItem:(Item*)item;
-(void)save;

@end
