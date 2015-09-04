//
//  DateTimeAndReferenceChooser.m
//  SyncForce
//
//  Created by Gaeasys on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DateTimeAndReferenceChooser.h"
#import "DatetimeHelper.h"
#import "CustomDataGrid.h"
#import <QuartzCore/QuartzCore.h>


@interface GridCellFrame : UITableViewCell
@end

@implementation GridCellFrame

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentView.layer.cornerRadius = 5;
    self.contentView.layer.borderWidth = 1;
    self.contentView.layer.borderColor = [[UIColor grayColor] CGColor];
    
    CGRect frame =  self.contentView.frame;
    frame.size.width = frame.size.width + 20;
    self.contentView.frame = frame;
    self.contentView.backgroundColor = [UIColor whiteColor];
    
}
@end


@interface ReferenceTypePopup : UIViewController <UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>{
    
    UIPopoverController *popover;
    UITableView* tableData;
    NSString*datetime;
    NSArray *listData;
    NSString *type;
    UIDatePicker *datePicker;
    NSArray  *listItemsBackUp;
    NSObject<UpdateListener> *updateListener;
    BOOL isBeingSearch;
    
}
- (id)initWithListData:(NSArray*)listItems itemSelect:(NSString*)item type:(NSString*)atype updateListener:(NSObject<UpdateListener>*)listener;
- (id)initWithDate:(NSString*)date type:(NSString*)type updateListener:(NSObject<UpdateListener>*)lister;
- (void)show:(CGRect)rect parent:(UIView*)mainView;
@end

@implementation ReferenceTypePopup

- (id)initWithListData:(NSArray*)listItems itemSelect:(NSString*)item type:(NSString*)atype updateListener:(NSObject<UpdateListener>*)listener{

   
    type= atype;
    listData = listItems;
    listItemsBackUp = listItems;
    datetime = item;
    updateListener = listener;
    isBeingSearch = NO;
    
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 300, self.view.frame.size.height);
    
    CGRect rect = self.view.frame;
    rect.origin.x =0;
    rect.origin.y = [listData count]>10 ? 50:0;
    rect.size.height = rect.size.height - rect.origin.y;
    tableData = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    tableData.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    tableData.delegate = self;
    tableData.dataSource = self;
    
    if([listData count]> 10){
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
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
    
    [self.view addSubview:tableData];

    
    return self;
}

- (id)initWithDate:(NSString*)date type:(NSString*)atype updateListener:(NSObject<UpdateListener>*)listener{
    datetime = date;
    type = atype;
    updateListener = listener;
    return self;
}

- (void)show:(CGRect)rect parent:(UIView*)mainView{
    
    if(popover.popoverVisible){
        [popover release];
        [self release];
        return;
    }
    if ([type isEqualToString:@"reference"] || [type isEqualToString:@"picklist"]) {
    
        self.contentSizeForViewInPopover = CGSizeMake(300, (tableData.rowHeight*[listData count])+20);
        popover = [[UIPopoverController alloc] initWithContentViewController:self];
        [popover presentPopoverFromRect:rect inView:mainView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

    } else {
        
        tableData.separatorColor = [UIColor clearColor]; 
        tableData.scrollEnabled = NO;
        datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 400, 180)];
        NSDate *date;
  
        if ([type isEqualToString:@"dateTime"]) {
            [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
            date = [DatetimeHelper stringToDateTime:[datetime isEqualToString:@""] || datetime == nil ?[DatetimeHelper serverDate:[NSDate date]]:datetime];        }    
        else { 
            [datePicker setDatePickerMode:UIDatePickerModeDate];
            date = [DatetimeHelper stringToDate:[datetime isEqualToString:@""] || datetime == nil ?[DatetimeHelper serverDate:[NSDate date]]:datetime];
        }
        

        [datePicker setDate:date animated:NO];
        [self.view addSubview:datePicker];
        [datePicker release];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", Nil) style:UIBarButtonItemStyleDone target:self action:@selector(done)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CLEAR", Nil) style:UIBarButtonItemStyleDone target:self action:@selector(clear)];

      
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self];
        self.contentSizeForViewInPopover = datePicker.frame.size;
        popover = [[UIPopoverController alloc] initWithContentViewController:nav];
        [nav release];
    
        [popover presentPopoverFromRect:rect inView:mainView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }    
    
}

