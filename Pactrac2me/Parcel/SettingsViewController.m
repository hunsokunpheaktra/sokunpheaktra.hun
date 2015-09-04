//
//  SettingViewController.m
//  Parcel
//
//  Created by Davin Pen on 10/2/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingDetailViewController.h"
#import "UserViewController.h"
#import "SynchronizedViewController.h"
#import "DEFacebookComposeViewController.h"
#import "Base64.h"
//#import "PurchaseAppViewController.h"

@implementation SettingsViewController

@synthesize tableView,languages,userLogin;

- (id)initWithUser:(Item*)item
{
    self = [super init];
    
    userLogin = item;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    CGRect frame = self.view.frame;
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    [tableView release];
    
    UIView *background = [[[UIView alloc] initWithFrame:tableView.frame] autorelease];
    background.backgroundColor = [UIColor colorWithRed:(213./255.) green:(182./255.) blue:(145./255.) alpha:1];
    tableView.backgroundView = background;
    
    headerTitle = [[NSArray alloc] initWithObjects:PREMIUM_VERSION,LANGUAGE,PERSONAL,SYNCHRONIZE,SERVICE,OTHER, nil];
    
    sections = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    //purchase section
    NSMutableArray *sectionListItems = [NSMutableArray array];
    NSDictionary *sectionItem = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"isPurchase",INAPP_PURCHASE, nil] forKeys:[NSArray arrayWithObjects:@"fieldName",@"fieldLabel", nil]];
    
    [sectionListItems addObject:sectionItem];
    [sections setObject:sectionListItems forKey:PREMIUM_VERSION];
    
    
    //language
    sectionListItems = [NSMutableArray array];
    sectionItem = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"language", LANGUAGE, nil] forKeys:[NSArray arrayWithObjects:@"fieldName",@"fieldLabel", nil]];
    
    [sectionListItems addObject:sectionItem];
    [sections setObject:sectionListItems forKey:LANGUAGE];
    
    
    //personal section
    sectionListItems = [NSMutableArray array];
    sectionItem = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"user",USER, nil] forKeys:[NSArray arrayWithObjects:@"fieldName",@"fieldLabel", nil]];
    [sectionListItems addObject:sectionItem];
    
    sectionItem = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"defaultReminderSetting",DEFAULT_REMINDER_SETTING, nil] forKeys:[NSArray arrayWithObjects:@"fieldName",@"fieldLabel", nil]];
    [sectionListItems addObject:sectionItem];
    
    [sections setObject:sectionListItems forKey:PERSONAL];
    
    //service section
    sectionListItems = [NSMutableArray array];
    sectionItem = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"pushService",PUSH_SERVICE, nil] forKeys:[NSArray arrayWithObjects:@"fieldName",@"fieldLabel", nil]];
    
    [sectionListItems addObject:sectionItem];
    [sections setObject:sectionListItems forKey:SERVICE];
    
    //synchronize section
    sectionListItems = [NSMutableArray array];
    sectionItem = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"forceSync",SERVER_SYNC, nil] forKeys:[NSArray arrayWithObjects:@"fieldName",@"fieldLabel", nil]];
    [sectionListItems addObject:sectionItem];
    
    sectionItem = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"updateAtStart",UPDATE_AT_START, nil] forKeys:[NSArray arrayWithObjects:@"fieldName",@"fieldLabel", nil]];
    [sectionListItems addObject:sectionItem];
    
    [sections setObject:sectionListItems forKey:SYNCHRONIZE];
    
    //other
    sectionListItems = [NSMutableArray array];
    sectionItem = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"inviteFriend",INVITE_FRIEND, nil] forKeys:[NSArray arrayWithObjects:@"fieldName",@"fieldLabel", nil]];
    [sectionListItems addObject:sectionItem];
    
    sectionItem = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"feedback",FEEDBACK, nil] forKeys:[NSArray arrayWithObjects:@"fieldName",@"fieldLabel", nil]];
    [sectionListItems addObject:sectionItem];
    
    sectionItem = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"FAQ",FAQ, nil] forKeys:[NSArray arrayWithObjects:@"fieldName",@"fieldLabel", nil]];
    [sectionListItems addObject:sectionItem];
    
    sectionItem = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Tutorial",TUTORIAL, nil] forKeys:[NSArray arrayWithObjects:@"fieldName",@"fieldLabel", nil]];
    [sectionListItems addObject:sectionItem];
    
    [sections setObject:sectionListItems forKey:OTHER];
    
    self.languages = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"United-States-of-America-Flag.png",@"Germany-Flag.png",nil] forKeys:[NSArray arrayWithObjects:ENGLISH, GERMAN, nil]];
    
    //self.languages = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"United-States-of-America-Flag.png",@"Germany-Flag.png",@"Sweden-Flag.png",@"France-Flag.png",@"Italy-Flag.png",@"Spain-Flag.png",@"China-Flag.png", nil] forKeys:[NSArray arrayWithObjects: NSLocalizedString(@"ENGLISH", @"English"), NSLocalizedString(@"GERMAN", @"German"),NSLocalizedString(@"SWEDISH", @"Swedish"),NSLocalizedString(@"FRENCH", @"French"),NSLocalizedString(@"ITALIAN", @"Italian"), NSLocalizedString(@"SPANISH", @"Spainish"), NSLocalizedString(@"CHINESE", @"Chinese"), nil]];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    NSString *userId = [userLogin.fields objectForKey:@"id"];
    userId = userId==nil ? @"" : userId;
    userId = [userId isEqualToString:@""] ? [userLogin.fields objectForKey:@"email"] : userId;
    
    settingItem = [SettingManager find:@"Setting" column:@"user_email" value:userId];
    
    NSString* unit = [[[settingItem.fields objectForKey:@"defaultReminderSetting"] componentsSeparatedByString:@" "] objectAtIndex:1];
    NSString* amount = [[[settingItem.fields objectForKey:@"defaultReminderSetting"] componentsSeparatedByString:@" "] objectAtIndex:0];
    
    self.defaultRemindersetting=  [NSString stringWithFormat:@"%@ %@",amount,(NSLocalizedString(unit, @""))];
    
    [tableView reloadData];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return headerTitle.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSArray *listItems = [sections objectForKey:[headerTitle objectAtIndex:section]];
    return listItems.count;
    
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [headerTitle objectAtIndex:section];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
-(UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryView = nil;
    cell.imageView.image = nil;
    cell.detailTextLabel.text = @"";
    
    NSArray *listItems = [sections objectForKey:[headerTitle objectAtIndex:indexPath.section]];
    NSDictionary *fieldItem = [listItems objectAtIndex:indexPath.row];
    NSString *fieldLabel = [fieldItem objectForKey:@"fieldLabel"];
    NSString *fieldName = [fieldItem objectForKey:@"fieldName"];
    NSString *value = @"";
    
    if([settingItem.fields.allKeys containsObject:fieldName]){
        value = [settingItem.fields objectForKey:fieldName];
    }
    
    if([fieldName isEqualToString:@"isLocalStorage"]|| [fieldName isEqualToString:@"wlanSync"] || [fieldName isEqualToString:@"cloudSync"] || [fieldName isEqualToString:@"updateAtStart"]){
        
        UISwitch *mySwitch = [[UISwitch alloc] init];
        mySwitch.on = [value isEqualToString:@"yes"];
        [mySwitch.layer setValue:fieldName forKey:@"fieldName"];
        [mySwitch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = mySwitch;
        [mySwitch release];
        
    }else if([fieldName isEqualToString:@"language"]){
        cell.imageView.image = [UIImage imageNamed:[languages objectForKey:value]];
        cell.detailTextLabel.text = value;
    }else if([fieldName isEqualToString:@"isPurchase"]){
        cell.detailTextLabel.text = TRIAL_DAY_NUMBER;
    }
    
    if([fieldName isEqualToString:@"defaultReminderSetting"]){
        cell.detailTextLabel.text=self.defaultRemindersetting;
    }
    
    cell.textLabel.text = fieldLabel;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *listItems = [sections objectForKey:[headerTitle objectAtIndex:indexPath.section]];
    NSDictionary *fieldItem = [listItems objectAtIndex:indexPath.row];
    NSString *fieldName = [fieldItem objectForKey:@"fieldName"];
    NSString *fieldLabel= [fieldItem objectForKey:@"fieldLabel"];
    NSString *value = @"";
    
    if([settingItem.fields.allKeys containsObject:fieldName]){
        value = [settingItem.fields objectForKey:fieldName];
    }
    
    NSArray *items = nil;
    NSArray *icons = nil;
    
    if([fieldName isEqualToString:@"isPurchase"]){
        
        //        PurchaseAppViewController *purchase = [[PurchaseAppViewController alloc] init];
        //        [self.navigationController pushViewController:purchase animated:YES];
        //        [purchase release];
        
    }
    
    if([fieldName isEqualToString:@"language"]){
        
        items = [languages.allKeys retain];
        icons = [languages.allValues retain];
        
        SettingDetailViewController *edit = [[SettingDetailViewController alloc] initWithListItems:items icons:icons fieldName:fieldName value:value listener:self];
        edit.title = fieldLabel;
        [self.navigationController pushViewController:edit animated:YES];
        [edit release];
        
    }
    if([fieldName isEqualToString:@"feedback"]){
        
        DEFacebookComposeViewController *composeMessage = [[DEFacebookComposeViewController alloc] initWithType:@"Compose"];
        [self presentModalViewController:composeMessage animated:YES];
        [composeMessage release];
        
    }
    
    if([fieldName isEqualToString:@"user"]){
        
        UserViewController *user = [[UserViewController alloc] initWithParent:self];
        user.user = [UserManager find:@"User" column:@"email" value:[userLogin.fields objectForKey:@"email"]];
        [self.navigationController pushViewController:user animated:YES];
        [user release];
        
    }
    
    if([fieldName isEqualToString:@"forceSync"]){
        
        SynchronizedViewController *sync =  [[SynchronizedViewController alloc] initWithType:@"normal"];
        [self.navigationController pushViewController:sync animated:YES];
        [sync release];
        
    }
    
    if ([fieldName isEqualToString:@"defaultReminderSetting"]) {
        DefaultRemindersettingsView *reminderselect=[[DefaultRemindersettingsView alloc]inithWithItem:settingItem];
        reminderselect.listener=self;
        [self.navigationController pushViewController:reminderselect animated:YES];
        [reminderselect release];
    }
    
   
}

- (void) updateUser : (Item*)item{
    userLogin = item;
}


-(void)switchChange:(UISwitch*)newSwitch{
    
    NSString *fieldName = [newSwitch.layer valueForKey:@"fieldName"];
    NSString *value = newSwitch.on ? @"yes" : @"no";
    [settingItem.fields setObject:value forKey:fieldName];
    [SettingManager update:settingItem];
}

#pragma mark -updateListener
-(void)didUpdate:(NSString*)fName value:(NSString*)value{
    [settingItem.fields setObject:value forKey:fName];
    [SettingManager update:settingItem];
}
-(void)mustUpdate:(Item *)item{
    
}

#pragma mark - mail composer

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            
            break;
        case MFMailComposeResultSaved:
            
            break;
        case MFMailComposeResultSent:
                                             
            break;
        case MFMailComposeResultFailed:
            
            break;
        default:
            
            break;
    }
    
    [controller dismissModalViewControllerAnimated:YES];
}

#pragma mark - Reminderlistener
-(void)didselect:(id)val{
    settingItem=(Item *)val;
    [SettingManager update:settingItem];
    [self.tableView reloadData];
}



- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
