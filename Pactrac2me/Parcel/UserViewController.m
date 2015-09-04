//
//  UserViewController.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 11/6/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "UserViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "ValuesCriteria.h"
#import "ParcelEntityManager.h"
#import "Reachability.h"
#import "Reachability.h"

@implementation UserViewController

@synthesize user;

- (id)initWithParent:(id)parent{

    parentVC = parent;
    self = [super initWithStyle:UITableViewStyleGrouped];
    self.navigationItem.rightBarButtonItem = [[CustomUIBarButtonItem alloc] initWithText:MSG_EDIT target:self action:@selector(updateUser:)];
    return self;
}

- (void)updateUser:(UIButton*)button{
    
    if([[button titleForState:UIControlStateNormal] isEqualToString:MSG_EDIT]){
        
        [button setTitle:MSG_SAVE forState:UIControlStateNormal];
        isEditing = YES;
        [self updateView];
        
        UIResponder* nextResponder = [self.view viewWithTag:0];
        [nextResponder becomeFirstResponder];
        
        return;
    }
    
    [self.view endEditing:YES];
    
    NSString *email = [user.fields objectForKey:@"email"] == nil ? @"" : [user.fields objectForKey:@"email"];
    if(![self isValidEmail:email]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:INVALID_EMAIL message:ERROR_EMAIL delegate:self cancelButtonTitle:MSG_OK otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
        
    }
    
    NSString *password = [user.fields objectForKey:@"password"];
    password = password == nil ? @"" : password;
    NSString *retype = [user.fields objectForKey:@"retypePass"];
    retype = retype == nil ? @"" : retype;    
    
    Item *existUser = [UserManager find:@"User" column:@"email" value:[user.fields objectForKey:@"email"]];
    NSString *uId = [user.fields objectForKey:@"id"];
    uId = uId==nil ? [user.fields objectForKey:@"local_id"] : uId;
    
    NSString *newUid = [existUser.fields objectForKey:@"id"];
    newUid = newUid==nil ? [existUser.fields objectForKey:@"local_id"] : newUid;
    
    if(existUser && ![uId isEqualToString:newUid]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:DUPLICATE_USER message:EMAIL_IN_USED delegate:nil cancelButtonTitle:MSG_OK otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    [existUser release];
    
    NSString *oldPass = [[MainViewController getInstance].user.fields objectForKey:@"password"];
    oldPass = oldPass == nil || [oldPass isKindOfClass:[NSNull class]] ? @"" : oldPass;
    if(![oldPass isEqualToString:password] && ![password isEqualToString:retype]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:INVALID_PASSWORD message:CONFIRM_PASSWORD delegate:nil cancelButtonTitle:MSG_OK otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
        
    }
    
    [user.fields removeObjectForKey:@"retypePass"];
    
    if (![[user.fields valueForKey:@"modified"] isEqualToString:@"2"])
        [user.fields setValue:@"1" forKey:@"modified"];
    
    NSString *oldEmail = [[MainViewController getInstance].user.fields objectForKey:@"email"];
    NSString *newEmail = [user.fields objectForKey:@"email"];
    if(![oldEmail.lowercaseString isEqualToString:newEmail.lowercaseString]){
        
        NSMutableDictionary *criter = [NSMutableDictionary dictionary];
        [criter setObject:[[[ValuesCriteria alloc] initWithString:oldEmail] autorelease] forKey:@"user_email"];
        
        //update parcel user_email to id of user
        for(Item *item in [ParcelEntityManager list:@"Parcel" criterias:criter]){
            [item.fields setObject:newEmail forKey:@"user_email"];
            [ParcelEntityManager update:item modifiedLocally:NO];
            [item release];
        }
        
        //update setting user_email to id of user
        Item *settingItem = [SettingManager find:@"Setting" column:@"user_email" value:oldEmail];
        if(settingItem){
            [settingItem.fields setObject:newEmail forKey:@"user_email"];
            [SettingManager update:settingItem];
            [settingItem release];
        }
        
    }
    
    if([Reachability isNetWorkReachable:YES]){
        
        NSString *sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
        if(!sessionId){
            LoginRequest *login = [[LoginRequest alloc] init];
            [login doRequest:self];
            [login release];
        }else{
            CreateRecordRequest *upsertUser = [[CreateRecordRequest alloc] initWithItem:user];
            [upsertUser doRequest:self];
            [upsertUser release];
        }
        
    }else{
        [UserManager update:user];
        [parentVC updateUser:user];
        isEditing = NO;
        [self updateView];
    }
    
    [button setTitle:MSG_EDIT forState:UIControlStateNormal];
    [MainViewController getInstance].user = user;
    [self.tableView reloadData];
    
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


- (void)updateView{
    
    if(isEditing){
        if(fieldNames.count < 5){
            [fieldNames addObject:@"retypePass"];
            [fieldLabels addObject:@"Retype Password"];
        }
        [self.tableView reloadData];
    }else{
        if(fieldNames.count == 5){
            [fieldNames removeLastObject];
            [fieldLabels removeLastObject];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *background = [[[UIView alloc] initWithFrame:self.tableView.frame] autorelease];
    background.backgroundColor = [UIColor colorWithRed:(213./255.) green:(182./255.) blue:(145./255.) alpha:1];
    self.tableView.backgroundView = background;
    
    fieldNames = [[NSMutableArray alloc] initWithObjects:@"first_name",@"last_name",@"email",@"password", nil];
    fieldLabels = [[NSMutableArray alloc] initWithObjects:FIRST_NAME,LAST_NAME,USER_NAME,PASSWORD, nil];
    
    self.fields = [[NSDictionary alloc] initWithDictionary:user.fields];
    self.title = @"User";
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - TextField delegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return isEditing;
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

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    NSString *fieldName = [textField.layer valueForKey:@"fieldName"];
    
    NSString *value = textField.text;
    value = value == nil ? @"" : value;
    
    [user.fields setObject:value forKey:fieldName];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return fieldNames.count+2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return section >= fieldLabels.count ? @"" : [fieldLabels objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    for(UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CGRect frame = [tableView rectForRowAtIndexPath:indexPath];
    
    if(indexPath.section < fieldNames.count){
    
        cell.backgroundColor = [UIColor whiteColor];
        
        NSString *fieldLabel = [fieldLabels objectAtIndex:indexPath.section];
        NSString *fieldName = [fieldNames objectAtIndex:indexPath.section];
        NSString *value = [user.fields objectForKey:fieldName];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, frame.size.width-40, 30)];
        textField.text = value;
        textField.tag = indexPath.section;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.returnKeyType = UIReturnKeyNext;
        textField.delegate = self;
        textField.keyboardType = [fieldName isEqualToString:@"email"] ? UIKeyboardTypeEmailAddress : UIKeyboardTypeDefault;
        textField.secureTextEntry = [fieldName isEqualToString:@"password"] || [fieldName isEqualToString:@"retypePass"];
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.placeholder = fieldLabel;
        [textField.layer setValue:fieldName forKey:@"fieldName"];
        [cell.contentView addSubview:textField];
        [textField release];
        
    }else if(indexPath.section == fieldNames.count){
        
        UILabel *logout = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width-40, frame.size.height)];
        logout.backgroundColor = [UIColor clearColor];
        logout.font = [UIFont boldSystemFontOfSize:17];
        logout.textAlignment = UITextAlignmentCenter;
        logout.text = @"Log out";
        [cell.contentView addSubview:logout];
        [logout release];
        
    }else{
        
        UILabel *logout = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width-40, frame.size.height)];
        logout.backgroundColor = [UIColor clearColor];
        logout.font = [UIFont boldSystemFontOfSize:17];
        logout.textAlignment = UITextAlignmentCenter;
        logout.text = @"Sync & Log out";
        [cell.contentView addSubview:logout];
        [logout release];
        
    }
    
    return cell;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == 1 && buttonIndex == 0){
    
        [[MainViewController getInstance] logout];
        [MainViewController clearInstance];
        
    }
    if(alertView.tag == 2 && buttonIndex == 0){
        
        if([Reachability isNetWorkReachable:YES]){
        
            SynchronizedViewController *sync =  [[SynchronizedViewController alloc] initWithType:@"logout"];
            [self.navigationController pushViewController:sync animated:YES];
            [sync release];
        }
        
    }
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == fieldNames.count){
        
        NSDictionary* criteria = [NSDictionary dictionaryWithObjectsAndKeys:[[[ValuesCriteria alloc] initWithString:@"1"] autorelease],@"modified", nil];
        NSMutableArray* listModified = [NSMutableArray arrayWithArray:[ParcelEntityManager list:@"Parcel" criterias:criteria]];
        
        criteria = [NSDictionary dictionaryWithObjectsAndKeys:[[[ValuesCriteria alloc] initWithString:@"2"] autorelease],@"modified", nil];
        NSMutableArray* listNew = [NSMutableArray arrayWithArray:[ParcelEntityManager list:@"Parcel" criterias:criteria]];
        
        if ([listNew count]>0 || [listModified count]>0 || [[user.fields valueForKey:@"modified"] isEqualToString:@"1"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:PARCEL_LOGOUT_SYN_WARNING message:PARCEL_LOGOUT_SYN_WARNING_MESSAGE delegate:self cancelButtonTitle:LOGOUT otherButtonTitles:MSG_CANCEL,nil];
            alert.tag = 1;
            [alert show];
            [alert release];
        }else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:PARCEL_LOGOUT message:PARCEL_LOGOUT_MESSAGE delegate:self cancelButtonTitle:MSG_YES otherButtonTitles:MSG_NO,nil];
            alert.tag = 1;
            [alert show];
            [alert release];
            
        }
        
    }else if(indexPath.section == fieldNames.count+1){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:PARCEL_SYNC_LOGOUT message:PARCEL_SYNC_LOGOUT_MESSAGE delegate:self cancelButtonTitle:MSG_YES otherButtonTitles:MSG_NO,nil];
        alert.tag = 2;
        [alert show];
        [alert release];
        
    }
    
}

