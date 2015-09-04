//
//  AutoSyncPopupViewController.m
//  CRMiOS
//
//  Created by Hun Sokunpheaktra on 5/21/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import "AutoSyncPopupViewController.h"


@interface AutoSyncPopupViewController ()

@end

@implementation AutoSyncPopupViewController

/*
** value is the last selected autosync
*/
-(id)init:(NSString*)value{

    self = [super initWithStyle:UITableViewStylePlain];
    _value = value;
    _picklistItems = [SyncTools autoSyncDelays];
    return self;
}

-(void)dealloc{
    [super dealloc];
    [_popover release];
    [_picklistItems release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

/*
** show picklist popup from UITableViewCell
*/
-(void)show:(UITableViewCell*)cell parentView:(UIView *)parentView{
    
    _cell = cell;
    
    if([_popover isPopoverVisible])
    {
        //close the popover view if toolbar button was touched
        //again and popover is already visible
        
        [_popover dismissPopoverAnimated:YES];
        [self release];
        return;
    }
    
    self.title = NSLocalizedString(@"AUTO_SYNC", nil);
    //build our custom popover view
    UINavigationController *popoverContent = [[UINavigationController alloc]
                                              initWithRootViewController:self];
    
    //resize the popover view shown
    //in the current view to the view's size
    self.contentSizeForViewInPopover =
    CGSizeMake(400, _picklistItems.count * 44);
    
    //create a popover controller
    _popover = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
    
    //present the popover view non-modal with a
    //refrence to the toolbar button which was pressed
    CGRect rect = cell.frame;
    [_popover presentPopoverFromRect:rect inView:parentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    [popoverContent release];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _picklistItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *value = [_picklistItems objectAtIndex:indexPath.row];
    cell.textLabel.text = [SyncTools getDelayDisplayValue:value];
    cell.accessoryType = [value isEqualToString:_value] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}



#pragma mark - Table view delegate 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *value = [_picklistItems objectAtIndex:indexPath.row];
    _cell.detailTextLabel.text = [SyncTools getDelayDisplayValue:value];

    [PropertyManager save:@"SyncAtStartup" value:value];
    [_popover dismissPopoverAnimated:YES];
    
    //rerun schedule sync background
    gadgetAppDelegate *delegate = (gadgetAppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate abortScheduleTimer];
    [delegate runScheduleTimer];
    
}

@end
