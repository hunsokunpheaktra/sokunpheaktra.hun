//
//  LayoutDetailViewController.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/26/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "LayoutDetailViewController.h"


@implementation LayoutDetailViewController

@synthesize entity;
@synthesize fields;
@synthesize subtype;

- (id)initWithEntity:(NSString *)newEntity subtype:(NSString *)newSubtype
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    self.entity = newEntity;
    self.subtype = newSubtype;
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:self.subtype];
    self.fields = [LayoutFieldManager read:self.subtype page:0 section:0];
    self.title = [NSString stringWithFormat:@"%@ Layout", [sinfo localizedName]];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStyleBordered target:self action:@selector(reset)];
    [self.navigationItem setRightBarButtonItem:item];
    [self setEditing:YES];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return [self.fields count];
    } else {
        return 1;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        NSString *code = [fields objectAtIndex:indexPath.row];
        CRMField *field = [FieldsManager read:entity field:code];
        cell.textLabel.text = field.displayName;
        
    } else {
        cell.textLabel.text = @"Add New Field";
    }
    
    return cell;
}

// The editing style for a row is the kind of button displayed to the left of the cell when in editing mode.
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleInsert;
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath {
    CRMField *field = [[fields objectAtIndex:fromIndexPath.row] retain];
    [fields removeObject:field];
    [fields insertObject:field atIndex:toIndexPath.row];
    
    [LayoutFieldManager save:self.subtype  page:0 section:0 fields:fields];
    [field release];
}

// Update the data model according to edit actions delete or insert.
- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [fields removeObjectAtIndex:indexPath.row];
        [LayoutFieldManager save:self.subtype page:0 section:0 fields:fields];
        [self.tableView reloadData];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        SelectFieldViewController *selectController = [[SelectFieldViewController alloc] initWithEntity:entity subtype:self.subtype parent:self selected:fields];
        [[self navigationController] pushViewController:selectController animated:YES];
        [selectController release];
    }
}

- (void)addField:(NSString *)field {
    [fields addObject:field];
    [LayoutFieldManager save:self.subtype page:0 section:0 fields:fields];
    [self.tableView reloadData];
    
}

- (IBAction)reset {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset Layout" message:@"Reset the layout to defaults ?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
    
        Configuration *configuration = [Configuration getInstance]; 
        for (ConfigSubtype *configSubtype in configuration.subtypes) {
            if ([configSubtype.entity isEqualToString:entity]) {
                Page *page = [configSubtype.detailLayout.pages objectAtIndex:0];
                Section *section = [page.sections objectAtIndex:0];
                self.fields = section.fields;
                [LayoutFieldManager save:configSubtype.name page:0 section:0 fields:fields];
                [self.tableView reloadData];
                break;
            }
        }
        
    }
}


@end