#pragma mark-
#pragma Sycnlistener

-(void)onSuccess:(id)req{
    
    SalesforceAPIRequest *request = req;
    if([request isKindOfClass:[LoginRequest class]]){
        
        CreateRecordRequest *upsertUser = [[CreateRecordRequest alloc] initWithItem:user];
        [upsertUser doRequest:self];
        [upsertUser release];
        
    }else if([request isKindOfClass:[CreateRecordRequest class]]){
        
        if([request.item.fields.allKeys containsObject:@"id"]){
            [user.fields setObject:[request.item.fields objectForKey:@"id"] forKey:@"id"];
        }
        [user.fields setValue:@"0" forKey:@"modified"];
        
        NSString *userId = [request.item.fields objectForKey:@"id"];
        userId = userId==nil ? @"" : userId;
        userId = [userId isEqualToString:@""] ? [request.item.fields objectForKey:@"local_id"] : userId;
        
        NSMutableDictionary *criter = [NSMutableDictionary dictionary];
        [criter setObject:[[[ValuesCriteria alloc] initWithString:[request.item.fields objectForKey:@"local_id"]] autorelease] forKey:@"user_email"];
        
        //update parcel user_email to id of user
        for(Item *item in [ParcelEntityManager list:@"Parcel" criterias:criter]){
            [item.fields setObject:userId forKey:@"user_email"];
            [ParcelEntityManager update:item modifiedLocally:NO];
            [item release];
        }
        
        //update setting user_email to id of user
        Item *settingItem = [SettingManager find:@"Setting" column:@"user_email" value:[request.item.fields objectForKey:@"email"]];
        if(settingItem){
            [settingItem.fields setObject:userId forKey:@"user_email"];
            [SettingManager update:settingItem];
            [settingItem release];
        }
        
        [UserManager update:user];
        [parentVC updateUser:user];
        isEditing = NO;
        [self updateView];
        
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

@end
