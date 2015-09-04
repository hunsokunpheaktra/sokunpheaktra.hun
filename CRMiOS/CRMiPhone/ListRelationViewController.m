//
//  ListRelationViewController.m
//  CRMiOS
//
//  Created by Sy Pauv on 5/27/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "ListRelationViewController.h"


@implementation ListRelationViewController

@synthesize groups, relatedItems, subtype;

- (id)initWithRelSub:(RelationSub *)relSub refValue:(NSString *)refValue {
    
    self = [super initWithStyle:UITableViewStylePlain];
    self.subtype = relSub.otherSubtype;

    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:relSub.otherSubtype entity:relSub.otherEntity];
    NSArray *criterias = [NSArray arrayWithObject:[ValuesCriteria criteriaWithColumn:relSub.otherKey value:refValue]];
    self.relatedItems = [EntityManager list:sinfo.name entity:sinfo.entity criterias:criterias];
    


    self.groups = [GroupManager getGroups:self.subtype items:(NSArray *)relatedItems];
    self.title = [NSString stringWithFormat:@"Related %@", [sinfo localizedName]];
    


    return self;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.groups count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    Group *group = [groups objectAtIndex:section];
    return group.items.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    Group *group = [groups objectAtIndex:section];
    return group.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    static NSString *CellIdentifier2 = @"Cell2";    
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier2] autorelease];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    Group *group = [groups objectAtIndex:indexPath.section];
    Item *item = [group.items objectAtIndex:indexPath.row];
    // Configure the cell...
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:self.subtype];
    cell.textLabel.text = [sinfo getDisplayText:item];
    cell.detailTextLabel.text = [sinfo getDetailText:item];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];

    Group *group = [groups objectAtIndex:indexPath.section];
    Item *item = [group.items objectAtIndex:indexPath.row];
    DetailViewController *detailController = [[DetailViewController alloc] initWithItem:item listener:self];
    [self.navigationController pushViewController:detailController animated:YES];
    [detailController release];

}

- (void)mustUpdate {
   
}

@end
