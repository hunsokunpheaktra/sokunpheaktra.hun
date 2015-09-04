//
//  LoginViewController.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 10/30/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "UserManager.h"
#import "ValuesCriteria.h"
#import "LoginRequest.h"
#import "MyParcelDetailViewController.h"
#import "ParcelEntityManager.h"
#import "NewParcelViewController.h"
#import "QueryRequest.h"
#import "UserManager.h"
#import "CallSFMethodRequest.h"
#import "PropertyManager.h"
#import "DatetimeHelper.h"
#import "RequestUpdate.h"
#import "CustomTextField.h"

@implementation LoginViewController

@synthesize hud,googleAuth,currentUser;

-(id)init{
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    [[SyncProcess getInstance] startNotifier];
    currentUser = [[Item alloc] init:@"User" fields:[NSDictionary dictionary]];
    return self;
}

-(void)dealloc{
    [super dealloc];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
    if([Reachability isNetWorkReachable:YES]){
        loginFrom = @"query";
        
        NSString *sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
        if(!sessionId){
            LoginRequest *login = [[LoginRequest alloc] init];
            [login doRequest:self];
            [login release];
        }else{
            NSString *lastSync = [PropertyManager read:@"LastSyncUser"];
            NSString *sql = @"select id,First_Name__c,Last_Name__c,Email__c,Password__c from Parcel_User__c";
            if(![lastSync isEqualToString:@""]){
                sql = [NSString stringWithFormat:@"select id,First_Name__c,Last_Name__c,Email__c,Password__c from Parcel_User__c where CreatedDate > %@",lastSync];
            }
            QueryRequest *query = [[QueryRequest alloc] initWithSQL:sql sobject:@"Parcel_User__c"];
            [query doRequest:self];
            [query release];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.showsVerticalScrollIndicator = NO;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTableView:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:tap];
    [tap release];
    
    CGRect frame = self.tableView.frame;
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 240)] autorelease];
    headerView.backgroundColor = [UIColor clearColor];
    
    UIView *header = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 19)] autorelease];
    header.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    header.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login-header.png"]];
    [headerView addSubview:header];
    
    UIImage *image = [UIImage imageNamed:@"logo.png"];
    float x = (frame.size.width/2) - (image.size.width/2);
    
    UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(x, 80, image.size.width, image.size.height)];
    logo.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    logo.image = image;
    [headerView addSubview:logo];
    [logo release];
    
    self.tableView.tableHeaderView = headerView;
    
    UIView *footerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 100)] autorelease];
    footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.frame = CGRectMake(0, 50, frame.size.width, 66);
    loginButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [loginButton setBackgroundImage:[UIImage imageNamed:@"login-footer.png"] forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(localUserLogin) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:loginButton];
    
    self.tableView.tableFooterView = footerView;
    
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 40)];
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    image = [UIImage imageNamed:@"google-icon.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(googleLogin) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barGoogle = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    image = [UIImage imageNamed:@"facebook-icon.png"];
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(facebookLogin) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barFacebook = [[UIBarButtonItem alloc] initWithCustomView:button];

    UIBarButtonItem *barForgotPass = [[UIBarButtonItem alloc] initWithTitle:@"Forgot Password ?" style:UIBarButtonItemStyleBordered target:self action:@selector(forgotPassword)];
    
    UIBarButtonItem *barRegister = [[UIBarButtonItem alloc] initWithTitle:@"Register" style:UIBarButtonItemStyleBordered target:self action:@selector(signUp:)];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *barSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    barSpace.width = 5;
    
    _toolbar.items = [NSArray arrayWithObjects:barForgotPass,barRegister,space,barGoogle,barSpace,barFacebook, nil];
    
    /*UIView *footerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-240)] autorelease];
    footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIButton *login = [UIButton buttonWithType:UIButtonTypeCustom];
    login.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    if (!isiPhone) {
        login.frame = CGRectMake(130, 10, (frame.size.width-30)/3, 42);
    }else{
        login.frame = CGRectMake(10, 10, (frame.size.width-30)/2, 42);
    }
    [login setBackgroundImage:[[UIImage imageNamed:@"green-bg.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:20] forState:UIControlStateNormal];
    [login setTitle:LOGIN forState:UIControlStateNormal];
    [login setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    login.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    login.titleLabel.shadowColor = [UIColor lightGrayColor];
    login.titleLabel.shadowOffset = CGSizeMake(0, -1);
    [login addTarget:self action:@selector(localUserLogin) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:login];
    
    UIButton *signUp = [UIButton buttonWithType:UIButtonTypeCustom];
    signUp.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    if (!isiPhone) {
        signUp.frame = CGRectMake(150 + (frame.size.width-30)/3, 10, (frame.size.width-30)/3, 42);
    }else{
        signUp.frame = CGRectMake(20 + (frame.size.width-30)/2, 10, (frame.size.width-30)/2, 42);
    }
    [signUp setBackgroundImage:[[UIImage imageNamed:@"green-bg.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:20] forState:UIControlStateNormal];
    [signUp setTitle:SIGNUP forState:UIControlStateNormal];
    [signUp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    signUp.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    signUp.titleLabel.shadowColor = [UIColor lightGrayColor];
    signUp.titleLabel.shadowOffset = CGSizeMake(0, -1);
    [signUp addTarget:self action:@selector(signUp:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:signUp];
    
    UIButton *fbLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    fbLogin.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    if (!isiPhone) {
        fbLogin.frame = CGRectMake(225, 65, 0, 0);
    }else{
        fbLogin.frame = CGRectMake(10, 65, 0, 0);
    }
    [fbLogin setImage:[UIImage imageNamed:@"facebook_connection.png"] forState:UIControlStateNormal];
    [fbLogin addTarget:self action:@selector(facebookLogin) forControlEvents:UIControlEventTouchUpInside];
    [fbLogin sizeToFit];
    [footerView addSubview:fbLogin];
    
    UIButton *googleLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    googleLogin.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    if (!isiPhone) {
        googleLogin.frame = CGRectMake(420, 65, 0, 0);
    }else{
        googleLogin.frame = CGRectMake(185, 65, 0, 0);
    }
    
    [googleLogin setImage:[UIImage imageNamed:@"google_connection.png"] forState:UIControlStateNormal];
    [googleLogin addTarget:self action:@selector(googleLogin) forControlEvents:UIControlEventTouchUpInside];
    [googleLogin sizeToFit];
    [footerView addSubview:googleLogin];
    
    UIButton *forgetPass = [UIButton buttonWithType:UIButtonTypeCustom];
    forgetPass.frame = isiPhone ? CGRectMake(0, 110, 150, 40) : CGRectMake(130, 130, (frame.size.width-30)/3, 40);
    forgetPass.titleLabel.font = [UIFont systemFontOfSize:14];
    [forgetPass setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [forgetPass setTitle:[NSString stringWithFormat:@"%@ ?",FORGOT_PASSWORD] forState:UIControlStateNormal];
    [forgetPass addTarget:self action:@selector(forgotPassword) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:forgetPass];
    
    UILabel *powerBy = [[UILabel alloc]initWithFrame:CGRectMake(0, 160, frame.size.width, 50)];
    powerBy.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    powerBy.textAlignment = UITextAlignmentCenter;
    powerBy.backgroundColor = [UIColor clearColor];
    powerBy.numberOfLines = 2;
    [powerBy setTextColor:[UIColor colorWithRed:0.1 green:0.3 blue:0.9 alpha:1]];
    [powerBy setFont:[UIFont systemFontOfSize:12]];
    powerBy.shadowColor = [UIColor lightGrayColor];
    powerBy.shadowOffset = CGSizeMake(0, -1);
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSYearCalendarUnit fromDate:[NSDate date]];
    NSInteger year = [components year];
    powerBy.text = [NSString stringWithFormat:@"Copyright ©%d • Powered by: Pactrac2me Version %@",year,version];
    [footerView addSubview:powerBy];
    [powerBy release];
    
    self.tableView.tableFooterView = footerView;
    */
    
    UIView *background = [[[UIView alloc] initWithFrame:frame] autorelease];
    background.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundView = background;
    
    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation-bg.png"] forBarMetrics:UIBarMetricsDefault];
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    self.hud.labelText = LOADING;
    [self.view addSubview:hud];
    [hud release];
    
    Item *lastUser = [UserManager find:@"User" column:@"lastLogin" value:@"1"];
    if (lastUser) {
        [self.view setHidden:YES];
        
        int loginCount = [[lastUser.fields objectForKey:@"loginCount"] intValue];
        [lastUser.fields setObject:[NSString stringWithFormat:@"%d",loginCount+1] forKey:@"loginCount"];
        [UserManager update:lastUser];
        
        MainViewController *main = [MainViewController getInstance];
        main.user = lastUser;
        [self presentModalViewController:main animated:NO];
        self.navigationController.navigationBar.hidden = YES;
        
        [appdelegate openURLPage];
        
    }
    
}

