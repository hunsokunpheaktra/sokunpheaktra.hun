//
//  MyParcelViewController.m
//  Parcel
//
//  Created by Davin Pen on 10/2/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "MyParcelViewController.h"
#import "MyParcelDetailViewController.h"
#import "ParcelEntityManager.h"
#import "NewParcelViewController.h"
#import "PhotoUtile.h"
#import "LikeCriteria.h"
#import "PicklistPopupShowView.h"

#import "TutorialViewController.h"
#import "NSObject+SBJson.h"
#import "CRTableViewCell.h"
#import "ShowMapViewController.h"
#import "MainViewController.h"
#import "Base64.h"
#import "MyPhoto.h"
#import "MyPhotoSource.h"
#import "NotInCriteria.h"
#import "RequestUpdate.h"
#import "SettingManager.h"
#import "AppDelegate.h"
#import "DeleteRecordRequest.h"
#import "AttachmentEntitymanager.h"
#import "SynchronizedViewController.h"

@implementation MyParcelViewController

@synthesize tableView,searchBar;

- (id)init
{
    
    [self performSelector:@selector(addUIBarButtonItems:)];
    self = [super init];
    return self;
    
}

-(void)dealloc{
    [super dealloc];
    [_hud release];
    [allParcels release];
    [originalParcels release];
}

-(void)openTutorial{
    
    TutorialViewController *tutorial = [[TutorialViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tutorial];
    [tutorial release];
    
    [self presentModalViewController:nav animated:YES];
    [nav release];
    
}

-(void)refresh{
    
    NSString *text = self.searchBar.text;
    text = text != nil ? text : @"";
    
    if([text isEqualToString:@""]){
        [allParcels release];
        allParcels = [[NSMutableArray alloc] initWithArray:originalParcels];
    }else{
        
        if (![[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
            text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        
        
        [allParcels removeAllObjects];
        for(Item *item in originalParcels){
            NSString* searchFieldValue = [item.fields valueForKey:@"search"];
            if ([searchFieldValue rangeOfString:[text lowercaseString]].location != NSNotFound ) {
                [allParcels addObject:item];
            }
        }
    }
    [self.tableView reloadData];
    
}

-(void)addParcel{
    
    MainViewController *main = [MainViewController getInstance];
    main.selectedIndex = 1;
    UINavigationController *nav = (UINavigationController*)[main.viewControllers objectAtIndex:1];
    NewParcelViewController *addParcel = (NewParcelViewController*)nav.topViewController;
    addParcel.updateListener = self;
    [main tabBar:main.tabBar didSelectItem:nav.topViewController.tabBarItem];
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    searchBar.text = @"";
    [self performSelector:@selector(getAllParcelBySorting:)];
    //[self performSelector:@selector(doneEdit:)];
    
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    CGRect frame = self.view.frame;
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    searchBar.placeholder = FIND_PARCELS;
    searchBar.delegate = self;
    searchBar.showsCancelButton = YES;
    
    for(UIView *view in searchBar.subviews){
        if([view isKindOfClass:[UITextField class]]){
            UITextField *textField = (UITextField*)view;
            textField.delegate = self;
            break;
        }
    }
    
    [self.view addSubview:searchBar];
    [searchBar release];
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, frame.size.width, frame.size.height-44) style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [tableView release];
    
    //push refresh header init
    if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
	}
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTableView:)];
    tap.cancelsTouchesInView = NO;
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tap];
    [tap release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    Item *user = [MainViewController getInstance].user;
    
    NSString *userId = [user.fields objectForKey:@"id"];
    userId = userId == nil ? @"" : userId;
    userId = [userId isEqualToString:@""] ? [user.fields objectForKey:@"local_id"] : userId;
    
    //auto update status on start
    Item *settingItem = [SettingManager find:@"Setting" column:@"user_email" value:userId];
    if([[settingItem.fields objectForKey:@"updateAtStart"] isEqualToString:@"yes"]){
        [self updateParcelStatus];
    }
    
    int loginCount = [[[MainViewController getInstance].user.fields objectForKey:@"loginCount"] intValue];
    if(loginCount == 1 && [Reachability isNetWorkReachable:NO]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:SYNC_PARCEL message:ASK_FIRST_SYNC delegate:self cancelButtonTitle:MSG_YES otherButtonTitles:MSG_NO,nil];
        [alert show];
        [alert release];
    }
    
}

#pragma Hud progress
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

#pragma UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex==0){
        SynchronizedViewController *sync = [[SynchronizedViewController alloc] initWithType:@"normal"];
        [self.navigationController pushViewController:sync animated:YES];
        [sync startSync];
        [sync release];
    }
    
}

