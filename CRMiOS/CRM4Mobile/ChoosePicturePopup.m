//
//  PictureManager.m
//  CRMiOS
//
//  Created by Sy Pauv on 10/27/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "ChoosePicturePopup.h"


@implementation ChoosePicturePopup

@synthesize imgPicker,popoverController,item,parent;


- (id)initWithItem:(Item *)newItem{

    self.item=newItem;
    return [super init];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
   
    [newButton setImage:img forState:UIControlStateNormal];
    [newButton setTag:0];
	[self.popoverController dismissPopoverAnimated:YES];

}

-(void)dealloc{

    [super dealloc];
}

- (void)showPopup:(id)sender parent:(UIView *)parentView{

    newButton = (UIButton *)sender;
    self.parent=parentView;
    
    if([self.popoverController isPopoverVisible])
    {
        //close the popover view if toolbar button was touched
        //again and popover is already visible
        
        [self.popoverController dismissPopoverAnimated:YES];
        [self release];
        return;
    }
    
    CGRect rect = [newButton.superview convertRect:newButton.frame toView:parentView];
    
    if (newButton.tag==0) {
        
        UIActionSheet *popupSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                                delegate:self 
                                                       cancelButtonTitle:nil 
                                                  destructiveButtonTitle:@"Delete Photo" 
                                                       otherButtonTitles:@"Choose Photo",nil];
        
        popupSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [popupSheet showFromRect:rect inView:parentView animated:YES];      
        return;
    }
 
    // dismiss any left over popovers here
    self.imgPicker = [[UIImagePickerController alloc] init]; 
    self.imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; 
	self.imgPicker.allowsEditing = YES;
	self.imgPicker.delegate = self;	
	
    UIBarButtonItem *delete=[[UIBarButtonItem alloc]initWithTitle:@"delete" style:UIBarButtonItemStyleDone target:self action:@selector(deletePhoto)];
    self.imgPicker.navigationController.navigationItem.rightBarButtonItem=delete;
    
    //create a popover controller
    self.popoverController = [[UIPopoverController alloc]
                              initWithContentViewController:self.imgPicker];
    
    //present the popover view non-modal with a
    //refrence to the toolbar button which was pressed
 
    [self.popoverController presentPopoverFromRect:rect inView:parentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

}

- (void)deletePhoto{
    [newButton setImage:nil forState:UIControlStateNormal];
    [popoverController dismissPopoverAnimated:YES];

}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            newButton.tag=1;
            [newButton setImage:nil forState:UIControlStateNormal];
            [newButton setTitle:@"Add Image" forState:UIControlStateNormal];
            [popoverController dismissPopoverAnimated:YES];
            break;
            
        case 1:
            newButton.tag=1;
            [self showPopup:newButton parent:parent];    
            break;
    }
}

@end
