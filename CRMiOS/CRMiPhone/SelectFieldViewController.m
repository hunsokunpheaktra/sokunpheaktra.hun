//
//  SelectFieldViewController.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/26/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "SelectFieldViewController.h"


@implementation SelectFieldViewController

@synthesize entity;
@synthesize subtype;
@synthesize fields;
@synthesize parent;

- (id)initWithEntity:(NSString *)newEntity subtype:(NSString *)newSubtype parent:(LayoutDetailViewController *)newParent selected:(NSMutableArray *)selected
{
    self = [super initWithStyle:UITableViewStylePlain];
    self.entity = newEntity;
    self.parent = newParent;
    self.subtype = newSubtype;
    self.title = @"Add Field";
    NSArray *allFields = [[Configuration getInfo:self.entity] fields];
    self.fields = [[NSMutableArray alloc] initWithCapacity:1];        
    for (NSString *code in allFields) {
        BOOL found = NO;
        for (NSString *other in selected) {
            if ([other isEqualToString:code]) {
                found = YES;
                break;
            }
        }
        if (!found) {
            CRMField *field = [FieldsManager read:self.entity field:code];
            NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:self.subtype];
            if ([field.type isEqualToString:@"ID"]) {
                continue;
            }
            BOOL isCriteria = NO;
            for (NSObject <Criteria> *criteria in [sinfo getCriterias]) {
                if ([field.code isEqualToString:[criteria column]]) {
                    isCriteria = YES;
                    break;
                }
            }
            if (isCriteria) {
                continue;
            }
            int i = 0;
            for (CRMField *other in self.fields) {
                if ([field.displayName compare:other.displayName] < 0) {
                    break;
                }
                i++;
            }
            if (field != nil) {
                [self.fields addObject:field];   
            }
            
            
        }
    }
    //[allFields release];
    return self;
}

- (void)dealloc
{
    [self.fields release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSLog(@"list Field size = %d",[fields count]);
    return [self.fields count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    CRMField *field = [fields objectAtIndex:indexPath.row];
    NSLog(@"Display name %@",field.displayName);
    cell.textLabel.text = field.displayName;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CRMField *field = [fields objectAtIndex:indexPath.row];
    [parent addField:field.code];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
