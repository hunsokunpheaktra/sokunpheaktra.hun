//
//  NewParcelViewController.m
//  Parcel
//
//  Created by Davin Pen on 10/2/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "NewParcelViewController.h"
#import "ParcelEntityManager.h"
#import "CustomTableViewCell.h"
#import "PhotoUtile.h"
#import "MainViewController.h"
#import "ParcelItem.h"
#import "Base64.h"
#import "TakePictureViewController.h"
#import "SearchFields.h"
#import "baseapi.h"
#import "ProviderManager.h"
#import "CustomTextView.h"
#import "DEFacebookComposeViewController.h"
#import "Reachability.h"
#import "AttachmentEntitymanager.h"
#import "CreateRecordRequest.h"
#import "QueryRequest.h"
#import "LoginRequest.h"
#import "AppDelegate.h"
#import "SearchDataViewController.h"
#import "NotInCriteria.h"

@interface NewParcelViewController(){
    TessBaseAPI *ocrScanner;
}

@end

@implementation NewParcelViewController

@synthesize currentItem,updateListener,eventStore,popover;

-(id)initWithItem:(Item*)item{
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    self.currentItem = item;
    
    self.title = [item.fields objectForKey:@"local_id"] ? EDIT_PARCEL : NEW_PARCEL;
    if([currentItem.fields objectForKey:@"local_id"] == nil){
        self.navigationItem.leftBarButtonItem = [[CustomUIBarButtonItem alloc] initWithText:@"Cancel" target:self action:@selector(cancel)];
    }
    
    self.navigationItem.rightBarButtonItem = [[CustomUIBarButtonItem alloc] initWithText:@"Save" target:self action:@selector(save)];
    
    return self;
}

-(void)cancel{
    [self.view endEditing:YES];
    
    currentItem = [[Item alloc] init:@"Parcel" fields:[ParcelItem newItem]];
    [MainViewController getInstance].selectedIndex = 0;
    
    UINavigationController *nav = [[MainViewController getInstance].viewControllers objectAtIndex:0];
    [nav popToRootViewControllerAnimated:NO];
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(picklistPopup){
        [picklistPopup hide];
    }
    
    if ([self.title isEqualToString:NEW_PARCEL]) {
        if ([[self.currentItem.fields valueForKey:@"shippingDate"] length] == 0) {
            NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
            formatter.dateFormat = @"yyyy-MMM-dd";
            [currentItem.fields setValue:[formatter stringFromDate:[NSDate new]] forKey:@"shippingDate"];
        }
    }
    
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *background = [[[UIView alloc] initWithFrame:self.tableView.frame] autorelease];
    background.backgroundColor = [UIColor colorWithRed:(213./255.) green:(182./255.) blue:(145./255.) alpha:1];
    self.tableView.backgroundView = background;
    
	self.eventStore= [[EKEventStore alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    tap.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tap];
    [tap release];
    
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [imagePicker release];
    }
    sections = [ParcelItem allSections];
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 6.0){
        [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error){}];
    }
    
    //hud progress
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _hud.labelText = FINDING_STATUS;
    [self.view addSubview:_hud];
    
    //OCR Scanner
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    
    NSString *dataPath = [documentsDirectoryPath stringByAppendingPathComponent:@"tessdata"];
	/*
	 Set up the data in the docs dir
	 want to copy the data to the documents folder if it doesn't already exist
	 */
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:dataPath]) {
		// get the path to the app bundle (with the tessdata dir)
		NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
		NSString *tessdataPath = [bundlePath stringByAppendingPathComponent:@"tessdata"];
		if (tessdataPath) {
			[fileManager copyItemAtPath:tessdataPath toPath:dataPath error:NULL];
		}
	}
	
	NSString *dataPathWithSlash = [documentsDirectoryPath stringByAppendingString:@"/"];
	setenv("TESSDATA_PREFIX", [dataPathWithSlash UTF8String], 1);
	
	// init the tesseract engine.
	ocrScanner = new TessBaseAPI();
	
	ocrScanner->SimpleInit([dataPath cStringUsingEncoding:NSUTF8StringEncoding],  // Path to tessdata-no ending /.
                           "eng",  // ISO 639-3 string or NULL.
                           false);

    listSendingAtt = [[NSMutableArray alloc] initWithCapacity:1];
    
    if([self.currentItem.fields objectForKey:@"local_id"] == nil){
        UIPasteboard *pastBoard = [UIPasteboard generalPasteboard];
        NSArray *listProvider = [ProviderManager checkTrackingNumber:pastBoard.string];
        if(listProvider.count > 0){
            [self.currentItem.fields setObject:pastBoard.string forKey:@"trackingNo"];
            [self.currentItem.fields setObject:[listProvider objectAtIndex:0] forKey:@"forwarder"];
        }
    }
    
}

-(void)dealloc{
    [super dealloc];
    [sections release];
    [eventStore release];
    [imagePicker release];
    [picklistPopup release];
    [listSendingAtt release];
}

-(void)showHud:(NSString*)textLabel{
    if(textLabel != nil) _hud.labelText = textLabel;
    [_hud show:YES];
    self.navigationController.view.userInteractionEnabled = NO;
}
-(void)hideHud:(NSString*)textLabel{
    if(textLabel != nil) _hud.labelText = textLabel;
    [_hud hide:YES];
    self.navigationController.view.userInteractionEnabled = YES;
}

