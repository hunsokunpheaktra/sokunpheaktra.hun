//
//  AlertViewTool.m
//  CRMiOS
//
//  Created by Hun Sokunpheaktra on 9/5/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "AlertViewTool.h"

@implementation AlertViewTool

@synthesize controlDb;
@synthesize popup;
@synthesize mainView;
@synthesize tabLayout;

- (id)initWithDatabase:(Database*)db parentView:(UIView *)parentView tabLayout:(NSObject <TabLayout> *)newTabLayout {
    
    self = [super init];
    
    self.controlDb = db;
    self.mainView = parentView;
    self.tabLayout = newTabLayout;
    
    return self;
    
}

-(BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    return NO;
}

- (void)loadOpenDatabase {
    
    lblHead = [[UILabel alloc] init];
    lblHead.text = NSLocalizedString(@"Header_Access_DB", @"Header Access encrypted Database.");
    lblHead.textAlignment = UITextAlignmentCenter;
    [lblHead setBackgroundColor:[UIColor clearColor]];
    
    tvDesc = [[UITextView alloc] init];
    [tvDesc setBackgroundColor:[UIColor clearColor]];
    [tvDesc setEditable:NO];
    tvDesc.text = NSLocalizedString(@"OPEN_ENCRYPTED_DESC", @"Open encrypted database description.");
    
    lblPass = [[UILabel alloc] init];
    lblPass.text = NSLocalizedString(@"ENTER_PASSWORD", @"Label input password");
    
    txtPassword = [[UITextField alloc] init];
    [txtPassword setBorderStyle:UITextBorderStyleRoundedRect];
    txtPassword.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    txtPassword.secureTextEntry = YES;
    txtPassword.placeholder = NSLocalizedString(@"PASSWORD", @"Password");
    txtPassword.delegate = self;
    txtPassword.returnKeyType = UIReturnKeyDefault;
    
    btnCreate = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnCreate setTitle:NSLocalizedString(@"BUTTON_VALIDATE_PASSWORD", @"Button label validate database.") forState:UIControlStateNormal];
    [btnCreate setEnabled:YES];
    [btnCreate addTarget:self action:@selector(validateDatabase:) forControlEvents:UIControlEventTouchUpInside];
    
    lblMessage = [[UITextView alloc] init];
    [lblMessage setEditable:NO];
    lblMessage.textAlignment = UITextAlignmentCenter;
    lblMessage.textColor = [UIColor redColor];
    
    [self loadGUI];
    
    [self.view addSubview:lblHead];
    [self.view addSubview:tvDesc];
    [self.view addSubview:lblPass];
    [self.view addSubview:txtPassword];
    [self.view addSubview:btnCreate];
    [self.view addSubview:lblMessage];
    
    [lblMessage release];
    [txtPassword release];
    [lblPass release];
    [lblHead release];
    [tvDesc release];
    
}