-(void)tapTableView:(UIGestureRecognizer*)tap{
    
    if(![tap.view isKindOfClass:[UITextField class]]){
        [self.view endEditing:YES];
    }
    
}

- (void) forgotPassword{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:RETREIVE_PASSWORD message:ENTER_EMAIL delegate:self cancelButtonTitle:MSG_OK otherButtonTitles:MSG_CANCEL,nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeEmailAddress;
    [alert show];
    [alert release];
    
}

#pragma mark-
#pragma UIAlertView delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    self.userEmail = [alertView textFieldAtIndex:0].text;
    
    if(buttonIndex == 0){
        
        if([Reachability isNetWorkReachable:YES] && ![self.userEmail isEqualToString:@""]){
            loginFrom = @"forgetPassword";
            LoginRequest *login = [[LoginRequest alloc] init];
            [login doRequest:self];
            [login release];
        }
    }
    
}

- (void)signUp:(id)sender {
    
    Item* newUser = [[Item alloc] init:@"User" fields:[NSDictionary dictionary]];
    RegisterViewController *registerController = [[RegisterViewController alloc] initWithUserInfo:newUser parent:self];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:registerController];
    [self presentModalViewController:nav animated:YES];
    self.navigationController.navigationBar.hidden = YES;
    [nav release];
}