-(void)save{
    
    [self.view endEditing:YES];
    
    NSString *trackingNo = [currentItem.fields objectForKey:@"trackingNo"];
    trackingNo = [trackingNo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    trackingNo = trackingNo==nil ? @"" : trackingNo;
    
    NSString *forwarder = [currentItem.fields objectForKey:@"forwarder"];
    forwarder = forwarder==nil ? @"" : forwarder;
    
    //check empty trackingNo or forwarder
    if([trackingNo isEqualToString:@""] || [forwarder isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:SAVE_PARCEL_ERROR message:REQUIRED_FIELD_ERROR delegate:self cancelButtonTitle:MSG_OK otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    //check exist trackingNo
    Item* user = [MainViewController getInstance].user;
    
    NSString *userId = [user.fields objectForKey:@"id"];
    userId = userId==nil ? @"" : userId;
    userId = [userId isEqualToString:@""] ? [user.fields objectForKey:@"local_id"] : userId;
    
    NSMutableDictionary* criterias = [[NSMutableDictionary alloc] init];
    [criterias setValue:[[[ValuesCriteria alloc] initWithString:userId] autorelease] forKey:@"user_email"];
    [criterias setValue:[[[ValuesCriteria alloc] initWithString:[currentItem.fields objectForKey:@"trackingNo"]] autorelease] forKey:@"trackingNo"];
    [criterias setValue:[[[ValuesCriteria alloc] initWithString:@"0"] autorelease] forKey:@"deleted"];
    
    NSString *localId = [self.currentItem.fields objectForKey:@"local_id"];
    if(localId != nil){
        [criterias setValue:[[[NotInCriteria alloc] initWithValue:localId] autorelease] forKey:@"local_id"];
    }
    
    NSArray *itemsExisted = [ParcelEntityManager list:@"Parcel" criterias:criterias];
    [criterias release];
    
    if(itemsExisted.count > 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:TRACKING_DUPLICATED message:TRACKING_DUPLICATED_MESSAGE delegate:self cancelButtonTitle:MSG_YES otherButtonTitles:MSG_NO,nil];
        alert.tag = 1;
        [alert show];
        [alert release];
        return;
    }
    
    if([Reachability isNetWorkReachable:YES]){
        [self showHud:nil];
        [self performSelector:@selector(checkTrackingNo) withObject:nil afterDelay:0.1];
        
    }else{
        
        NSString *status = [self.currentItem.fields objectForKey:@"status"];
        status = status ? status : @"";
        NSString *forwarder = [self.currentItem.fields objectForKey:@"forwarder"];
        forwarder = forwarder ? forwarder : @"";
        
        if([status isEqualToString:@""] && [forwarder isEqualToString:@""]){
            [self.currentItem.fields setValue:@"No Status available" forKey:@"status"];
        }
        [self saveRecord];
    }
    
}

-(void)saveRecord{
    
    Item* user = [MainViewController getInstance].user;
    NSArray* searchField = [[SearchFields read] retain];
    NSString* searchString = @"";
    for (NSString* st in searchField) {
        if ([st isEqualToString:@"user_email"])
            searchString  = [searchString stringByAppendingString:[[user.fields valueForKey:@"email"] lowercaseString]];
        else {
            searchString  = [searchString stringByAppendingString:[[currentItem.fields valueForKey:st] lowercaseString]];
            searchString  = [searchString stringByAppendingString:@" "];
        }
            
    }
    
    [currentItem.fields setValue:searchString forKey:@"search"];
    [searchField release];
    
    //if has internet send record to server
    if([Reachability isNetWorkReachable:NO]){
        [self showHud:CONNECTING_SERVER];
        
        //checking salesforce login
        NSString *sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
        if(!sessionId){
            
            LoginRequest *login = [[LoginRequest alloc] init];
            [login doRequest:self];
            [login release];
            
        }else{
            [self userRequest];
        }
    }else{
        [self hideHud:nil];
        
        NSString *userId = [user.fields objectForKey:@"id"];
        userId = userId==nil ? @"" : userId;
        userId = [userId isEqualToString:@""] ? [user.fields objectForKey:@"local_id"] : userId;
        
        [currentItem.fields setValue:userId forKey:@"user_email"];
        
        if([currentItem.fields objectForKey:@"local_id"] == nil){
            
            [currentItem.fields setValue:@"2" forKey:@"modified"];
            [currentItem.fields setValue:@"0" forKey:@"deleted"];
            [currentItem.fields setValue:@"0" forKey:@"error"];
            
            [ParcelEntityManager insert:currentItem modifiedLocally:NO];
            [self cancel];
        }else{
            
            [ParcelEntityManager update:currentItem modifiedLocally:YES];
            if(updateListener){
                [updateListener mustUpdate:currentItem];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
    
}

/*
 * server sending record
**/
-(void)syncRecord{
    
    _hud.labelText = SENDING_RECORD;
    
    CreateRecordRequest *create = [[CreateRecordRequest alloc] initWithItem:self.currentItem];
    [create doRequest:self];
    [create release];
    
}

#pragma Login listener

- (void) userRequest {
    
    Item *user = [MainViewController getInstance].user;
    NSString *sql = [NSString stringWithFormat:@"SELECT Id,Email__c,First_Name__c,Last_Name__c,Password__c FROM Parcel_User__c WHERE Email__c = '%@'",[user.fields objectForKey:@"email"]];
    
    QueryRequest *query = [[QueryRequest alloc] initWithSQL:sql sobject:@"Parcel_User__c"];
    [query doRequest:self];
    [query release];
}

-(void)registerUser{
 
    Item *user = [MainViewController getInstance].user;
    NSString *uid = [user.fields objectForKey:@"id"];

    NSString *firstName = [user.fields objectForKey:@"first_name"];
    firstName = firstName ? firstName : @"";

    NSString *lastName = [user.fields objectForKey:@"last_name"];
    lastName = lastName ? lastName : @"";

    NSString *password = [user.fields objectForKey:@"password"];
    password = !password ? @"" : password;

    NSMutableDictionary *fields = [NSMutableDictionary dictionary];

    [fields setObject:firstName forKey:@"first_name"];
    [fields setObject:lastName.length == 0 ? @" ": lastName forKey:@"last_name"];
    [fields setObject:[user.fields objectForKey:@"email"] forKey:@"email"];
    [fields setObject:password forKey:@"password"];
    if(uid) [fields setObject:uid forKey:@"id"];
    
    Item *item = [[Item alloc] init:@"User" fields:fields];
    CreateRecordRequest *create = [[CreateRecordRequest alloc] initWithItem:item];
    [create doRequest:self];
    [create release];
 
}
 
-(void)registerDeviceToken{
 
    Item *user = [MainViewController getInstance].user;

    Item *item = [[Item alloc] init:@"Mobile_Device__c" fields:[NSDictionary dictionaryWithObjectsAndKeys:appdelegate.deviceTokenData,@"Name",[user.fields objectForKey:@"id"],@"Parcel_User__c" ,nil]];

    CreateRecordRequest *create = [[CreateRecordRequest alloc] initWithItem:item];
    [create doRequest:self];
    [create release];
 
}
 
-(void)checkDeviceToken{
 
    Item *user = [MainViewController getInstance].user;
    
    NSString *sql = [NSString stringWithFormat:@"select id,Name from Mobile_Device__c where Name = '%@' and Parcel_User__c = '%@'",appdelegate.deviceTokenData,[user.fields objectForKey:@"id"]];
     
    QueryRequest *query = [[QueryRequest alloc] initWithSQL:sql sobject:@"Mobile_Device__c"];
    [query doRequest:self];
    [query release];
 
 }

-(void)onSuccess:(id)req{
 
    SalesforceAPIRequest *request = req;
    Item *user = [MainViewController getInstance].user;

    if([request isKindOfClass:[QueryRequest class]]){
        
        QueryRequest *queryReq = (QueryRequest*)request;
        
        if([queryReq.sobject isEqualToString:@"Parcel_User__c"]){
            
            if(request.records.count > 0){
                Item *user = [MainViewController getInstance].user;
                if ([[user.fields valueForKey:@"modified"] isEqualToString:@"2"]){
                    
                    if (!(([[user.fields valueForKey:@"password"] isEqualToString:@""] || [user.fields valueForKey:@"password"] == nil )&&  ([[queryReq.records objectAtIndex:0] valueForKey:@"Password__c" ] == [NSNull null]))) {
                        
                        
                        if (![[user.fields valueForKey:@"password"] isEqualToString:[[queryReq.records objectAtIndex:0] valueForKey:@"Password__c"]]) {
                            [self onFailure:@"INVALID_PASSWORD" request:req];
                            return;
                        }
                    }
                    
                }
                
                [user.fields setObject:[[request.records objectAtIndex:0] objectForKey:@"Id"] forKey:@"id"];
                if (![[user.fields valueForKey:@"modified"] isEqualToString:@"1"]) {
                    if ([[request.records objectAtIndex:0] objectForKey:@"Password__c"] != nil)
                        [user.fields setObject:[[request.records objectAtIndex:0] objectForKey:@"Password__c"] forKey:@"password"];
                    if ([[request.records objectAtIndex:0] objectForKey:@"Last_Name__c"] != nil)
                        [user.fields setObject:[[request.records objectAtIndex:0] objectForKey:@"Last_Name__c"] forKey:@"last_name"];
                    if ([[request.records objectAtIndex:0] objectForKey:@"First_Name__c"] != nil)
                        [user.fields setObject:[[request.records objectAtIndex:0] objectForKey:@"First_Name__c"] forKey:@"first_name"];
                    [user.fields setObject:@"0" forKey:@"modified"];
                    [UserManager update:user];
                }
                
                if([[user.fields objectForKey:@"modified"] isEqualToString:@"1"]){
                    CreateRecordRequest *updateUser = [[CreateRecordRequest alloc] initWithItem:user];
                    [updateUser doRequest:self];
                    [updateUser release];
                }else{
                    [self checkDeviceToken];
                }
                
            }else{
                
                [self registerUser];
                
            }
            
        }else if([queryReq.sobject isEqualToString:@"Mobile_Device__c"]){
            
            if(request.records.count > 0){
                [self syncRecord];
            }else{
                [self registerDeviceToken];
            }

        }
    } else if([request isKindOfClass:[CreateRecordRequest class]]) {
        
        if([request.item.entity isEqualToString:@"Parcel_User__c"] || [request.item.entity isEqualToString:@"User"]) {
            [user.fields setObject:[request.item.fields objectForKey:@"id"] forKey:@"id"];
            [user.fields setObject:@"0" forKey:@"modified"];
            [UserManager update:user];
            
            [MainViewController getInstance].user = user;
            
            //update parcel user_email field to id
            NSMutableDictionary *criteria = [NSMutableDictionary dictionary];
            [criteria setObject:[[[ValuesCriteria alloc] initWithString:[user.fields objectForKey:@"local_id"]] autorelease] forKey:@"user_email"];
            NSArray *listParcel = [ParcelEntityManager list:@"Parcel" criterias:criteria];
            for(Item *item in listParcel){
                [item.fields setObject:[user.fields objectForKey:@"id"] forKey:@"user_email"];
                [ParcelEntityManager update:item modifiedLocally:NO];
                [item release];
            }
            
            Item *settingItem = [SettingManager find:@"Setting" column:@"user_email" value:[user.fields objectForKey:@"local_id"]];
            if(settingItem){
                [settingItem.fields setObject:[user.fields objectForKey:@"id"] forKey:@"user_email"];
                [SettingManager update:settingItem];
                [settingItem release];
            }
            
            if ([request.item.entity isEqualToString:@"User"]) [self checkDeviceToken];
        }else if([request.item.entity isEqualToString:@"Mobile_Device__c"]){
            
            [self syncRecord];

        }else if([request.item.entity isEqualToString:@"Parcel"]){
            
            if([self.currentItem.fields objectForKey:@"local_id"] == nil){
                
                NSString *userId = [user.fields objectForKey:@"id"];
                userId = userId==nil ? @"" : userId;
                userId = [userId isEqualToString:@""] ? [user.fields objectForKey:@"local_id"] : userId;
                
                [currentItem.fields setObject:[request.item.fields objectForKey:@"id"] forKey:@"id"];
                [currentItem.fields setValue:userId forKey:@"user_email"];
                [currentItem.fields setValue:@"0" forKey:@"modified"];
                [currentItem.fields setValue:@"0" forKey:@"deleted"];
                [currentItem.fields setValue:@"0" forKey:@"error"];
                
                [ParcelEntityManager insert:currentItem modifiedLocally:NO];
            }else{
                [ParcelEntityManager update:currentItem modifiedLocally:YES];
                if(updateListener){
                    [updateListener mustUpdate:currentItem];
                }
            }
            
            self.currentItem.attachments = [AttachmentEntitymanager findAttachmentByParentId:[currentItem.fields objectForKey:@"id"]];
            [listSendingAtt removeAllObjects];
            
            if(request.item.attachments!=nil && request.item.attachments.count > 0){
                
                if([self.currentItem.fields objectForKey:@"local_id"] != nil){
                    
                    //do update childs attachment
                    for (Item *t in self.currentItem.attachments.allValues) {
                        
                        if ([[t.fields objectForKey:@"modified"] isEqualToString:@"1"] || [[t.fields objectForKey:@"modified"] isEqualToString:@"2"]) {
                            
                            [t.fields setObject:[request.item.fields objectForKey:@"id"] forKey:@"ParentId"];
                            
                            UpsertAttachmentRequest *upAtt = [[UpsertAttachmentRequest alloc] initWithItem:t];
                            [upAtt doRequest:self];
                            [upAtt release];
                            
                            [listSendingAtt addObject:[t.fields objectForKey:@"Description"]];
                            
                        }
                    }
                    
                    if(listSendingAtt.count == 0){
                        [self hideHud:FINDING_STATUS];
                        
                        if([self.currentItem.fields objectForKey:@"local_id"] == nil){
                            [self cancel];
                        }else{
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                    }
                    
                }else{
                
                    //insert attachments
                    if (request.item.attachments!=nil) {
                        
                        for(Item *t in request.item.attachments.allValues) {
                            
                            [t.fields setObject:[request.item.fields objectForKey:@"id"] forKey:@"ParentId"];
                            [AttachmentEntitymanager update:t modifiedLocally:NO];
                            
                            UpsertAttachmentRequest *upsertatt = [[UpsertAttachmentRequest alloc] initWithItem:t];
                            [upsertatt doRequest:self];
                            [upsertatt release];
                            
                            [listSendingAtt addObject:[t.fields objectForKey:@"Description"]];
                        }
                    }
                }
            
            //no upsert attachment go to main screen
            }else{
                [self hideHud:FINDING_STATUS];
                
                if([self.currentItem.fields objectForKey:@"local_id"] == nil){
                    [self cancel];
                }else{
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
            }
            
        }
        
    }else if([request isKindOfClass:[UpsertAttachmentRequest class]]){
        
        NSString *lastKey = [listSendingAtt lastObject];
        NSString *des = [request.item.fields objectForKey:@"Description"];
        if([des isEqualToString:lastKey]){
        
            [self hideHud:FINDING_STATUS];
            
            if([self.currentItem.fields objectForKey:@"local_id"] == nil){
                [self cancel];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }
        
    }
 
}

-(void)onFailure:(NSString *)errorMessage request:(id)req{
 
    if([errorMessage isEqualToString:@"INVALID_SESSION_ID"]){
        
        LoginRequest *login = [[LoginRequest alloc] init];
        [login doRequest:self];
        [login release];
        
    }else if ([errorMessage rangeOfString:@"INVALID_PASSWORD"].location != NSNotFound) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:CONNECT_ERROR message:INVALID_PASSWORD_MESSAGE delegate:self cancelButtonTitle:MSG_OK otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == 1){
        
        Item* user = [MainViewController getInstance].user;
        
        NSString *userId = [user.fields objectForKey:@"id"];
        userId = userId==nil ? @"" : userId;
        userId = [userId isEqualToString:@""] ? [user.fields objectForKey:@"local_id"] : userId;
        
        NSMutableDictionary* criterias = [[NSMutableDictionary alloc] init];
        [criterias setValue:[[[ValuesCriteria alloc] initWithString:userId] autorelease] forKey:@"user_email"];
        [criterias setValue:[[[ValuesCriteria alloc] initWithString:[currentItem.fields objectForKey:@"trackingNo"]] autorelease] forKey:@"trackingNo"];
        [criterias setValue:[[[ValuesCriteria alloc] initWithString:@"0"] autorelease] forKey:@"deleted"];
        
        NSArray *itemsExisted = [ParcelEntityManager list:@"Parcel" criterias:criterias];
        [criterias release];
        
        if(buttonIndex == 0){
        
            Item *item = [itemsExisted objectAtIndex:0];
            [item.fields setObject:@"2" forKey:@"deleted"];
            [ParcelEntityManager update:item modifiedLocally:NO];
            
        }
        if([Reachability isNetWorkReachable:NO]){
            [self showHud:FINDING_STATUS];
            [self performSelector:@selector(checkTrackingNo) withObject:nil afterDelay:0.1];
            
        }else{
            [self.currentItem.fields setValue:@"No Status available" forKey:@"status"];
            [self saveRecord];
        }
    }
    
    if(alertView.tag == 2){
        
        if(buttonIndex == 0){
        
            [self.currentItem.fields setValue:@"No Status available" forKey:@"status"];
            [self saveRecord];
        }else{
            [self cancel];
        }
    }
    
}

-(void)scanBarcode{
    
    [self.view endEditing:YES];
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    
    ZBarImageScanner *scanner = reader.scanner;
    [scanner setSymbology: ZBAR_I25 config: ZBAR_CFG_ENABLE to: 0];
    
    // present and release the controller
    [self presentModalViewController:reader animated: YES];
    [reader release];
    
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
//    actionSheet.tag = 1;
//    actionSheet.title = @"Scan TrackingNo";
//    actionSheet.delegate = self;
//    
//    [actionSheet addButtonWithTitle:@"OCR-Code"];
//    [actionSheet addButtonWithTitle:@"BarCode & QR-Code"];
//    [actionSheet addButtonWithTitle:@"Cancel"];
//    actionSheet.cancelButtonIndex = 2;
//    
//    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
//        [actionSheet addButtonWithTitle:@"Cancel"];
//    }
//    
//    [actionSheet showFromTabBar:[MainViewController getInstance].tabBar];
//    [actionSheet release];
    
}

- (NSString *) ocrImage: (UIImage *) uiImage
{
	
	//code from http://robertcarlsen.net/2009/12/06/ocr-on-iphone-demo-1043
	
	CGSize imageSize = [uiImage size];
	double bytes_per_line	= CGImageGetBytesPerRow([uiImage CGImage]);
	double bytes_per_pixel	= CGImageGetBitsPerPixel([uiImage CGImage]) / 8.0;
	
	CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider([uiImage CGImage]));
	const UInt8 *imageData = CFDataGetBytePtr(data);
	
	// this could take a while. maybe needs to happen asynchronously.
	char* text = ocrScanner->TesseractRect(imageData,(int)bytes_per_pixel,(int)bytes_per_line, 0, 0,(int) imageSize.height,(int) imageSize.width);
	
	// Do something useful with the text!
	NSLog(@"Converted text: %@",[NSString stringWithCString:text encoding:NSUTF8StringEncoding]);
    
	return [NSString stringWithCString:text encoding:NSUTF8StringEncoding];
}


#pragma mark -
#pragma mark Text Field Delegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    NSString *fieldLabel = [textField.layer valueForKey:@"fieldLabel"];
    NSString *fieldName = [textField.layer valueForKey:@"fieldName"];
    NSIndexPath *indexPath = [textField.layer valueForKey:@"indexPath"];
    
    if([fieldName isEqualToString:@"shippingDate"] || [fieldName isEqualToString:@"reminderDate"]){
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
        return NO;
    }else if([fieldName isEqualToString:@"description"]){
        
        DEFacebookComposeViewController *facebookViewComposer = [[DEFacebookComposeViewController alloc] initWithParcel:currentItem textField:textField fieldItem:[NSDictionary dictionaryWithObjectsAndKeys:fieldLabel,@"fieldLabel",fieldName,@"fieldName", nil]];
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:facebookViewComposer animated:YES completion:^{ }];
        
        [facebookViewComposer release];
        
        return NO;
        
    }else if([fieldName isEqualToString:@"trackingNo"]){
        [self showInputTrackingNumber];
        return NO;
        
    }else if([fieldName isEqualToString:@"status"] || [fieldName isEqualToString:@"forwarder"]){
        return NO;
    }
    
    return YES;
}

-(void)showInputTrackingNumber{
    SearchDataViewController *search = [[SearchDataViewController alloc] initWithListener:self item:self.currentItem];
    [self presentModalViewController:search animated:YES];
    //[search release];
}

/* Editing began */
//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    if ([self.keyboardControls.textFields containsObject:textField])
//        self.keyboardControls.activeTextField = textField;
//
//    [self scrollViewToTextField:textField];
//}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    NSString *text = textField.text;
    text = text == nil ? @"" : text;
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *fieldName = [textField.layer valueForKey:@"fieldName"];
    [currentItem.fields setObject:text forKey:fieldName];
    
}

#pragma UITextView delegate

-(void)textViewDidEndEditing:(UITextView *)textView{
    NSString *text = textView.text;
    text = text == nil ? @"" : text;
    NSString *fieldName = [textView.layer valueForKey:@"fieldName"];
    [currentItem.fields setObject:text forKey:fieldName];
}

-(void)checkTrackingNo{
    
    NSString *status = [self.currentItem.fields objectForKey:@"status"];
    status = status==nil ? @"" : status;

    NSDictionary *provider = [ProviderManager findStatus:[currentItem.fields objectForKey:@"trackingNo"] forwarder:[currentItem.fields objectForKey:@"forwarder"]];
    
    if([[provider allKeys] count] == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:STATUS_NOT_FOUND message:ASK_SAVE_RECORD delegate:self cancelButtonTitle:MSG_YES otherButtonTitles:MSG_NO,nil];
        alert.tag = 2;
        [alert show];
        [alert release];
        [self hideHud:nil];
        return;
    }
    
    if([[provider allKeys] count] > 0){
        NSString *status = [provider valueForKey:@"keyStatus"];
        status = status == nil ? @"" : status;
        [currentItem.fields setObject:[provider valueForKey:@"providerName"] forKey:@"forwarder"];
        [currentItem.fields setObject:status forKey:@"status"];
    
    }
    
    
    [self saveRecord];
}

#pragma mark -
#pragma mark BSKeyboardControls Delegate

/* Scroll the view to the active text field */
- (void)scrollViewToTextField:(id)textField
{
    UITableViewCell *cell = (UITableViewCell *) ((UIView *) textField).superview.superview;
    [self.tableView scrollRectToVisible:cell.frame animated:YES];
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)controls
{
    [controls.activeTextField resignFirstResponder];
    
    UITextField *textField = controls.activeTextField;
    NSString *fieldName = [textField.layer valueForKey:@"fieldName"];
    NSString *text = textField.text ? textField.text : @"";
    [currentItem.fields setObject:text forKey:fieldName];
    
}

- (void)keyboardControlsPreviousNextPressed:(BSKeyboardControls *)controls withDirection:(KeyboardControlsDirection)direction andActiveTextField:(id)textField
{
    [self scrollViewToTextField:textField];
    [textField becomeFirstResponder];
}

-(void)didUpdate:(NSString *)fName value:(NSString *)value{
    
    if ([fName isEqualToString:@"reminderDate"] && ![value isEqualToString:@""]) {
        [self addEvent:value];
    }
    [self.currentItem.fields setObject:value forKey:fName];
    [self.tableView reloadData];
}
-(void)mustUpdate:(Item *)item{
    self.currentItem = item;
    [self.tableView reloadData];
}

-(void)changeImage:(UIButton*)button{
    
    [self.view endEditing:YES];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.tag = 2;
    actionSheet.title = TAKE_PICTURE;
    actionSheet.delegate = self;
    
    [actionSheet addButtonWithTitle:CAMERA];
    [actionSheet addButtonWithTitle:LIBRARY];
    [actionSheet addButtonWithTitle:MSG_CANCEL];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [actionSheet addButtonWithTitle:MSG_CANCEL];
    }
    
    actionSheet.cancelButtonIndex = 2;
    
    [actionSheet showFromTabBar:[MainViewController getInstance].tabBar];
    [actionSheet release];
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == 2)return;
    
    if(actionSheet.tag == 1){
        
        if(buttonIndex == 0){
            
            UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
            actionSheet.tag = 3;
            actionSheet.title = @"OCR Source";
            actionSheet.delegate = self;
            
            [actionSheet addButtonWithTitle:CAMERA];
            [actionSheet addButtonWithTitle:LIBRARY];
            [actionSheet addButtonWithTitle:MSG_CANCEL];
            
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                [actionSheet addButtonWithTitle:MSG_CANCEL];
            }
            
            actionSheet.cancelButtonIndex = 2;
            
            [actionSheet showFromTabBar:[MainViewController getInstance].tabBar];
            [actionSheet release];
            
            return;
            
        }else{
            
            [self.view endEditing:YES];
            ZBarReaderViewController *reader = [ZBarReaderViewController new];
            reader.readerDelegate = self;
            
            ZBarImageScanner *scanner = reader.scanner;
            [scanner setSymbology: ZBAR_I25 config: ZBAR_CFG_ENABLE to: 0];
            
            // present and release the controller
            [self presentModalViewController:reader animated: YES];
            [reader release];
            
            return;
        }
        
    }else{
        
        imagePicker.sourceType = buttonIndex == 0 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
        
    }
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        [self presentModalViewController:imagePicker animated:YES];
    }else{
        [popover presentPopoverFromRect:self.view.frame inView:self.view permittedArrowDirections:0 animated:NO];
    }
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return sections.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSArray *sec = [sections objectAtIndex:section];
    return section == 1 ? sec.count-2 : sec.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0) return 35;
    
    NSArray *section = [sections objectAtIndex:indexPath.section];
    NSDictionary *fieldItem = [section objectAtIndex:indexPath.row];
    NSString *fieldLabel = [fieldItem objectForKey:@"fieldLabel"];
    NSString *fieldName = [fieldItem objectForKey:@"fieldName"];
    NSString *value = [self.currentItem.fields objectForKey:fieldName];
    
    if([fieldName rangeOfString:@"pictureContent"].location != NSNotFound) return 50;
    if(fieldLabel.length > 20) return 60;
    if([fieldName isEqualToString:@"note"]) return 70;
    if([fieldName isEqualToString:@"status"]){
        if(value.length > 40) return 70;
    }
    
    return 40;
}
-(UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = nil;
    if (cell == nil) {
        if(indexPath.section == 0){
            cell = [[[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        }else{
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        }
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    CGRect frame = [tv rectForRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSArray *section = [sections objectAtIndex:indexPath.section];
    NSDictionary *fieldItem = [section objectAtIndex:indexPath.row];
    NSString *fieldName = [fieldItem objectForKey:@"fieldName"];
    NSString *fieldLabel = [fieldItem objectForKey:@"fieldLabel"];
    NSString *value = [currentItem.fields objectForKey:fieldName];
    value = value == nil ? @"" : value;
    
    if(indexPath.section == 0){
        
        float y = 2;
        if(indexPath.row == 1){
            y = -30;
        }else if(indexPath.row == 2){
            y = -68;
        }
    
        Item *att=[currentItem.attachments objectForKey:@"invoiceImage"];
        NSString *b64img=att==nil?@"":[att.fields objectForKey:@"body"];
        UIImage *image = [UIImage imageWithData:[Base64 decode:b64img]];
        
        imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        imageButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageButton setImage:image?image:[UIImage imageNamed:@"photo_48.png"] forState:UIControlStateNormal];
        imageButton.frame = CGRectMake(5, y, 120, 100);
        imageButton.backgroundColor = [UIColor colorWithRed:(248./255.) green:(246./255.) blue:(246./255.) alpha:1];
        [cell.contentView addSubview:imageButton];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(150, 0, frame.size.width-180, 30)];
        textField.font = [UIFont systemFontOfSize:13];
        textField.placeholder = fieldLabel;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.delegate = self;
        textField.text = value;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [textField.layer setValue:fieldName forKey:@"fieldName"];
        [textField.layer setValue:fieldLabel forKey:@"fieldLabel"];
        [cell.contentView addSubview:textField];
        [textField release];
        
        if([fieldName isEqualToString:@"trackingNo"] || [fieldName isEqualToString:@"forwarder"]){
            
            textField.placeholder = [NSString stringWithFormat:@"%@ %@",fieldLabel, REQUIRED];
            [textField.layer setValue:cell forKey:@"cell"];
            
            UIView *required = [[UIView alloc] initWithFrame:CGRectMake(142, 2, 4, 25)];
            required.backgroundColor = [UIColor redColor];
            [cell.contentView addSubview:required];
            [required release];
            
//            UIImageView *scanBarcode = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width-55, 0, 0, 0)];
//            scanBarcode.image = [UIImage imageNamed:@"0003.png"];
//            scanBarcode.userInteractionEnabled = YES;
//            [scanBarcode sizeToFit];
//            cell.accessoryView = scanBarcode;
//            [scanBarcode release];
            
        }
        
    }else{
        
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 2, 115, frame.size.height-10)];
        textView.editable = NO;
        textView.scrollEnabled = NO;
        textView.backgroundColor = [UIColor clearColor];
        textView.text = fieldLabel;
        textView.textAlignment = NSTextAlignmentRight;
        textView.font = [UIFont boldSystemFontOfSize:13];
        [cell.contentView addSubview:textView];
        [textView release];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if([fieldName isEqualToString:@"shippingDate"] || [fieldName isEqualToString:@"reminderDate"]){
            
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(123, 3, frame.size.width-150, 30)];
            textField.font = [UIFont boldSystemFontOfSize:14];
            textField.placeholder = fieldLabel;
            textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textField.delegate = self;
            textField.text = value;
            textField.font = [UIFont systemFontOfSize:13];
            [textField.layer setValue:fieldName forKey:@"fieldName"];
            [textField.layer setValue:indexPath forKey:@"indexPath"];
            [cell.contentView addSubview:textField];
            [textField release];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }else if([fieldName rangeOfString:@"pictureContent"].location != NSNotFound){
            

            Item *att=[currentItem.attachments objectForKey:@"pictureContent1"];
            NSString *b64img=att==nil?@"":[att.fields objectForKey:@"body"];
            UIImage *image = [UIImage imageWithData:[Base64 decode:b64img]];

            UIButton *pictureContent1 = [UIButton buttonWithType:UIButtonTypeCustom];
            pictureContent1.imageView.contentMode = UIViewContentModeScaleAspectFill;
            [pictureContent1 setImage:image forState:UIControlStateNormal];
            pictureContent1.frame = CGRectMake(123, 4, 40, 40);
            [cell.contentView addSubview:pictureContent1];
            
            float x = image ? 168 : 123;
            
            Item *att1=[currentItem.attachments objectForKey:@"pictureContent2"];
            NSString *b64img1=att1==nil?@"":[att1.fields objectForKey:@"body"];
            UIImage *image1 = [UIImage imageWithData:[Base64 decode:b64img1]];

            UIButton *pictureContent2 = [UIButton buttonWithType:UIButtonTypeCustom];
            pictureContent2.imageView.contentMode = UIViewContentModeScaleAspectFill;
            [pictureContent2 setImage:image1 forState:UIControlStateNormal];
            pictureContent2.frame = CGRectMake(x, 4, 40, 40);
            [cell.contentView addSubview:pictureContent2];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }else if([fieldName isEqualToString:@"note"]){
            
            float minus = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 220 : 150;
            
            CustomTextView *textView = [[CustomTextView alloc] initWithFrame:CGRectMake(114, 3, frame.size.width-minus, frame.size.height-10)];
            textView.font = [UIFont boldSystemFontOfSize:14];
            textView.backgroundColor = [UIColor clearColor];
            textView.placeholder = fieldLabel;
            textView.delegate = self;
            textView.text = value;
            textView.font = [UIFont systemFontOfSize:13];
            [textView.layer setValue:fieldName forKey:@"fieldName"];
            [cell.contentView addSubview:textView];
            [textView release];
            
        }else if([fieldName isEqualToString:@"status"]){
            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(114, 5, frame.size.width-150, frame.size.height-10)];
            textView.editable = NO;
            textView.scrollEnabled = NO;
            textView.backgroundColor = [UIColor clearColor];
            textView.text = value;
            textView.font = [UIFont systemFontOfSize:13];
            [cell.contentView addSubview:textView];
            [textView release];
        }else{
        
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(123, 3, frame.size.width-150, 30)];
            textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textField.placeholder = fieldLabel;
            textField.font = [UIFont systemFontOfSize:13];
            textField.delegate = self;
            textField.text = value;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            [textField.layer setValue:fieldName forKey:@"fieldName"];
            [cell.contentView addSubview:textField];
            [textField release];
            
        }
        
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *section = [sections objectAtIndex:indexPath.section];
    NSDictionary *fieldItem = [section objectAtIndex:indexPath.row];
    NSString *fieldLabel = [fieldItem objectForKey:@"fieldLabel"];
    NSString *fieldName = [fieldItem objectForKey:@"fieldName"];
    NSString *value = [currentItem.fields objectForKey:fieldName];
    value = value == nil ? @"" : value;
    
    if([fieldName isEqualToString:@"shippingDate"] || [fieldName isEqualToString:@"reminderDate"]){
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSString *type = @"picklist";
        
        NSArray *listItems;
        if([fieldName isEqualToString:@"sendProofOfDelivery"]){
            listItems = [[NSArray alloc] initWithObjects:EMAIL,PRINT,nil];
        }else if([fieldName isEqualToString:@"reminderDate"]){
            listItems = [[NSArray alloc] init];
            type = @"longdate";
        }else{
            listItems = [[NSArray alloc] init];
            type = @"date";
        }
        
        [self.view endEditing:YES];
        
        value = [value isEqualToString:@""] ? nil : value;
        
        if([fieldName isEqualToString:@"reminderDate"]){
            value=[self getDefaultReminderDate];
        }
        
        if(picklistPopup) [picklistPopup release];
        
        picklistPopup = [[PicklistPopupShowView alloc] initWithListDatas:listItems frame:[UIScreen mainScreen].bounds mainView:self.view selectedVal:value type:type];
        
        picklistPopup.fieldName = fieldName;
        picklistPopup.title = fieldLabel;
        picklistPopup.updateListener = self;
        [picklistPopup show:cell];
        
    }
    
    if([fieldName rangeOfString:@"pictureContent"].location != NSNotFound){
        [self changePictureContent];
    }
    
}