- (void)loadEncryptedDatabase {

    lblHead = [[UILabel alloc] init];
    lblHead.text =  NSLocalizedString(@"HEADER_CREATE_ENCRYPTED_DB", @"Header create encrypted Database.");
    lblHead.textAlignment = UITextAlignmentCenter;
    [lblHead setBackgroundColor:[UIColor clearColor]];
    
    tvDesc = [[UITextView alloc] init];
    [tvDesc setBackgroundColor:[UIColor clearColor]];
    [tvDesc setEditable:NO];
    tvDesc.text =  NSLocalizedString(@"ENCRYPT_DB_DESCRIPTION", @"Decription for Database encrypt.");
    
    lblPass = [[UILabel alloc] init];
    lblPass.text = NSLocalizedString(@"ENTER_PASSWORD", @"label enter your password.");
    [lblPass setBackgroundColor:[UIColor clearColor]];
    
    txtPassword = [[UITextField alloc] init];
    [txtPassword setBorderStyle:UITextBorderStyleRoundedRect];
    txtPassword.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    txtPassword.secureTextEntry = YES;
    txtPassword.placeholder = NSLocalizedString(@"PASSWORD", @"Password");
    txtPassword.delegate = self;
    txtPassword.returnKeyType = UIReturnKeyNext;
    
    lblConfirm = [[UILabel alloc] init];
    lblConfirm.text =NSLocalizedString(@"RE_ENTER_PWD", @"Re-enter password");
    [lblConfirm setBackgroundColor:[UIColor clearColor]];
    
    txtConfirm = [[UITextField alloc] init];
    [txtConfirm setBorderStyle:UITextBorderStyleRoundedRect];
    txtConfirm.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    txtConfirm.secureTextEntry = YES;
    txtConfirm.placeholder = NSLocalizedString(@"CONFIRM_PWD",@"Confirm passwrod.");
    txtConfirm.delegate = self;
    
    btnCreate = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnCreate setTitle:NSLocalizedString(@"USE_PASSWORD", @"Button label 'use password'") forState:UIControlStateNormal];
    [btnCreate addTarget:self action:@selector(createEncryptedDatabase:) forControlEvents:UIControlEventTouchUpInside];
    
    btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnCancel setTitle:NSLocalizedString(@"DONT_USE_PASSWORD",@"Button label ' Don't use password' .")  forState:UIControlStateNormal];
    [btnCancel setEnabled:YES];
    [btnCancel addTarget:self action:@selector(notUsePassword:) forControlEvents:UIControlEventTouchUpInside];
    
    lblMessage = [[UITextView alloc] init];
    [lblMessage setEditable:NO];
    lblMessage.textAlignment = UITextAlignmentCenter;
    lblMessage.textColor = [UIColor redColor];
    [lblMessage setBackgroundColor:[UIColor clearColor]];
    
    [self loadGUI];
    
    [self.view addSubview:btnCreate];
    [self.view addSubview:btnCancel];
    [self.view addSubview:lblHead];
    [self.view addSubview:tvDesc];
    [self.view addSubview:lblPass];
    [self.view addSubview:txtPassword];
    [self.view addSubview:lblConfirm];
    [self.view addSubview:txtConfirm];
    [self.view addSubview:lblMessage];
    
    [lblMessage release];
    [txtConfirm release];
    [lblConfirm release];
    [txtPassword release];
    [lblPass release];
    [lblHead release];
    [tvDesc release];
    
}

- (void)loadGUI {

    CGRect rect = [UIScreen mainScreen].bounds;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        lblHead.font = [UIFont boldSystemFontOfSize:40];
        tvDesc.font = [UIFont systemFontOfSize:16];
        lblPass.font = [UIFont systemFontOfSize:20];
        lblConfirm.font = [UIFont systemFontOfSize:20];
        lblMessage.font = [UIFont systemFontOfSize:16];
        
        if([popup isPopoverVisible]){
            [popup dismissPopoverAnimated:NO];
            [popup release];
        }
        
        UINavigationController *popoverContent = [[UINavigationController alloc] initWithRootViewController:self];
        [self setTitle:NSLocalizedString(@"TITLE_ENCRYPTED_DB", nil)];
        self.contentSizeForViewInPopover = rect.size;
        [self.view setBackgroundColor:[UIColor whiteColor]];
        popup = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
        popup.delegate = self;
        [popoverContent release];
        
        lblHead.frame = CGRectMake(0, 40, rect.size.width, 40);
        tvDesc.frame = CGRectMake(100, 90, 550, 200);
        lblPass.frame = CGRectMake(110, 200, 250, 40);
        txtPassword.frame = CGRectMake(390, 200, 250, 40);
        
        if(lblConfirm){
            lblConfirm.frame = CGRectMake(110, 250, 250, 40);
            txtConfirm.frame = CGRectMake(390, 250, 250, 40);
            btnCreate.frame = CGRectMake(110, 330, 250, 50);
            btnCancel.frame = CGRectMake(390, 330, 250, 50);
            lblMessage.frame = CGRectMake(100, 470, 550, 100);
        }else{
            lblPass.frame = CGRectMake(110, 160, 250, 40);
            txtPassword.frame = CGRectMake(390, 160, 250, 40);
            btnCreate.frame = CGRectMake(240, 240, 250, 50);
            lblMessage.frame = CGRectMake(80, 320, 550, 100);
        }
        
        if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown){
    
            [popup presentPopoverFromRect:rect inView:mainView permittedArrowDirections:0 animated:NO];
            
        }else{
            [popup presentPopoverFromRect:CGRectMake(260, 0, rect.size.width, rect.size.height) inView:mainView permittedArrowDirections:0 animated:NO];
        }
        
    } else {
        
        if(mainView) [mainView addSubview:self.view];
        
        lblHead.font = [UIFont boldSystemFontOfSize:22];
        tvDesc.font = [UIFont systemFontOfSize:12];
        lblPass.font = [UIFont systemFontOfSize:12];
        lblConfirm.font = [UIFont systemFontOfSize:12];
        btnCreate.titleLabel.font = [UIFont boldSystemFontOfSize:10];
        btnCancel.titleLabel.font = [UIFont boldSystemFontOfSize:10];
        lblMessage.font = [UIFont systemFontOfSize:12];
        
        if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown){
            
            lblHead.frame = CGRectMake(0, 10, rect.size.width, 45);
            tvDesc.frame = CGRectMake(5, 55, 315, 200);
            lblPass.frame = CGRectMake(12, 150, 140, 40);
            txtPassword.frame = CGRectMake(150, 155, 160, 30);
            
            if (lblConfirm) {
                lblConfirm.frame = CGRectMake(12, 190, 140, 40);
                txtConfirm.frame = CGRectMake(150, 195, 160, 30);
                btnCreate.frame = CGRectMake(10, 250, 140, 30);
                btnCancel.frame = CGRectMake(170, 250, 140, 30);
                lblMessage.frame = CGRectMake(0, 340, 320, 200);
            } else {
                lblPass.frame = CGRectMake(12, 90, 140, 40);
                txtPassword.frame = CGRectMake(150, 95, 160, 30);
                btnCreate.frame = CGRectMake(100, 150, 120, 30);
                lblMessage.frame = CGRectMake(5, 200, 315, 200);
            }
            
        }
        
    }
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if(textField == txtPassword && textField.returnKeyType == UIReturnKeyNext){
        [txtConfirm becomeFirstResponder];
    }
    return YES;
}

