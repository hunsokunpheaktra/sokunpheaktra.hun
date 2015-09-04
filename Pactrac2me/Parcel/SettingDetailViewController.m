//
//  SettingDetailViewController.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 10/26/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "SettingDetailViewController.h"
#import "MainViewController.h"

@implementation SettingDetailViewController

-(id)initWithListItems:(NSArray*)items icons:(NSArray*)icons fieldName:(NSString*)fName value:(NSString*)val listener:(NSObject<UpdateListener>*)listener{
    
    selectValue = val;
    listItems = items;
    listIcons = icons;
    updateListener = listener;
    fieldName = fName;
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    self.navigationItem.rightBarButtonItem = [[CustomUIBarButtonItem alloc] initWithText:@"Done" target:self action:@selector(done)];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *background = [[[UIView alloc] initWithFrame:self.tableView.frame] autorelease];
    background.backgroundColor = [UIColor colorWithRed:(213./255.) green:(182./255.) blue:(145./255.) alpha:1];
    self.tableView.backgroundView = background;
    
}

-(void)done{
    
    /*NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableArray *languages = [def objectForKey:@"AppleLanguages"];
    if(![selectValue isEqualToString:[languages objectAtIndex:0]]){
        if([selectValue isEqualToString:@"English"]){
            [def setObject:[NSArray arrayWithObjects:@"en", @"de", nil] forKey:@"AppleLanguages"];
        }else{
            [def setObject:[NSArray arrayWithObjects:@"de", @"en", nil] forKey:@"AppleLanguages"];
        }
        [def synchronize];
        
        Item *user = [MainViewController getInstance].user;
        int loginCount = [[user.fields objectForKey:@"loginCount"] intValue];
        [user.fields setObject:[NSString stringWithFormat:@"%d",loginCount+1] forKey:@"loginCount"];
        [UserManager update:user];
        
        [LanguageTool changeLanguage];
    }
    [[MainViewController getInstance] reloadTabs];*/
    
    [updateListener didUpdate:fieldName value:selectValue];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return listItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imageView.image = nil;
    
    NSString *value = [listItems objectAtIndex:indexPath.row];
    cell.accessoryType = [value isEqualToString:selectValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.textLabel.text = value;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    
    if(listIcons){
        cell.imageView.image = [UIImage imageNamed:[listIcons objectAtIndex:indexPath.row]];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectValue = [listItems objectAtIndex:indexPath.row];
    [self.tableView reloadData];
    
}

@end
