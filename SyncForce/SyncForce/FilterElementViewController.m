//
//  FilterElementViewController.m
//  SyncForce
//
//  Created by Hun Sokunpheaktra on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterElementViewController.h"

@interface InformationPopup : UITableViewController {
    
    UIPopoverController *popover;
    NSArray *listData;
    NSString *header;
    NSObject<UpdateListener> *updateListener;
    
}
- (id)initWithListData:(NSArray*)listItems title:(NSString*)newTitle updateListener:(NSObject<UpdateListener>*)listener;
- (void)show:(CGRect)rect parent:(UIView*)mainView;
@end

@implementation InformationPopup

- (id)initWithListData:(NSArray*)listItems title:(NSString*)newTitle updateListener:(NSObject<UpdateListener>*)listener{
    header = newTitle;
    self.title = newTitle;
    listData = listItems;
    updateListener = listener;
    return self;
}

- (void)show:(CGRect)rect parent:(UIView*)mainView{
    
    if(popover.popoverVisible){
        [popover release];
        [self release];
        return;
    }
    
    self.contentSizeForViewInPopover = CGSizeMake(300, 44*[listData count]);
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self];
    popover = [[UIPopoverController alloc] initWithContentViewController:nav];
    [popover presentPopoverFromRect:rect inView:mainView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [listData count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.textLabel.text = [listData objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [updateListener mustUpdate:[listData objectAtIndex:indexPath.row]];
    [popover dismissPopoverAnimated:YES];
}

@end

@implementation FilterElementViewController

@synthesize itemSelect,tag;

- (id)initWithHeader:(NSString*)newHeader title:(NSString*)newTitle selectValue:(NSString*)value arrItems:(NSArray*)items frame:(CGRect)rect updateListener:(NSObject<UpdateListener>*)newListener isFieldDisplay:(BOOL)isFieldDisplay{
    
    header = [newHeader retain];
    itemSelect = value;
    displayField = isFieldDisplay;
    NSMutableArray *tmp = [[[NSMutableArray alloc] initWithArray:items copyItems:YES] autorelease];
    
    listItems = [tmp copy];
    myTitle = newTitle;
    
    self.tableView = [[[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    UIView *background = [[UIView alloc] initWithFrame:self.tableView.backgroundView.frame];
    background.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = background;
    [background release];
    
    listener = newListener;
    self.tableView.scrollEnabled = NO;
    return self;
}

- (void)show:(CGRect)rect parent:(UIView*)mainView{
    
}

-(void)mustUpdate:(NSString *)value{
    if (!displayField) {
        if(![header isEqualToString:@"none"]){    
            value = [value isEqualToString:@"--None--"]?@"":value;
            Item *item = [[Item alloc] init:@"" fields:[[NSMutableDictionary alloc] initWithCapacity:1]];
            [item.fields setValue:[NSString stringWithFormat:@"%d",tag] forKey:@"tag"];
    
            [item.fields setValue:value forKey:@"value"];
            [item.fields setValue:header forKey:@"header"];
            [listener didUpdate:item];
        
        }else {
            [listener updateFieldDisplay:value index:tag];
        }
        
    }else {
        [listener updateFieldDisplay:value index:tag];
    }  
}

-(void)didUpdate:(Item *)newItem{
    
}

-(void)updateFieldDisplay:(NSString *)newValue index:(int)index{

}

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)dealloc{
    [super dealloc];
    [listItems release];
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    // Return the number of rows in the section.
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if ([header isEqualToString:@"Fields"]) return NSLocalizedString(@"FILED", nil);
    else if ([header isEqualToString:@"Operator"]) return NSLocalizedString(@"OPERATOR", nil);
    else if ([header isEqualToString:@"Values"]) return NSLocalizedString(@"VALUE", nil);
    else if([header isEqualToString:@"none"]) return @"";
    
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.textLabel.text = itemSelect;
    if (!(tag == 0 && [header isEqualToString:@""])) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }    
            
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([listItems count] >0) {
        if (!(tag == 0 && [header isEqualToString:@""])) {
            InformationPopup *popup = [[InformationPopup alloc] initWithListData:listItems title:myTitle updateListener:self];
            [popup show:[self.tableView cellForRowAtIndexPath:indexPath].frame parent:self.tableView];
        }    
    }  
}

@end