- (IBAction)validateDatabase:(id)sender{
    
    lblMessage.text = @"";
    [txtConfirm resignFirstResponder];
    [txtPassword resignFirstResponder];
    
    [controlDb reOpenDatabase];
    //check key match key in database if key match we can query
    if(![EncryptedDatabase executeOpen:controlDb.database openKey:txtPassword.text]){
        //if key not match show error
        lblMessage.text =NSLocalizedString(@"Wrong_PWD", @"Wrong password inputed.");
        
    } else {
        [self loadLayout];

    }
    
}

- (IBAction)notUsePassword:(id)sender{
    
    [self loadLayout];
    
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) return YES;
    else return NO;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    [self loadGUI];
        
}

- (IBAction)createEncryptedDatabase:(id)sender{
    
    lblMessage.text = @"";
    if([txtPassword.text length] >= 8 && [txtPassword.text length] <= 32){
        //Does password and confirm match ?
        if (![txtPassword.text isEqualToString:txtConfirm.text]){
            lblMessage.text =  NSLocalizedString(@"LABEL_PASSWORD_DIFFERENCE", @"Label error message Password and confirm are different.");
        } else {
            NSLog(@"Encrypt");
            //put password user enter as key for encrypt database
            [EncryptedDatabase executeEncrypt:controlDb.database encryptKey:txtPassword.text];
            //init layout
            [self loadLayout];
        }
        
    } else {
        lblMessage.text = NSLocalizedString(@"LABEL_INVALID_PASSWORD", @"The password must be 8-32 characters long.");
    }

}

- (void)loadLayout{
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        //gadgetAppDelegate *ipadDelegate = (gadgetAppDelegate*)[[UIApplication sharedApplication] delegate];
        [self.tabLayout initLayout];
        if([popup isPopoverVisible]) [popup dismissPopoverAnimated:YES];
        
    } else { 
        //CRMAppDelegate *iphoneDelegate = (CRMAppDelegate*)[[UIApplication sharedApplication] delegate];
        if([self.view isDescendantOfView:mainView]){ 
            [self.view removeFromSuperview];
        }
        [self dismissModalViewControllerAnimated:NO];
        [self.tabLayout initLayout];
        [self.view removeFromSuperview];
        [self release];
    }

}

@end