-(void)changePictureContent{
    
    TakePictureViewController *takePhoto = [[TakePictureViewController alloc] initWithItem:currentItem];
    [self.navigationController pushViewController:takePhoto animated:YES];
    [takePhoto release];
    
}

-(void)tapHandler:(UITapGestureRecognizer*)tap{
    
    CGPoint point = [tap locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    
    if(indexPath.section == 0){
        
        CGRect frame = [self.tableView rectForRowAtIndexPath:indexPath];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
        
        float leftX = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 15 : 40;
        float rightX = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? frame.size.width - 185 : frame.size.width - 590;
        
        if(point.x > leftX && point.x < rightX){
            [self changeImage:imageButton];
        }else if(indexPath.row == 1){
            
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
                if(point.x < frame.size.width-8 && point.x > frame.size.width-45){
                    [self scanBarcode];
                }
            }else{
                if(point.x < frame.size.width-35 && point.x > frame.size.width-65){
                    [self scanBarcode];
                }
            }
            
        }
        
    }
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [self.view viewWithTag:nextTag];
    if ([nextResponder isKindOfClass:[UITextField class]]) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else{
        [textField resignFirstResponder];
        nextResponder = [self.view viewWithTag:nextTag+1];
        [nextResponder becomeFirstResponder];
        // Not found, so remove keyboard
        
    }
    return NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    if([picker isKindOfClass:[ZBarReaderViewController class]]){
        
        // ADD: get the decode results
        id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
        ZBarSymbol *symbol = nil;
        for(symbol in results)
            break;
        
        [currentItem.fields setObject:symbol.data forKey:@"trackingNo"];
        [self.tableView reloadData];
        
        [picker dismissModalViewControllerAnimated:YES];
        
    }else{
        
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }
        
//        if(picker.view.tag == 3){
//            
//            [currentItem.fields setObject:[self ocrImage:image] forKey:@"trackingNo"];
//            [self.tableView reloadData];
//
//        }else{
        
        NSData *imageData = [PhotoUtile resizeImage:image];
        NSString *base64String = [Base64 encode:imageData];

        //RSK::add attachment
        Item *att = [currentItem.attachments objectForKey:@"invoiceImage"];
        if (att != nil) {
            [att.fields setValue:@"1" forKey:@"modified"];
            if ([[att.fields objectForKey:@"local_id"] isEqualToString:@""]) [att.fields setValue:@"2" forKey:@"modified"];
            [att.fields setObject:base64String forKey:@"body"];
        }else{
            Item *att=[[Item alloc]init:@"Attachment" fields:[AttachmentEntitymanager newAttachment]];
            [att.fields setValue:base64String forKey:@"body"];
            [att.fields setValue:@"invoiceImage" forKey:@"Description"];
            [att.fields setValue:@"2" forKey:@"modified"];
            [att.fields setValue:@"0" forKey:@"deleted"];
            [att.fields setValue:@"0" forKey:@"error"];
            [currentItem.attachments setObject:att forKey:@"invoiceImage"];
        }

        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
//        }
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            [popover dismissPopoverAnimated:YES];
        }else{
            [picker dismissViewControllerAnimated:YES completion:^void(){
                if(picker.view.tag == 2){
                    [self showInputTrackingNumber];
                }
            }];
        }
        
    }
    
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if([picker isKindOfClass:[ZBarReaderViewController class]]){
            [picker dismissModalViewControllerAnimated:YES];
        }
        [popover dismissPopoverAnimated:YES];
    }else{
        [picker dismissModalViewControllerAnimated:YES];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark -
#pragma mark Add a new event

- (void)addEvent:(id)sender {
    // Get the default calendar from store.
    
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 6.0){
        if ([EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent] == EKAuthorizationStatusAuthorized) {
            [self newEvent:sender];
        }else{
            UIAlertView *alert=[[[UIAlertView alloc]initWithTitle:CALENDAR message:CALENDAR_PERMISSION_ENABLE_MESSAGE delegate:self cancelButtonTitle:MSG_OK otherButtonTitles: nil] autorelease];
            [alert show];
            [alert release];
        }
    }else{
        [self newEvent:sender];
    }
}

