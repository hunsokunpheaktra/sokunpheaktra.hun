//
//  MultiSelectPopup.m
//  CRMiOS
//
//  Created by Arnaud Marguerat on 9/28/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "MultiSelectPopup.h"

@implementation MultiSelectPopup

@synthesize item;
@synthesize values;
@synthesize popoverController;
@synthesize entity;
@synthesize code;
@synthesize checked;
@synthesize listener;
@synthesize tableView;


- (id)initWithField:(NSString *)pCode entity:(NSString *)pEntity value:(NSString *)pValue item:(Item *)pItem listener:(NSObject<SelectionListener> *)pListener {
    self.item = pItem;
    self.code = pCode;
    self.entity = pEntity;
    self.listener = pListener;
    NSArray *tmp = [PicklistManager getPicklist:self.entity field:code item:item];
    self.values = [tmp subarrayWithRange:NSMakeRange(1, [tmp count] - 1)];
    self.checked = malloc(sizeof(BOOL) * [self.values count]);
    NSArray *chunks = [NSMutableArray arrayWithArray:[pValue componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@";,"]]];
    for (int i = 0; i < [self.values count]; i++) {
        NSDictionary *picklistValue = [self.values objectAtIndex:i];
        self.checked[i] = [chunks indexOfObject:[picklistValue objectForKey:@"ValueId"]] != NSNotFound;
    }
    return self;
}

- (int)getHeight {
    int height = [self.values count];
    if (height > 9) height = 9;
    return height;
}


- (void)viewDidLoad {
    
    
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 480, [self getHeight] * 44)];
    // Create the list
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 480, [self getHeight] * 44) style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [mainView addSubview:self.tableView];

    // sets the view
    [self setView:mainView];
    
}


- (void) show:(CGRect)rect parentView:(UIView *)parentView {
    if ([self.popoverController isPopoverVisible]) {
        //close the popover view if toolbar button was touched
        //again and popover is already visible
        
        [self.popoverController dismissPopoverAnimated:YES];
        [self release];
        return;
    }
    if ([self.values count] == 1) {
        return;
    }
    
    //build our custom popover view
    UINavigationController *popoverContent = [[UINavigationController alloc]
                                              initWithRootViewController:self];
    
    
    self.title = [FieldsManager read:self.entity field:self.code].displayName;
    
    //resize the popover view shown
    //in the current view to the view's size
    self.contentSizeForViewInPopover =
        CGSizeMake(480, [self getHeight] * 44);
    
    //create a popover controller
    self.popoverController = [[UIPopoverController alloc]
                              initWithContentViewController:popoverContent];
    
    //present the popover view non-modal with a
    //refrence to the toolbar button which was pressed
    [self.popoverController presentPopoverFromRect:rect inView:parentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [popoverContent release];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.values count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    
    // Configure the cell...
    NSDictionary *picklistValue = [self.values objectAtIndex:indexPath.row];
    NSString *tmpValue = [picklistValue objectForKey:@"Value"];
    [cell.textLabel setTextColor:[UIColor darkTextColor]];
    cell.textLabel.text = tmpValue;
    if (self.checked[indexPath.row]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.checked[indexPath.row] = !self.checked[indexPath.row];
    [tableView reloadData];
    NSMutableString *tmp = [[NSMutableString alloc] initWithCapacity:1];
    for (int i = 0; i < [self.values count]; i++) {
        if (self.checked[i]) {
            if ([tmp length] > 0) {
                [tmp appendString:@","];
            }
            NSDictionary *picklistValue = [self.values objectAtIndex:i];
            [tmp appendString:[picklistValue objectForKey:@"ValueId"]];
        }
    }
    [listener didSelect:self.code valueId:tmp display:nil];
}


- (void) dealloc
{
    free(self.checked);
    [values release];
    [super dealloc];
}


@end
