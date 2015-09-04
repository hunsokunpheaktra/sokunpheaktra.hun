//
//  AutoSyncDelayVC.m
//  CRMiOS
//
//  Created by Arnaud on 22/05/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import "AutoSyncDelayVC.h"

@implementation AutoSyncDelayVC

- (id)init {
    self = [super init];
    self.values = [SyncTools autoSyncDelays];
    self.title = NSLocalizedString(@"AUTO_SYNC", nil);
    return self;
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.values count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"Cell1";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1] autorelease];
    }
    NSString *value = [self.values objectAtIndex:indexPath.row];
    cell.textLabel.text = [SyncTools getDelayDisplayValue:value];
    if ([[PropertyManager read:@"SyncAtStartup"] isEqualToString:value]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *value = [self.values objectAtIndex:indexPath.row];
    [PropertyManager save:@"SyncAtStartup" value:value];
    [self.navigationController popViewControllerAnimated:YES];
    
    //rerun schedule sync background
    CRMAppDelegate *delegate = (CRMAppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate abortScheduleTimer];
    [delegate runScheduleTimer];
    
}

@end
