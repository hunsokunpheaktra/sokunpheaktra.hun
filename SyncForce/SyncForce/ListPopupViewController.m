//
//  ListPopupViewController.m
//  SyncForce
//
//  Created by Gaeasys Admin on 11/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ListPopupViewController.h"
#import "ValuesCriteria.h"
#import "PicklistForRecordTypeInfoManager.h"
#import "FieldInfoManager.h"
#import "EntityManager.h"
#import "DatabaseManager.h"

@implementation ListPopupViewController

@synthesize listPopup,listItems,listItemsBackUp;
@synthesize editController,containerViewController;
@synthesize editPath,selectPath,tableView;
@synthesize fieldName,selectValue,fType;

- (id)initWithController:(NSString*)newEntity fieldName:(NSString*)newField listData:(NSArray*)listData recordType:(NSString*)type parentController:(EditViewController*)parent selectValue:(NSString*)value fieldType:(NSString*)fieldType{
    
    self = [super init];
    self.selectValue = value; 
    self.fType = fieldType;
    listItems = listData;
    self.fieldName = newField;
    self.editController = parent;
 
    CGRect rect = self.view.bounds;
    
    BOOL isShow = [listItems count] > 10;
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 50)];
    
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, isShow?50:0, 768, 1000) style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.dataSource = self;
    tableView.delegate = self;
    
    if(isShow){
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 50)];
        searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
        searchBar.showsCancelButton = NO;
        searchBar.delegate = self;
        [toolbar addSubview:searchBar];
        [searchBar release];
        [self.view addSubview:toolbar];
        [toolbar release];
    }
    [self.view addSubview:self.tableView];
    [self.tableView release];
    
    listItemsBackUp = listItems;
    
    return self;
}

- (void)showPopup:(UIView*)content parentView:(UIView*)parent{
    
    if([listPopup isPopoverVisible]){
        [listPopup dismissPopoverAnimated:YES];
        [listPopup release];
        [self release];
        return;
    }
        
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self];
    
    listPopup = [[UIPopoverController alloc] initWithContentViewController:nav];
    [nav release];
    listPopup.popoverContentSize = CGSizeMake(480, ([self.listItems count] * self.tableView.rowHeight) + 100);
    CGRect rect = [content.superview convertRect:content.frame fromView:parent];
    [listPopup presentPopoverFromRect:rect inView:parent permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.listItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.hidden = YES;
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:24];
    
    Item *item = [listItems objectAtIndex:indexPath.row];
    NSString *check = [fType isEqualToString:@"reference"]?@"Name":@"value";
    
    if([[item.fields objectForKey:check] isEqualToString:self.selectValue]){
        selectPath = [indexPath retain];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
     cell.detailTextLabel.text = [fType isEqualToString:@"reference"]?[item.fields objectForKey:@"Name"]:[item.fields objectForKey:@"value"];
    
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView cellForRowAtIndexPath:selectPath].accessoryType = UITableViewCellAccessoryNone;
    [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    selectPath = [indexPath retain];
    
    Item *item = [listItems objectAtIndex:indexPath.row];
    [editController updateCell:self.editPath newValue:[fType isEqualToString:@"reference"]?[item.fields objectForKey:@"Name"]:[item.fields objectForKey:@"value"]];
    
    [self.listPopup dismissPopoverAnimated:YES];
    [self.listPopup release];
}

#pragma mark UISearchBarDelegate 

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    listItems = listItemsBackUp;
    NSMutableArray* tmpListItems = [[[NSMutableArray alloc] init] autorelease];
   
    if (searchText.length > 0) { 
        for (Item *item in listItems) {
            NSString *values = [fType isEqualToString:@"reference"]?[item.fields objectForKey:@"Name"]:[item.fields objectForKey:@"value"];
            if(values.length > 0) { 
                if ([values rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    [tmpListItems addObject:item];
                }
            }
        }
    }else tmpListItems = [listItemsBackUp copy];

    listItems = [tmpListItems copy];
    [self.tableView reloadData];
 
}


@end