-(void)newEvent:(NSString *)date{
    
    self.defaultCalendar = [self.eventStore defaultCalendarForNewEvents];
    // When add button is pushed, create an EKEventEditViewController to display the event.
    EKEventEditViewController *addController = [[EKEventEditViewController alloc] initWithNibName:nil bundle:nil];
    // set the addController's event store to the current event store.
    addController.eventStore = self.eventStore;
    addController.navigationBar.tintColor = [UIColor colorWithRed:0.1 green:0.3 blue:0.5 alpha:1.0];
    addController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    formatter.dateFormat = @"yyyy-MMM-dd HH:mm";
    addController.event.title=[self getTitle];
    addController.event.calendar=self.defaultCalendar;
    NSDate *startDate=[formatter dateFromString:date];
    addController.event.startDate=startDate;
    addController.event.endDate=[NSDate dateWithTimeInterval:30 sinceDate:startDate]; // changed from 3600 to 30
    
    addController.event.notes=[self.currentItem.fields objectForKey:@"note"];
    [self presentViewController:addController animated:YES completion:nil];
    addController.editViewDelegate = self;
    [addController release];
    
}

-(NSString *)getTitle{
    
    NSArray *titles=@[@"description",@"receiver",@"shippingDate",@"forwarder",@"trackingNo"];
    NSMutableString *title=[[NSMutableString alloc] initWithCapacity:1];
    [title appendString:REFUND_REMINDER];
    for (NSString *key in titles) {
        NSString *value=[self.currentItem.fields objectForKey:key];
        if (value !=nil && ![value isEqualToString:@""]) {
            [title appendFormat:@" %@",value];
        }
    }
    return title;
}