- (void)done{
    [popover dismissPopoverAnimated:YES];     
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if ([type isEqualToString:@"dateTime"]) [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.'000Z'"];
    else  [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strDate = [dateFormatter stringFromDate:datePicker.date];
    [dateFormatter release];
    
    [updateListener mustUpdate:strDate];
   
}

- (void)clear{
    [popover dismissPopoverAnimated:YES];
    [updateListener mustUpdate:@""];
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
    
    if ([type isEqualToString:@"reference"]) {
         cell.textLabel.text = [[[listData objectAtIndex:indexPath.row] fields] objectForKey:@"Name"];
    }else  cell.textLabel.text = [[[listData objectAtIndex:indexPath.row] fields] objectForKey:@"label"];
       
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    [cell.textLabel setTextColor:[UIColor darkTextColor]];
    
    if([cell.textLabel.text isEqualToString:datetime]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [cell.textLabel setTextColor:[UIColor colorWithRed:0.318 green:0.4 blue:0.569 alpha:1.0]];
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    int index = 0;
    if (isBeingSearch){
        for (Item* item in listItemsBackUp) {
            if ([[item.fields objectForKey:@"Id"] isEqualToString:[[[listData objectAtIndex:indexPath.row] fields] objectForKey:@"Id"]])
                break;
            
            index++;
        }
    }else index = indexPath.row;
    
    [updateListener mustUpdate:[NSString stringWithFormat:@"%d",index]];
    [popover dismissPopoverAnimated:YES];
}

#pragma mark UISearchBarDelegate 

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    isBeingSearch = YES;
    listData = listItemsBackUp;
    NSMutableArray* tmpListItems = [[[NSMutableArray alloc] init] autorelease];
    
    NSString* subOrName = @"";
    
    if (searchText.length > 0) { 
        for (Item *item in listData) {
            
            if ([item.entity isEqualToString:@"Case"] ||
                [item.entity isEqualToString:@"Task"] ||
                [item.entity isEqualToString:@"Event"]
                ) {
                subOrName = @"Subject";
            }
            else if ([item.entity isEqualToString:@"Contract"]) subOrName = @"ContractNumber";
            else subOrName = @"Name";
            
            
            NSString *values = [type isEqualToString:@"reference"]?[item.fields objectForKey:subOrName]:[item.fields objectForKey:@"value"];
            if(values.length > 0) { 
                if ([values rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    [tmpListItems addObject:item];
                }
            }
        }
    }else tmpListItems = [listItemsBackUp copy];
    
    listData = [tmpListItems copy];
    [tableData reloadData];
    
}


@end


@implementation DateTimeAndReferenceChooser

@synthesize itemSelect,tag;

- (id)initWithHeader:(NSString*)atype indexRowCol:(NSArray*)arrayIndex selectValue:(NSString*)value arrItems:(NSArray*)items frame:(CGRect)rect updateListener:(NSObject<UpdateListener>*)newListener{
    
    itemSelect = value;
    listItems = [items copy];
    
    type = atype;
    indexRowCol = arrayIndex;
    
    self.tableView = [[[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorColor = [UIColor clearColor];
    
    UIView *background = [[UIView alloc] initWithFrame:self.tableView.backgroundView.frame];
    background.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = background;
    [background release];
    
    listener = newListener;
    return self;
}

- (void)show:(CGRect)rect parent:(UIView*)mainView{
    
}

-(void)mustUpdate:(NSString *)value{
    if (![type isEqualToString:@"reference"] && ![type isEqualToString:@"picklist"]) {
        itemSelect = [value copy]; 
        [(CustomDataGrid*)listener datetimeAndReferenceChanged:indexRowCol value:itemSelect];
    } else {
        if([type isEqualToString:@"reference"]) {
            itemSelect = [[[listItems objectAtIndex:[value intValue]] fields] objectForKey:@"Name"];
            [(CustomDataGrid*)listener datetimeAndReferenceChanged:indexRowCol value:[[[listItems objectAtIndex:[value intValue]] fields] objectForKey:@"Id"]];
        }else {
            itemSelect = [[[listItems objectAtIndex:[value intValue]] fields] objectForKey:@"label"];
            [(CustomDataGrid*)listener datetimeAndReferenceChanged:indexRowCol value:[[[listItems objectAtIndex:[value intValue]] fields] objectForKey:@"label"]];
        }    
    }   
    
    [self.tableView reloadData];
}

-(void)didUpdate:(Item *)newItem{
    
}

-(void)updateFieldDisplay:(NSString *)newValue index:(int)index{
    
}

-(void)dealloc{
    [super dealloc];
    //[listItems release];
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

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 34;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    GridCellFrame *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[GridCellFrame alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
   if ([type isEqualToString:@"dateTime"] || [type isEqualToString:@"date"]) 
        cell.textLabel.text = [DatetimeHelper display:itemSelect];    
   else cell.textLabel.text = itemSelect;    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![type isEqualToString:@"reference"] && ![type isEqualToString:@"picklist"]) {
        ReferenceTypePopup *popup = [[ReferenceTypePopup alloc] initWithDate:itemSelect type:type updateListener:self];
        [popup show:[self.tableView cellForRowAtIndexPath:indexPath].frame parent:self.tableView];

    }else{
        
       // if ([listItems count] >0) {
            ReferenceTypePopup *popup = [[ReferenceTypePopup alloc] initWithListData:listItems itemSelect:itemSelect type:type updateListener:self];
            [popup show:[self.tableView cellForRowAtIndexPath:indexPath].frame parent:self.tableView];
       // }  
    }
}

@end
