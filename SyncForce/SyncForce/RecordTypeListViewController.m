//
//  RecordTypeListViewController.m
//  SyncForce
//
//  Created by Gaeasys on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecordTypeListViewController.h"
#import "CustomDataGrid.h"

@interface RecordTypeList : UITableViewController {
    
    UIPopoverController *popover;
    NSArray *listData;
    NSString * recordSelected;
    NSObject<UpdateListener> *updateListener;
    id parent;
    
}

- (id)initWithframe:(CGRect)rect listItems:(NSArray*)listItems updateListener:(id)listener recordTypeSelected:(NSString*)record parent:(id)parentCon;

- (void)show:(CGRect)rect parent:(UIView*)mainView;
@end


@implementation RecordTypeList

- (id)initWithframe:(CGRect)rect listItems:(NSArray*)listItems updateListener:(id)listener recordTypeSelected:(NSString*)record parent:(id)parentCon{

        parent = parentCon;
        recordSelected = record;
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
    
    [self.tableView initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.title = NSLocalizedString(@"RECORD_TYPE_AVAILABLE", nil); //@"Record Type available";
    self.contentSizeForViewInPopover = CGSizeMake(300, 55*[listData count]);
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
    cell.textLabel.text = [[[listData objectAtIndex:indexPath.row] fields] objectForKey:@"name"];
    if ([cell.textLabel.text isEqualToString:recordSelected]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [cell.textLabel setTextColor:[UIColor colorWithRed:0.318 green:0.4 blue:0.569 alpha:1.0]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [updateListener mustUpdate:[NSString stringWithFormat:@"%d",indexPath.row]];
    [popover dismissPopoverAnimated:YES];
}

@end


@implementation RecordTypeListViewController


- (id)initWithframe:(CGRect)rect listItems:(NSArray*)listItem updateListener:(id)listen {
    
    parentCon = listen;
    UIView* view = [[[UIView alloc] init] autorelease];
    [view setBackgroundColor:[UIColor clearColor]];
    
    self.tableView = [[[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped] autorelease];
    self.tableView.backgroundView = view;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    listItems = listItem; 
    
    recordTypeSelected = @"";
    
    NSMutableArray* tmpArr = [[[NSMutableArray alloc] init] autorelease];
    for (Item* item in listItems) {
        if (![[item.fields objectForKey:@"name"] isEqualToString:@"Master"]) {
            [tmpArr addObject:item];
            if ([[item.fields objectForKey:@"defaultRecordTypeMapping"] isEqualToString:@"true"]) {
                recordTypeSelected = [item.fields objectForKey:@"name"];
                [(CustomDataGrid*)parentCon mustUpdate:[item.fields objectForKey:@"recordTypeId"]];
            }
   
        }
    }
    
    listItems = [[tmpArr copy] retain];
    
    return self;
}

- (void)show:(CGRect)rect parent:(UIView*)mainView{
    
}

-(void)mustUpdate:(NSString *)value{
    
    [(CustomDataGrid*)parentCon mustUpdate:[[[listItems objectAtIndex:[value intValue]] fields] objectForKey:@"recordTypeId"]];
    recordTypeSelected = [[[listItems objectAtIndex:[value intValue]] fields] objectForKey:@"name"];
    [self.tableView reloadData];
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

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = recordTypeSelected;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        
    RecordTypeList *popup = [[RecordTypeList alloc] initWithframe:self.view.frame listItems:listItems updateListener:self recordTypeSelected:recordTypeSelected parent:parentCon];
    [popup show:[self.tableView cellForRowAtIndexPath:indexPath].frame parent:self.tableView];

}

@end