-(void)loginToApp:(Item*)loginUser isLocal:(BOOL)isLocal{
    
    [self.view endEditing:YES];
    
    NSString *email = [loginUser.fields objectForKey:@"email"];
    NSString *newPass = [loginUser.fields objectForKey:@"password"]==nil?@"":[loginUser.fields objectForKey:@"password"];
    
    Item *existUser = [UserManager find:@"User" column:@"email" value:email];
    NSString *oldPass = [existUser.fields objectForKey:@"password"]==nil ?@"":[existUser.fields objectForKey:@"password"];
    BOOL validatePassword = [oldPass isEqualToString:newPass];
    
    //login fail
    if(!existUser){
        //local login wrong user
        if(isLocal){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LOGIN_FAIL message:INVALID_USER_OR_PASSWORD delegate:nil cancelButtonTitle:MSG_OK otherButtonTitles:nil];
            [alert show];
            [alert release];
            //google or facebook login invalid open register screen
        }else{
            RegisterViewController *registerController = [[RegisterViewController alloc] initWithUserInfo:loginUser parent:self];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:registerController];
            [self presentModalViewController:nav animated:YES];
            [nav release];
        }
        //log in success
    }else{
        //local login wrong password
        if(isLocal && !validatePassword){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LOGIN_FAIL message:INVALID_USER_OR_PASSWORD delegate:nil cancelButtonTitle:MSG_OK otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }
        
        //update number of login current user
        int loginCount = [[existUser.fields objectForKey:@"loginCount"] intValue];
        [existUser.fields setObject:[NSString stringWithFormat:@"%d",loginCount+1] forKey:@"loginCount"];
        [UserManager update:existUser];
        
        MainViewController *main = [MainViewController getInstance];
        main.user = existUser;
        
        main.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:main animated:YES];
        self.navigationController.navigationBar.hidden = YES;
        
        [appdelegate openURLPage];
    }
    
    [self.hud hide:YES];
    
}