-(NSString *)getDefaultReminderDate{
    
    Item *user = [MainViewController getInstance].user;
    
    NSString *userId = [user.fields objectForKey:@"id"];
    userId = userId==nil ? @"" : userId;
    userId = [userId isEqualToString:@""] ? [user.fields objectForKey:@"local_id"] : userId;
    
    Item  *item = [SettingManager find:@"Setting" column:@"user_email" value:userId];
    
    NSString *defaultreminder = NSLocalizedString([item.fields objectForKey:@"defaultReminderSetting"], @"");
    NSString *shippingDate = [self.currentItem.fields objectForKey:@"shippingDate"];
    if (defaultreminder == nil || defaultreminder.length < 5) {
        defaultreminder = NSLocalizedString(@"1 WEEKS", @"");
    }
    
    //splite string option
    NSArray *defaultoption=[defaultreminder componentsSeparatedByString:@" "];
    int defaultAmout=0;
    if ([defaultoption count]==2) {
        defaultAmout = [[defaultoption objectAtIndex:0] intValue];
        if ([[item.fields objectForKey:@"defaultReminderSetting"] rangeOfString:@"WEEK"].location!=NSNotFound) {
            defaultAmout = defaultAmout*7;
        }
    }
    
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    formatter.dateFormat = @"yyyy-MMM-dd";
    NSDate *startDate; //=[NSDate date];
    
    if (shippingDate==nil || shippingDate.length == 0) { // || shippingDate.length==11
        startDate = [formatter dateFromString: [formatter stringFromDate:[NSDate date]]];
    }else {
        startDate = [formatter dateFromString:shippingDate];
    }
    
    if (defaultAmout>0) {
        NSDateComponents* components = [[[NSDateComponents alloc] init] autorelease];
        components.day = defaultAmout;
        components.hour = 8;
        NSCalendar* calendar = [[[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar] autorelease];
        startDate = [calendar dateByAddingComponents: components toDate: startDate options: 0];
    }
    
    
    formatter.dateFormat = @"yyyy-MMM-dd HH:mm";
    return [formatter stringFromDate:startDate];
    
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
        if(popover.isPopoverVisible){
            
            [popover dismissPopoverAnimated:NO];
            [popover presentPopoverFromRect:self.view.frame inView:self.view permittedArrowDirections:0 animated:NO];
            
        }
    }
    
}

