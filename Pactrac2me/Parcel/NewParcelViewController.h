//
//  NewParcelViewController.h
//  Parcel
//
//  Created by Davin Pen on 10/2/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBArSDK.h"
#import "Item.h"
#import "UpdateListener.h"
#import <QuartzCore/QuartzCore.h>
#import "UpdateListener.h"
#import "BSKeyboardControls.h"
#import "SettingManager.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "PicklistPopupShowView.h"
#import "MBProgressHUD.h"
#import "SyncListener.h"

@interface NewParcelViewController : UITableViewController<ZBarReaderDelegate, UITextFieldDelegate,UITextViewDelegate, UpdateListener, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate,BSKeyboardControlsDelegate,UIAlertViewDelegate,EKEventEditViewDelegate,SyncListener,MBProgressHUDDelegate>{
    
    Item *currentItem;
    NSArray *sections;
    
    UIImagePickerController *imagePicker;
    UIButton *imageButton;
    PicklistPopupShowView *picklistPopup;
    
    NSMutableArray *listSendingAtt;
    
}
@property(nonatomic, retain)EKEventStore *eventStore;
@property(nonatomic, retain)EKCalendar *defaultCalendar;
@property(nonatomic,retain)NSObject<UpdateListener> *updateListener;
@property(nonatomic,retain)Item *currentItem;
@property(nonatomic,retain)MBProgressHUD *hud;
@property(nonatomic,retain)UIPopoverController *popover;

-(id)initWithItem:(Item*)item;
-(void)cancel;
-(void)scanBarcode;
-(void)save;
-(void)saveRecord;
-(void)changeImage:(UIButton*)button;
-(void)changePictureContent;
-(void)tapHandler:(UITapGestureRecognizer*)tap;
-(void)scrollViewToTextField:(id)textField;

-(NSString *)ocrImage:(UIImage *)uiImage;
-(void)checkTrackingNo;
-(void)showInputTrackingNumber;
-(void)showHud:(NSString*)textLabel;
-(void)hideHud:(NSString*)textLabel;

@end