#pragma Keyboard Notification
-(void)keyboardDidShow:(NSNotification *)notification{
    
    CGSize keyboardSize = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGSize size = keyboardSize;
    
    BOOL isPort = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    
    if(!isPort){
        size.width = keyboardSize.height;
        size.height = keyboardSize.width;
    }
    
    CGRect frame = self.tableView.frame;
    frame.size.height -= size.height;
    frame.size.height += 50;
    
    self.tableView.frame = frame;
    
}
-(void)keyboardWillHide:(NSNotification *)notification{

    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGSize size = keyboardSize;
    
    BOOL isPort = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    
    if(!isPort){
        size.width = keyboardSize.height;
        size.height = keyboardSize.width;
    }
    
    CGRect frame = self.tableView.frame;
    frame.size.height += size.height;
    frame.size.height -= 50;
    
    self.tableView.frame = frame;
}

-(void)tapTableView:(UIGestureRecognizer*)tap{
    if([self.searchBar isFirstResponder] && tap.view != self.searchBar){
        [self.searchBar resignFirstResponder];
    }
}

#pragma UpdateListener methods
-(void)didUpdate:(NSString *)fName value:(NSString *)value{
    
}

-(void)mustUpdate:(Item *)item{
    
    [allParcels addObject:item];
    [self.tableView reloadData];
}

- (void) getAllParcelBySorting : (id) sender{
    
    if (allParcels != nil) {
        [allParcels release];
    }
    
    Item* user = [MainViewController getInstance].user ;
    
    NSString *userId = [user.fields objectForKey:@"id"];
    userId = userId==nil ? @"" : userId;
    userId = [userId isEqualToString:@""] ? [user.fields objectForKey:@"local_id"] : userId;
    
    NSMutableDictionary* criteria = [[NSMutableDictionary alloc] init];
    [criteria setValue:[[[ValuesCriteria alloc] initWithString:userId] autorelease] forKey:@"user_email"];
    [criteria setValue:[[[ValuesCriteria alloc] initWithString:@"0"] autorelease] forKey:@"deleted"];
    originalParcels = [[NSMutableArray alloc] init];
    NSArray* list = [NSArray arrayWithArray:[ParcelEntityManager list:@"Parcel" criterias:criteria]];
    
    NSMutableArray *sortedArray = [[NSMutableArray alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MMM-dd"];
    
    for (Item *item in list)
    {
        NSString* str = [item.fields valueForKey:@"shippingDate"];
        NSDate *date = [formatter dateFromString:str];
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:item, @"item", date, @"date", nil];
        [sortedArray addObject:dic];
    }
    
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    [sortedArray sortUsingDescriptors:[NSArray arrayWithObjects:sortDesc, nil]];
    
    
    for (NSDictionary* dic in sortedArray) {
        [originalParcels addObject:[dic valueForKey:@"item"]];
    }
    
    allParcels = [[NSMutableArray alloc] initWithArray:originalParcels];
    [self.tableView reloadData];
    
    [sortedArray release];
    [formatter release];
    [criteria release];
    
}

-(void)previewImage:(UIButton*)button{
    
    UIImage *image = [button imageForState:UIControlStateNormal];
    if (image == nil) return;
    
    NSString *path = NSTemporaryDirectory();
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:path error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.png'"];
    NSArray *onlyPngs = [dirContents filteredArrayUsingPredicate:fltr];
    
    if(onlyPngs.count > 0){
        for(NSString *fileName in onlyPngs){
            
            if([fileName hasPrefix:@"preview"] && [fileName hasSuffix:@".png"]){
                
                NSString *oldPath = [path stringByAppendingPathComponent:fileName];
                [fm removeItemAtPath:oldPath error:nil];
                
                fileName = [fileName substringFromIndex:[fileName rangeOfString:@"preview"].location+7];
                fileName = [fileName substringToIndex:[fileName rangeOfString:@".png"].location];
                int i = [fileName intValue];
                i += 1;
                self.imageFilePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"preview%d.png",i]];
            }
            
        }
    }else{
        self.imageFilePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"preview0.png"]];
    }
    
    [UIImagePNGRepresentation(image) writeToFile:self.imageFilePath atomically:YES]; 
    
    QLPreviewController *preview = [[QLPreviewController alloc] init];
    preview.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    preview.dataSource = self;
    [self presentModalViewController:preview animated:YES];
    [preview release];
    
}