-(void)logout{
    
    [self.view endEditing:YES];
    
    //sign out facebook
    [appdelegate.facebook logout];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    //sign out google
    NSString *keychainItemName = @"OAuth Sample: Google Contacts";
    //if authentication saved sign out
    GTMOAuth2Authentication *mAuth= [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:keychainItemName clientID:Google_clientId clientSecret:Google_clientSecret];
    
    if (mAuth.canAuthorize) {
        [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:mAuth];
        // remove the stored Google authentication from the keychain, if any
        [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:keychainItemName];
    }
    
}

#pragma local user login
-(void)localUserLogin{
    [self loginToApp:currentUser isLocal:YES];
}

#pragma facebook api login
-(void)facebookLogin{
    
    if([Reachability isNetWorkReachable:YES]){
        
        if(!appdelegate.facebook){
            appdelegate.facebook = [[Facebook alloc] initWithAppId:FB_appId andDelegate:self];
        }
        
        if(!appdelegate.facebook.isSessionValid){
            [appdelegate.facebook authorize:[NSArray arrayWithObjects:@"read_stream", @"publish_stream",@"email", nil]];
        }else{
            
            self.hud.labelText = CHECKING_USER;
            [self.hud show:YES];
            [appdelegate.facebook requestWithGraphPath:@"me?fields=email,first_name,last_name,username" andDelegate:self];
        }
    }
    
}

#pragma google api login
-(void)googleLogin{
    
    if(![Reachability isNetWorkReachable:YES]) return;
    
    self.hud.labelText = CHECKING_USER;
    [self.hud show:YES];
    
    NSString *scope = @"https://www.googleapis.com/auth/userinfo.profile";
    NSString *keychainItemName = @"OAuth Sample: Google Contacts";
    
    googleAuth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:keychainItemName clientID:Google_clientId clientSecret:Google_clientSecret];
    
    if (googleAuth.canAuthorize) {
        
        NSString *urlStr = @"https://www.googleapis.com/oauth2/v1/userinfo?alt=json";
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [googleAuth authorizeRequest:request completionHandler:^(NSError *error) {
            NSString *output = nil;
            if (error) {
                output = [error description];
            } else {
                NSURLResponse *response = nil;
                NSData *data = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
                if (data) {
                    // API fetch succeeded
                    output = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
                    
                    SBJSON *parser = [[SBJSON alloc] init];
                    // parse the JSON string into an object - assuming json_string is a NSString of JSON data
                    
                    NSDictionary *results = [parser objectWithString:output error:nil];
                    [parser release];
                    if (results != nil) {
                        
                        Item *userLocal = [[Item alloc] init:@"User" fields:[NSDictionary dictionary]];
                        [userLocal.fields setObject:[results objectForKey:@"family_name"] forKey:@"first_name"];
                        [userLocal.fields setObject:[results objectForKey:@"given_name"] forKey:@"last_name"];
                        [userLocal.fields setObject:[results objectForKey:@"email"] forKey:@"email"];
                        
                        [self loginToApp:userLocal isLocal:NO];
                        
                    }
                    
                } else {
                    // fetch failed
                    output = [error description];
                }
            }
        }];
        
    }else{
        
        SEL finishedSel = @selector(viewController:finishedWithAuth:error:);
        
        GTMOAuth2ViewControllerTouch *viewController = [GTMOAuth2ViewControllerTouch controllerWithScope:scope clientID:Google_clientId clientSecret:Google_clientSecret keychainItemName:keychainItemName delegate:self finishedSelector:finishedSel];
        viewController.title = GOOGLE_LOGIN;
        NSDictionary *params = [NSDictionary dictionaryWithObject:@"en" forKey:@"hl"];
        viewController.signIn.additionalAuthorizationParameters = params;
        NSString *html = @"<html><body bgcolor=silver><div align=center>Loading sign-in page...</div></body></html>";
        viewController.initialHTMLString = html;
        viewController.signIn.shouldFetchGoogleUserProfile = YES;
        
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
}

