//
//  RegisterViewController.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 11/7/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "RegisterViewController.h"

#import "NSObject+SBJson.h"
#import "Item.h"
#import "UserManager.h"
#import "MainViewController.h"
#import "LoginViewController.h"
#import "ValuesCriteria.h"
#import "AppDelegate.h"
#import "Reachability.h"

@implementation RegisterViewController

@synthesize hud;
@synthesize parentClass;

-(id)initWithUserInfo:(Item*)newUser parent:(id)parent{
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    self.title = REGISTER;
       
    currentUser = newUser;
    self.parentClass = parent;
    
    self.navigationItem.leftBarButtonItem = [[CustomUIBarButtonItem alloc] initWithText:@"Cancel" target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[CustomUIBarButtonItem alloc] initWithText:MSG_CREATE target:self action:@selector(createUser)];
    
    return self;
}

-(void)dealloc{
    [super dealloc];
    [currentUser release];
    [hud release];
}

-(void)cancel{
    
    LoginViewController *login = (LoginViewController*)((UINavigationController*)self.presentingViewController).topViewController;
    [login logout];
    
    if ([parentClass isKindOfClass:[LoginViewController class]]) {
        [[(LoginViewController*)parentClass hud] hide:YES];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.autoresizesSubviews = YES;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIView *background = [[[UIView alloc] initWithFrame:self.tableView.frame] autorelease];
    background.backgroundColor = [UIColor colorWithRed:(213./255.) green:(182./255.) blue:(145./255.) alpha:1];
    self.tableView.backgroundView = background;

    
}


-(void)createUser{
    
    [self.view endEditing:YES];
    
    NSString *email = [currentUser.fields objectForKey:@"email"] == nil ? @"" : [currentUser.fields objectForKey:@"email"];
    NSString *password = [currentUser.fields objectForKey:@"password"] == nil ? @"" : [currentUser.fields objectForKey:@"password"];
    NSString *retype = [currentUser.fields objectForKey:@"retypePass"] == nil ? @"" : [currentUser.fields objectForKey:@"retypePass"];
    
    if(![self isValidEmail:email]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:INVALID_EMAIL message:ERROR_EMAIL delegate:self cancelButtonTitle:MSG_OK otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
        
    }
    
    if(![password isEqualToString:retype]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:INVALID_PASSWORD message:ERROR_PASSWORD_AND_REPEAT delegate:self cancelButtonTitle:MSG_OK otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    NSMutableDictionary* criteria = [NSMutableDictionary dictionary];
    [criteria setValue:[[[ValuesCriteria alloc] initWithString:[currentUser.fields objectForKey:@"email"]] autorelease] forKey:@"email"];
    NSArray* listFound = [UserManager find:criteria];
    
    if([listFound count] > 0){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:DUPLICATED_MAIL message:MESSAGE_DUPLICATED_MAIL delegate:self cancelButtonTitle:MSG_OK otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
        
    }
    
    [currentUser.fields removeObjectForKey:@"retypePass"];
    
    //update number of login current user
    [currentUser.fields setObject:@"2" forKey:@"loginCount"];
    
    MainViewController *main = [MainViewController getInstance];
    main.user = currentUser;
    main.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    UINavigationController *parent = (UINavigationController*)self.presentingViewController;
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        if([Reachability isNetWorkReachable:NO]){
            [(LoginViewController*)parentClass performSelector:@selector(registerUser:)];
            parent.navigationBar.hidden = YES;
        }else{
            [currentUser.fields setObject:@"midified" forKey:@"2"];
            [UserManager insert:currentUser];
        }
        
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(BOOL)isValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

#pragma mark -
#pragma mark Text Field Delegate

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    NSString *fieldName = [textField.layer valueForKey:@"fieldName"];
    NSString *text = textField.text ? textField.text : @"";
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [currentUser.fields setObject:text forKey:fieldName];
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [self.view viewWithTag:nextTag];
    if ([nextResponder isKindOfClass:[UITextField class]]) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:nextTag] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    } else{
        [textField resignFirstResponder];
        nextResponder = [self.view viewWithTag:nextTag+1];
        [nextResponder becomeFirstResponder];
        // Not found, so remove keyboard
        
    }
    return NO;
}

#pragma mark -
#pragma mark BSKeyboardControls Delegate

/* Scroll the view to the active text field */
- (void)scrollViewToTextField:(id)textField
{
    int tag = [textField tag];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:tag] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)controls
{
    [controls.activeTextField resignFirstResponder];
    
    UITextField *textField = controls.activeTextField;
    NSString *fieldName = [textField.layer valueForKey:@"fieldName"];
    NSString *text = textField.text ? textField.text : @"";
    [currentUser.fields setObject:text forKey:fieldName];
    
}

- (void)keyboardControlsPreviousNextPressed:(BSKeyboardControls *)controls withDirection:(KeyboardControlsDirection)direction andActiveTextField:(id)textField
{
    [self scrollViewToTextField:textField];
    [textField becomeFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if(section == 0){
        return FIRST_NAME;
    }else if(section == 1){
        return LAST_NAME;
    }else if(section == 2){
        return USER_NAME;
    }else if(section == 3){
        return PASSWORD;
    }else{
        return RETYPE_PASSWORD;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.backgroundColor = [UIColor whiteColor];
    }

    for(UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CGRect frame = [tableView rectForRowAtIndexPath:indexPath];
    
    if(indexPath.section == 2){
        UIView *required = [[UIView alloc] initWithFrame:CGRectMake(-6, 4, 4, frame.size.height-10)];
        required.layer.cornerRadius = 2;
        required.backgroundColor = [UIColor redColor];
        [cell.contentView addSubview:required];
        [required release];
    }
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(8, 4, frame.size.width-40, 35)];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.font = [UIFont boldSystemFontOfSize:15];
    textField.tag = indexPath.section;
    textField.delegate = self;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    if(indexPath.section == 0){
        
        textField.text = [currentUser.fields objectForKey:@"first_name"];
        textField.placeholder = FIRST_NAME;
        [textField.layer setValue:@"first_name" forKey:@"fieldName"];
        [textField becomeFirstResponder];
        
    }else if(indexPath.section == 1){
        
        textField.text = [currentUser.fields objectForKey:@"last_name"];
        textField.placeholder = LAST_NAME;
        [textField.layer setValue:@"last_name" forKey:@"fieldName"];
        
    }else if(indexPath.section == 2){
    
        textField.text = [currentUser.fields objectForKey:@"email"];
        textField.placeholder = ONLY_VALID_MAIL;
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        [textField.layer setValue:@"email" forKey:@"fieldName"];
        
    }else if(indexPath.section == 3){
        
        textField.text = [currentUser.fields objectForKey:@"password"];
        textField.secureTextEntry = YES;
        textField.placeholder = PASSWORD;
        [textField.layer setValue:@"password" forKey:@"fieldName"];
        
    }else{
        
        textField.text = [currentUser.fields objectForKey:@"retypePassword"];
        textField.secureTextEntry = YES;
        textField.placeholder = RETYPE_PASSWORD;
        [textField.layer setValue:@"retypePass" forKey:@"fieldName"];
        
    }
    
    textField.returnKeyType = UIReturnKeyNext;
    [cell.contentView addSubview:textField];
    [textField release];
    
    return cell;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end