#pragma UITableView Delegate & Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return allParcels.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
-(UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cRTableViewCellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:cRTableViewCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cRTableViewCellIdentifier] autorelease];
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    for(UIView *subview in cell.contentView.subviews){
        [subview removeFromSuperview];
    }
    
    Item *item = [allParcels objectAtIndex:indexPath.row];
    
    NSString *trackingNo = [item.fields objectForKey:@"trackingNo"];
    trackingNo = trackingNo?trackingNo:@"";
    NSString *status = [item.fields objectForKey:@"status"];
    status = status != nil ? status : @"";
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *text = [item.fields objectForKey:@"description"] == nil ? @"" : [item.fields objectForKey:@"description"];
    if(cell.contentView.frame.size.width < self.tableView.frame.size.width){
        CGRect frame = cell.contentView.frame;
        frame.size.width = self.tableView.frame.size.width;
        cell.contentView.frame = frame;
    }
    
    cell.imageView.image = [[[item.fields objectForKey:@"status"] lowercaseString] rangeOfString:@"delivered"].length > 0 ? [UIImage imageNamed:@"checkBox.png"] : [UIImage imageNamed:@""];
    
    CGRect frame = [tableView rectForRowAtIndexPath:indexPath];
    Item *att=[item.attachments objectForKey:@"invoiceImage"];
    NSString *b64img=att==nil?@"":[att.fields objectForKey:@"body"];
    
    UIImage *image = [UIImage imageWithData:[Base64 decode:b64img]];
    UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    imageButton.frame = CGRectMake(frame.size.width-58, 1, 57, frame.size.height-3);
    imageButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    imageButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [imageButton setImage:image forState:UIControlStateNormal];
    [imageButton addTarget:self action:@selector(previewImage:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:imageButton];
    
//    UIButton *showMap = [UIButton buttonWithType:UIButtonTypeCustom];
//    showMap.tag = indexPath.row;
//    showMap.frame = CGRectMake(x, 10, 0, 0);
//    showMap.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//    [showMap setBackgroundImage:[UIImage imageNamed:@"maps_icon.png"] forState:UIControlStateNormal];
//    [showMap sizeToFit];
//    [showMap addTarget:self action:@selector(showMap:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.contentView addSubview:showMap];
    
    float tWidth;
    if (image) tWidth = cell.frame.size.width - 95;
    else tWidth = cell.frame.size.width - 47;
    
    float x_text = 50;
    if (cell.imageView.image == [UIImage imageNamed:@""]) {
        x_text = 20;
    }
    
    UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(x_text, 0, tWidth, 30)];
    description.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    description.text = text;
    description.textColor = [UIColor blackColor];
    description.backgroundColor = [UIColor clearColor];
    description.font = [UIFont boldSystemFontOfSize:16];
    description.textAlignment = UITextAlignmentLeft;
    [cell.contentView addSubview:description];
    [description release];
    
    UILabel *trackingText = [[UILabel alloc] initWithFrame:CGRectMake(x_text, 17, tWidth, 30)];
    trackingText.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    trackingText.backgroundColor = [UIColor clearColor];
    trackingText.text = trackingNo;
    trackingText.font = [UIFont systemFontOfSize:13];
    trackingText.textColor = [UIColor grayColor];
    [cell.contentView addSubview:trackingText];
    [trackingText release];
    
    UILabel *statusText = [[UILabel alloc] initWithFrame:CGRectMake(x_text, 32, tWidth, 30)];
    statusText.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    statusText.backgroundColor = [UIColor clearColor];
    
    if (![status isEqualToString:@"No data available"]){
        statusText.text = [NSString stringWithFormat:@"%@ (%@)",status,[item.fields valueForKey:@"forwarder"]];
    }else {
        statusText.text = status;
    }
    
    statusText.font = [UIFont systemFontOfSize:13];
    statusText.textColor = [UIColor grayColor];
    [cell.contentView addSubview:statusText];
    [statusText release];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Item*item = [allParcels objectAtIndex:indexPath.row];
    [item.fields setValue:@"2" forKey:@"deleted"];
    [ParcelEntityManager update:item modifiedLocally:NO];
    [allParcels removeObject:item];
    
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
    }
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    if ([allParcels count] == 0) [self performSelector:@selector(enableAfterEdit:)];
    
}

-(void)deleteRecordFromServer{
    
    _hud.labelText = DELETE_RECORD;
    
    Item* user = [MainViewController getInstance].user ;
    
    NSString *userId = [user.fields objectForKey:@"id"];
    userId = userId==nil ? @"" : userId;
    userId = [userId isEqualToString:@""] ? [user.fields objectForKey:@"local_id"] : userId;
    
    NSDictionary* criteria = [NSDictionary dictionaryWithObjectsAndKeys:[[[ValuesCriteria alloc] initWithString:@"2"] autorelease],@"deleted",[[[ValuesCriteria alloc] initWithString:userId] autorelease],@"user_email", nil];
    NSMutableArray* listItems  = [[NSMutableArray alloc] initWithArray:[ParcelEntityManager list:@"Parcel" criterias:criteria]];
    
    if ([listItems count] > 0) {
        for(Item *item in listItems){
            if (![[item.fields valueForKey:@"id"] isEqualToString:@""] && [item.fields valueForKey:@"id"] != nil) {
                SalesforceAPIRequest *request = [[DeleteRecordRequest alloc] initWithItem:item];
                [request doRequest:self];
                [request release];
            }
        }
    }
    
}