#pragma Register new user
-(void)registerScreen:(Item*)newUser{
    
    [self.hud hide:YES];
    
    RegisterViewController *registerController = [[RegisterViewController alloc] initWithUserInfo:newUser parent:self];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:registerController];
    [self presentModalViewController:nav animated:YES];
    [nav release];
}

-(void)login2Mainscreen:(Item*)user{
    
    [self.hud hide:YES];
    
    MainViewController *main = [MainViewController getInstance];
    main.user = user;
    main.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:main animated:YES];
    self.navigationController.navigationBar.hidden = YES;
    
    [appdelegate openURLPage];
}

-(void)registerUser:(id)sender{
    
    RequestUpdate* req = [[RequestUpdate alloc] initWithEntity:@"Parcel_User__c" parentClass:self];
    [req registerUser];
    [req release];
}

#pragma SyncListener Method
-(void)onSuccess:(id)req{
    
    SalesforceAPIRequest *request = req;
    if([req isKindOfClass:[LoginRequest class]]){
        
        if([loginFrom isEqualToString:@"forgetPassword"]){
            
            CallSFMethodRequest *request = [[CallSFMethodRequest alloc] initWithUrlMapping:@"UserForgetPasswordChecking" userEmail:self.userEmail];
            [request doRequest:self];
            [request release];
        }else{
            NSString *lastSync = [PropertyManager read:@"LastSyncUser"];
            NSString *sql = @"select id,First_Name__c,Last_Name__c,Email__c,Password__c from Parcel_User__c";
            if(![lastSync isEqualToString:@""]){
                sql = [NSString stringWithFormat:@"select id,First_Name__c,Last_Name__c,Email__c,Password__c from Parcel_User__c where CreatedDate > %@",lastSync];
            }
            QueryRequest *query = [[QueryRequest alloc] initWithSQL:sql sobject:@"Parcel_User__c"];
            [query doRequest:self];
            [query release];
        }
        
        
    }else if([request isKindOfClass:[QueryRequest class]]){
        
        if(request.records.count > 0){
            
            for(NSDictionary *record in request.records){
                
                NSMutableDictionary *fields = [NSMutableDictionary dictionary];
                [fields setObject:[record objectForKey:@"Id"] forKey:@"id"];
                [fields setObject:[record objectForKey:@"First_Name__c"] forKey:@"first_name"];
                [fields setObject:[record objectForKey:@"Last_Name__c"] forKey:@"last_name"];
                [fields setObject:@"0" forKey:@"modified"];
                [fields setObject:[record objectForKey:@"Email__c"] forKey:@"email"];
                [fields setObject:[record objectForKey:@"Password__c"] forKey:@"password"];
                [fields setObject:@"0" forKey:@"loginCount"];
                [fields setObject:@"0" forKey:@"lastLogin"];
                
                Item *user = [[Item alloc] init:@"User" fields:fields];
                [UserManager insert:user];
                
            }
            NSString *dateString = [DatetimeHelper serverDateTime:[NSDate date]];
            [PropertyManager save:@"LastSyncUser" value:dateString];
        }
        [self.hud hide:YES];
        
    }else if([request isKindOfClass:[CallSFMethodRequest class]]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:FORGOT_PASSWORD message:PASSWORD_SENT delegate:nil cancelButtonTitle:MSG_OK otherButtonTitles:nil];
        [alert show];
        [alert release];
        
    }
    
}
-(void)onFailure:(NSString *)errorMessage request:(id)req{
    
    if([errorMessage isEqualToString:@"INVALID_SESSION_ID"]){
        
        LoginRequest *login = [[LoginRequest alloc] init];
        [login doRequest:self];
        [login release];
        
    }else if ([errorMessage rangeOfString:@"INVALID_PASSWORD"].location != NSNotFound) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:CONNECT_ERROR message:INVALID_PASSWORD_MESSAGE delegate:nil cancelButtonTitle:MSG_OK otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    
}

