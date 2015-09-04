//
//  TakePictureController.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 1/9/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "TakePictureController.h"

@implementation TakePictureController
@synthesize popoverController,imgPicker;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imgPicker = [[UIImagePickerController alloc] init]; 
    self.imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera; 
	self.imgPicker.allowsEditing = YES;
	self.imgPicker.delegate = self;	
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {

    
    
}

-(void)showCameraParent:(UIView *)parentView{
    
    //check if idevice support with camera ?
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"CRM4Mobile" message:@"Camera is not available for this iDevice." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
        return;
    }
    
    if([self.popoverController isPopoverVisible])
    {
        //close the popover view if toolbar button was touched
        //again and popover is already visible
        
        [self.popoverController dismissPopoverAnimated:YES];
        [self release];
        return;
    }
    
    //create a popover controller
    self.popoverController = [[UIPopoverController alloc]
                              initWithContentViewController:self.imgPicker];
    //present the popover view non-modal with a
    //refrence to the toolbar button which was pressed
    
   CGRect rect=parentView.frame;
    [self.popoverController presentPopoverFromRect:rect inView:parentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}
-(void)dealloc{

    [imgPicker release];
    [super dealloc];

}

@end