#pragma mark -
#pragma mark EKEventEditViewDelegate

// Overriding EKEventEditViewDelegate method to update event store according to user actions.
- (void)eventEditViewController:(EKEventEditViewController *)controller
          didCompleteWithAction:(EKEventEditViewAction)action {
	
	NSError *error = nil;
	EKEvent *thisEvent = controller.event;
    
	
	switch (action) {
		case EKEventEditViewActionCanceled:{
			// Edit action canceled, do nothing.
			break;
        }
		case EKEventEditViewActionSaved:{
			// When user hit "Done" button, save the newly created event to the event store,
			// and reload table view.
			// If the new event is being added to the default calendar, then update its
			// eventsList.
            
            
			if (self.defaultCalendar ==  thisEvent.calendar) {
                
			}
            
            [controller.eventStore saveEvent:controller.event span:EKSpanThisEvent error:&error];
            
            NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
            formatter.dateFormat = @"yyyy-MMM-dd HH:mm";
            NSString* dateChange = [formatter stringFromDate:thisEvent.startDate];
            [self didUpdate:@"reminderDate" value:dateChange];
            
            
			break;
        }
		case EKEventEditViewActionDeleted:{
			// When deleting an event, remove the event from the event store,
			// and reload table view.
			// If deleting an event from the currenly default calendar, then update its
			// eventsList.
			if (self.defaultCalendar ==  thisEvent.calendar) {
                
			}
			[controller.eventStore removeEvent:thisEvent span:EKSpanThisEvent error:&error];
			break;
        }
		default:
			break;
	}
	// Dismiss the modal view controller
	[controller dismissViewControllerAnimated:YES completion:nil];
	
}

// Set the calendar edited by EKEventEditViewController to our chosen calendar - the default calendar.
- (EKCalendar *)eventEditViewControllerDefaultCalendarForNewEvents:(EKEventEditViewController *)controller {
	EKCalendar *calendarForEdit = self.defaultCalendar;
	return calendarForEdit;
}


@end