#pragma Sync listener

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

    NSMutableDictionary *fields = [NSMutableDictionary dictionaryWithDictionary:user.fields];

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
                [self deleteRecordFromServer];
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
            
            [self deleteRecordFromServer];
            
        }
        
    }else if([request isKindOfClass:[DeleteRecordRequest class]]){
        
        [request.item.fields setObject:@"1" forKey:@"deleted"];
        [ParcelEntityManager update:request.item modifiedLocally:NO];
        
        //if request delete parcel completed set deleted status to childs attachment
        for (Item *it in request.item.attachments.allValues) {
            [it.fields setObject:@"1" forKey:@"deleted"];
            [AttachmentEntitymanager update:it modifiedLocally:NO];
        }
        
        [self hideHud:UPDATING_STATUS];
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

//end deleting record

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSelector:@selector(disableWhenEdit:)];
    
}

- (void) tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSelector:@selector(enableAfterEdit:)];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void) editParcel : (id)sender{
    
    [self performSelector:@selector(disableWhenEdit:)];
    [self.tableView setEditing:YES animated:YES];
}

- (void) doneEdit : (id) sender {
    [self performSelector:@selector(enableAfterEdit:)];
    [self.tableView setEditing:NO animated:YES];
}

- (void) enableAfterEdit : (id) sender {
    
    [searchBar setUserInteractionEnabled:YES];
    searchBar.alpha = 1.0;
    self.navigationItem.leftBarButtonItem = nil;
    [self performSelector:@selector(addUIBarButtonItems:)];
}

- (void) disableWhenEdit : (id) sender {
    
    [searchBar setUserInteractionEnabled:NO];
    searchBar.alpha = 0.75;
    
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.rightBarButtonItems = nil;
    
    self.navigationItem.leftBarButtonItem = [[CustomUIBarButtonItem alloc] initWithText:@"Done" target:self action:@selector(doneEdit:)];
}

- (void) addUIBarButtonItems : (id) sender {

    self.navigationItem.leftBarButtonItem = [[CustomUIBarButtonItem alloc] initWithText:@"Edit" target:self action:@selector(editParcel:)];
    self.navigationItem.rightBarButtonItem = [[CustomUIBarButtonItem alloc] initWithText:@"New" target:self action:@selector(addParcel)];

}

- (void) updateParcelStatus {
   
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        _hud.labelText = UPDATING_STATUS;
        [self.view addSubview:_hud];
    }
    
    RequestUpdate* req = [[RequestUpdate alloc] initWithEntity:@"Parcel__c" parentClass:self];
    [req checkSaleForceLogin];
    [self showHud:nil];
    
}

-(void)finishUpdating {
    [self performSelector:@selector(getAllParcelBySorting:)];
    [self doneLoadingTableViewData];
    [self hideHud:nil];
}

-(void)showMap:(UIButton*)button{
    
    ShowMapViewController *showMap = [[ShowMapViewController alloc] initWithItem:[allParcels objectAtIndex:button.tag]];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:showMap];
    [showMap release];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:nav animated:YES];
    [nav release];
    
    CGRect frame = showMap.view.superview.frame;
    [showMap initDetail:frame];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Item *item = [allParcels objectAtIndex:indexPath.row];
    MyParcelDetailViewController *detail = [[MyParcelDetailViewController alloc] initWithItem:item];
    detail.updateListener = self;
    [self.navigationController pushViewController:detail animated:YES];
    [detail release];
}

#pragma UISearchBar delegate

-(void)searchBar:(UISearchBar *)sb textDidChange:(NSString *)searchText{
    [self refresh];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)sb{
    sb.text = @"";
    [sb resignFirstResponder];
    [self refresh];
}

-(BOOL)textFieldShouldClear:(UITextField *)textField{
    [self refresh];
    return YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

//The TimeScroller needs to know what's happening with the UITableView (UIScrollView)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    //if user pull refresh reload feed data from offset 0
    [self updateParcelStatus];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return [NSDate date]; // should return date data source was last changed
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    BasicPreviewItem *previewItem = [[BasicPreviewItem alloc] init];
    previewItem.previewItemTitle = @"Preview Image";
    previewItem.previewItemURL = [NSURL fileURLWithPath:self.imageFilePath];
    
    return previewItem;
}

@end