#pragma UITabelView Delegate & Datasource method
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        UIView *background = [[[UIView alloc] initWithFrame:cell.frame] autorelease];
        background.backgroundColor = [UIColor clearColor];
        cell.backgroundView = background;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    for(UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    
    CGRect frame = [tableView rectForRowAtIndexPath:indexPath];
    
    if(indexPath.row == 0){
        
        CustomTextField *user = [[CustomTextField alloc] initWithFrame:CGRectMake(25, 5, frame.size.width-70, 40)];
        user.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"textfield-bg.png"]];
        user.autocorrectionType = UITextAutocorrectionTypeNo;
        user.delegate = self;
        user.textColor = [UIColor whiteColor];
        user.textAlignment = UITextAlignmentCenter;
        user.tag = indexPath.row;
        user.placeholder = @"Your E-Mail";
        user.autocorrectionType = UITextAutocorrectionTypeNo;
        user.keyboardType = UIKeyboardTypeEmailAddress;
        user.autocapitalizationType=UITextAutocapitalizationTypeNone;
        user.text = [currentUser.fields objectForKey:@"email"];
        user.returnKeyType = UIReturnKeyNext;
        user.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        if(user.inputAccessoryView == nil) user.inputAccessoryView = _toolbar;
        [user.layer setValue:@"email" forKey:@"fieldName"];
        [cell.contentView addSubview:user];
        [user becomeFirstResponder];
        [user release];
        
    }else{
        
        CustomTextField *password = [[CustomTextField alloc] initWithFrame:CGRectMake(25, 5, frame.size.width-70, 40)];
        password.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"textfield-bg.png"]];
        password.delegate = self;
        password.textColor = [UIColor whiteColor];
        password.secureTextEntry = YES;
        password.textAlignment = UITextAlignmentCenter;
        password.tag = indexPath.row;
        password.autocapitalizationType=UITextAutocapitalizationTypeNone;
        password.text = [currentUser.fields objectForKey:@"password"];
        password.returnKeyType = UIReturnKeyGo;
        password.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        password.placeholder = PASSWORD;
        if(password.inputAccessoryView == nil) password.inputAccessoryView = _toolbar;
        [password.layer setValue:@"password" forKey:@"fieldName"];
        [cell.contentView addSubview:password];
        [password release];
        
    }
    
    return cell;
    
}

#pragma UITextField delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField.returnKeyType == UIReturnKeyGo){
        [self localUserLogin];
        [textField resignFirstResponder];
    }else{
        [[self.view viewWithTag:1] becomeFirstResponder];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    return YES;
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    NSString *value = textField.text == nil ? @"" : textField.text;
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *fieldName = [textField.layer valueForKey:@"fieldName"];
    [currentUser.fields setObject:value forKey:fieldName];
    
}

#pragma Rotation Method
- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma GoogleAuthentication delegate
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)auth  error:(NSError *)error {
    
    if (error != nil) {
        
        NSData *responseData = [error.userInfo objectForKey:@"data"];
        if ([responseData length] > 0) {
            // show the body of the server's authentication failure response
            NSString *str = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
            NSLog(@"%@", str);
        }
        googleAuth = nil;
        
        NSDictionary *errorInfo = error.userInfo;
        if(errorInfo == nil || errorInfo.count == 0){
            errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:REQUEST_CANCEL,@"error", nil];
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.hud hide:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:RETRIEVE_FAIL message:[errorInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:MSG_OK otherButtonTitles:nil];
        [alert show];
        [alert release];
        
    }else{
        
        googleAuth = auth;
        
        NSString *urlStr = @"https://www.googleapis.com/oauth2/v1/userinfo?alt=json";
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [googleAuth authorizeRequest:request completionHandler:^(NSError *error) {
            NSString *output = nil;
            if (error) {
                output = [error description];
            } else {
                NSURLResponse *response = nil;
                NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                if (data) {
                    
                    // API fetch succeeded
                    output = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
                    SBJSON *parser = [[SBJSON alloc] init];
                    
                    // parse the JSON string into an object - assuming json_string is a NSString of JSON data
                    NSDictionary *results = [parser objectWithString:output error:nil];
                    [parser release];
                    if (results != nil) {
                        
                        Item *userLocal = [[Item alloc] init:@"User" fields:[NSDictionary dictionary]];
                        [userLocal.fields setObject:[results objectForKey:@"family_name"] forKey:@"first_name"];
                        [userLocal.fields setObject:[results objectForKey:@"given_name"] forKey:@"last_name"];
                        [userLocal.fields setObject:[results objectForKey:@"email"] forKey:@"email"];
                        
                        [self loginToApp:userLocal isLocal:NO];
                        
                    }
                    
                } else {
                    // fetch failed
                    output = [error description];
                }
            }
        }];
        
    }
}

