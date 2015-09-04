//
//  PickListSelectController.m
//  CRMiOS
//
//  Created by Sy Pauv on 5/10/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "PickListSelectController.h"


@implementation PickListSelectController

@synthesize field, item, pickList, currentSelection;
@synthesize updateListener;

-(id)init:(NSString *)newField item:(Item *)newItem updateListener:(NSObject<UpdateListener> *)newListener {
    self = [super initWithStyle:UITableViewStyleGrouped];
    self.field = newField;
    self.item = newItem;
    self.updateListener = newListener;
    return self;
}



- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pickList = [PicklistManager getPicklist:self.item.entity field:self.field item:item];
    self.navigationItem.title = [FieldsManager read:self.item.entity field:field].displayName ;
    self.currentSelection = [self.item.fields objectForKey:field];

}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.pickList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"Cell1";
      UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
    
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1] autorelease];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    NSDictionary *picklistValue = [self.pickList objectAtIndex:indexPath.row]; 
    NSString *tmpValue = [picklistValue objectForKey:@"Value"];
    if ([tmpValue length] == 0) {
        [cell.textLabel setTextColor:[UIColor grayColor]];
        cell.textLabel.text = @"No value";
    } else {
        [cell.textLabel setTextColor:[UIColor darkTextColor]];
        cell.textLabel.text = tmpValue;
    }
    if ([currentSelection isEqualToString:[picklistValue objectForKey:@"ValueId"]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    

    // Opportunity SalesStage 
    if ([item.entity isEqualToString:@"Opportunity"] && [field isEqualToString:@"SalesStage"] ) {

        [item.fields setValue:[[self.pickList objectAtIndex:indexPath.row] objectForKey:@"Probability"] forKey:@"Probability"];
    }
    NSString *valueId = [[self.pickList objectAtIndex:indexPath.row] objectForKey:@"ValueId"];
    
    [item.fields setValue:valueId forKey:field]; 
    // update cascading fields
    NSDictionary *children = [CascadingPicklistManager getChildren:self.item.entity field:field value:valueId];
    for (NSString *relatedField in [children keyEnumerator]) {
        NSString *relatedValue = [self.item.fields objectForKey:relatedField];
        BOOL ok = NO;
        for (NSString *tmp in [children objectForKey:relatedField]) {
            if ([tmp isEqualToString:relatedValue]) {
                ok = YES;
                break;
            }
        }
        if (!ok) {
            [self.item.fields removeObjectForKey:relatedField];
        }
    }
    
    
    [self.updateListener mustUpdate];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
