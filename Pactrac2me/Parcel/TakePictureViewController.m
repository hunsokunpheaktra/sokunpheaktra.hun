//
//  TakePictureViewController.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 12/4/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "TakePictureViewController.h"
#import "Base64.h"
#import "MainViewController.h"
#import "AttachmentEntitymanager.h"

@implementation TakePictureViewController

-(id)initWithItem:(Item*)item
{
    currentItem = item;
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)] autorelease];
    self.title = PICTURE_CONTENT;
    return self;
}

-(void)save{

    if (imageChosen1 != nil) {
        NSData *imageData = UIImageJPEGRepresentation(imageChosen1, 0.1);
        NSString *base64String = [Base64 encode:imageData];
        [self modifyAttachment:@"pictureContent1" image:base64String];
    }
    if (imageChosen2 != nil) {
        NSData *imageData = UIImageJPEGRepresentation(imageChosen2, 0.1);
        NSString *base64String = [Base64 encode:imageData];
        [self modifyAttachment:@"pictureContent2" image:base64String];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)modifyAttachment:(NSString *)type image:(NSString *)b64string{
    if ([currentItem.attachments objectForKey:type]==nil) {
        Item *att=[[Item alloc]init:@"Attachment" fields:[AttachmentEntitymanager newAttachment]];
        [att.fields setValue:b64string forKey:@"body"];
        [att.fields setValue:type forKey:@"Description"];
        [att.fields setValue:@"2" forKey:@"modified"];
        [att.fields setValue:@"0" forKey:@"deleted"];
        [att.fields setValue:@"0" forKey:@"error"];
        [currentItem.attachments setObject:att forKey:type];
    }else{
        Item *att = [currentItem.attachments objectForKey:type];
        [att.fields setValue:@"1" forKey:@"modified"];
        if ([[att.fields objectForKey:@"local_id"] isEqualToString:@""]) [att.fields setValue:@"2" forKey:@"modified"];
        [att.fields setObject:b64string forKey:@"body"];
    }
}

-(void)takePhoto : (UIButton*) sender{
    
    bntSelected = sender.tag;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:TAKE_PICTURE delegate:self cancelButtonTitle: MSG_CANCEL destructiveButtonTitle:nil otherButtonTitles:CAMERA,LIBRARY, nil];
    [actionSheet showFromTabBar:[MainViewController getInstance].tabBar];
    [actionSheet release];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    Item *att=[currentItem.attachments objectForKey:@"pictureContent1"];
    NSString *b64img=att==nil?@"":[att.fields objectForKey:@"body"];
    UIImage *image = [UIImage imageWithData:[Base64 decode:b64img]];
    
    imageView1 = [UIButton buttonWithType:UIButtonTypeCustom];
    imageView1.imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView1.frame = CGRectMake(0, 50, 160, 140);
    imageView1.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    imageView1.backgroundColor = [UIColor colorWithRed:(248./255.) green:(246./255.) blue:(246./255.) alpha:1];
    imageView1.layer.borderColor = [UIColor whiteColor].CGColor;
    imageView1.layer.borderWidth = 3.5;
    imageView1.layer.shadowOpacity = 0.8;
    imageView1.layer.shadowRadius = 2;
    imageView1.layer.shadowOffset = CGSizeMake(0.3, 0.3);
    [imageView1 setImage:image?image:[UIImage imageNamed:@"camera-library@2x.png"] forState:UIControlStateNormal];
    
    UIButton *changePicture = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    changePicture.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [changePicture setTitle:CHANGE_PICTURE forState:UIControlStateNormal];
    changePicture.tag = 1;
    [changePicture addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    changePicture.frame = CGRectMake(0, 210, 150, 35);
    
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 260)] autorelease];
    [headerView addSubview:imageView1];
    [headerView addSubview:changePicture];
    
    self.tableView.tableHeaderView = headerView;
    

    Item *att1=[currentItem.attachments objectForKey:@"pictureContent2"];
    NSString *b64img1=att1==nil?@"":[att1.fields objectForKey:@"body"];
    UIImage *image1 = [UIImage imageWithData:[Base64 decode:b64img1]];    

    imageView2 = [UIButton buttonWithType:UIButtonTypeCustom];
    imageView2.imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView2.frame = CGRectMake(0, 0, 160, 140);
    imageView2.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    imageView2.backgroundColor = [UIColor colorWithRed:(248./255.) green:(246./255.) blue:(246./255.) alpha:1];
    imageView2.layer.borderColor = [UIColor whiteColor].CGColor;
    imageView2.layer.borderWidth = 3.5;
    imageView2.layer.shadowOpacity = 0.8;
    imageView2.layer.shadowRadius = 2;
    imageView2.layer.shadowOffset = CGSizeMake(0.3, 0.3);
    [imageView2 setImage:image1?image1:[UIImage imageNamed:@"camera-library@2x.png"] forState:UIControlStateNormal];
    
    changePicture = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    changePicture.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [changePicture setTitle:CHANGE_PICTURE forState:UIControlStateNormal];
    changePicture.tag = 2;
    [changePicture addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    changePicture.frame = CGRectMake(0, 160 , 150, 35);
    
    UIView *footerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 260)] autorelease];
    [footerView addSubview:imageView2];
    [footerView addSubview:changePicture];
    
    self.tableView.tableFooterView = footerView;
    
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [imagePicker release];
    }
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == 2) return;
    
    imagePicker.sourceType = buttonIndex == 0 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        [self presentModalViewController:imagePicker animated:YES];
    }else{
        [popover presentPopoverFromRect:self.view.frame inView:self.view permittedArrowDirections:0 animated:YES];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma ImagePicker - delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (bntSelected == 1) {
        imageChosen1 = image;
        [imageView1 setImage:image?image:[UIImage imageNamed:@"photo_48.png"] forState:UIControlStateNormal];
    }else {
        imageChosen2 = image;
        [imageView2 setImage:image?image:[UIImage imageNamed:@"photo_48.png"] forState:UIControlStateNormal];
    }
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [popover dismissPopoverAnimated:YES];
    }else{
        [picker dismissModalViewControllerAnimated:YES];
    }
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [popover dismissPopoverAnimated:YES];
    }else{
        [picker dismissModalViewControllerAnimated:YES];
    }
    
}

@end