- (void)incrementNetworkActivity:(NSNotification *)notify {
    ++mNetworkActivityCounter;
    if (mNetworkActivityCounter == 1) {
        UIApplication *app = [UIApplication sharedApplication];
        [app setNetworkActivityIndicatorVisible:YES];
    }
}

- (void)decrementNetworkActivity:(NSNotification *)notify {
    --mNetworkActivityCounter;
    if (mNetworkActivityCounter == 0) {
        UIApplication *app = [UIApplication sharedApplication];
        [app setNetworkActivityIndicatorVisible:NO];
    }
}

- (void)signInNetworkLostOrFound:(NSNotification *)notify {
    if ([[notify name] isEqual:kGTMOAuth2NetworkLost]) {
        
    } else {
        
    }
}

- (void)displayAlertWithMessage:(NSString *)message {
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"OAuth2Sample"
                                                     message:message
                                                    delegate:nil
                                           cancelButtonTitle:MSG_OK
                                           otherButtonTitles:nil] autorelease];
    [alert show];
    [alert release];
}

#pragma mark - FacebookSession delegate
- (void)storeAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

/**
 * Called when the user has logged in successfully.
 */
-(void)fbDidLogin{
    
    self.hud.labelText = CHECKING_USER;
    [self.hud show:YES];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:appdelegate.facebook.accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:appdelegate.facebook.expirationDate forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    [appdelegate.facebook requestWithGraphPath:@"me?fields=email,first_name,last_name,username" andDelegate:self];
    
}
-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    [self storeAuthData:accessToken expiresAt:expiresAt];
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
    
    NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:REQUEST_CANCEL,ERROR, nil];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:RETRIEVE_FAIL message:[errorInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:MSG_OK otherButtonTitles:nil];
    [alert show];
    [alert release];
    
}

/**
 * Called when the request logout has succeeded.
 */

- (void)fbDidLogout {
    
}

/**
 * Called when the session has expired.
 */
- (void)fbSessionInvalidated {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Auth Exception"
                              message:SESSION_EXPIRED
                              delegate:nil
                              cancelButtonTitle:MSG_OK
                              otherButtonTitles:nil,
                              nil];
    [alertView show];
    [alertView release];
    [self fbDidLogout];
}

#pragma mark - FBRequestDelegate Methods
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {}
- (void)request:(FBRequest *)request didLoad:(id)result {
    
    if ([result isKindOfClass:[NSArray class]]) {
        result = [result objectAtIndex:0];
    }
    
    Item *userLocal = [[Item alloc] init:@"User" fields:[NSDictionary dictionary]];
    [userLocal.fields setValue:[result objectForKey:@"email"] forKey:@"email"];
    [userLocal.fields setObject:[result objectForKey:@"first_name"] forKey:@"first_name"];
    [userLocal.fields setObject:[result objectForKey:@"last_name"] forKey:@"last_name"];
    
    [self loginToApp:userLocal isLocal:NO];
    self.navigationController.navigationBar.hidden = YES;
    
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    
    [self.hud hide:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Fail" message:[error.userInfo objectForKey:@"error_msg"] delegate:nil cancelButtonTitle:MSG_OK otherButtonTitles:nil];
    [alert show];
    [alert release];
    
}

@end


