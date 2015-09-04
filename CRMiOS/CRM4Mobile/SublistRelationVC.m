//
//  SublistRelationVC.m
//  CRMiOS
//
//  Created by Arnaud on 06/05/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import "SublistRelationVC.h"

@implementation SublistRelationVC


@synthesize related;
@synthesize sublist;
@synthesize parentItem;

- (id)initWithSublist:(NSString *)pSublist parent:(Item *)pParentItem related:(NSArray *)pRelated {
    
    self = [super initWithStyle:UITableViewStylePlain];
    self.related = pRelated;
    self.sublist = pSublist;
    self.parentItem = pParentItem;
    
    NSString *sublistCode = [NSString stringWithFormat:@"%@_PLURAL", sublist];
    self.title = NSLocalizedString(sublistCode, @"Sublist code");
    
    return self;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [related count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier1 = @"Cell1";
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier1] autorelease];
    }
   
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSDictionary *value = [self.related objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [value objectForKey:@"Name"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];

    NSDictionary *item = [related objectAtIndex:indexPath.row];
    SublistItem *subItem = [SublistManager find:self.parentItem.entity sublist:sublist criterias:[NSArray arrayWithObject:[ValuesCriteria criteriaWithColumn:@"gadget_id" value:[item objectForKey:@"gadget_id"]]]];
    IphoneSublistDetail *detail = [[IphoneSublistDetail alloc] initWithItem:subItem parent:self.parentItem];
    [[self navigationController] pushViewController:detail animated:YES];
    [detail release];
        
}

- (void)mustUpdate {
    
}


@end
