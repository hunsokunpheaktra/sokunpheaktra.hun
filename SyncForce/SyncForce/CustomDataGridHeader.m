//
//  CustomDataGridHeader.m
//  Datagrid
//
//  Created by Gaeasys on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomDataGridHeader.h"
#import "CustomDataGrid.h"


@implementation CustomDataGridHeader

@synthesize headerTable,columnNames,columnTypes,target,isGridEditAble,listSize, isPortrait;

-(id)initWithPopulate:(CGRect)frame listSize:(NSArray*)alistSize withColunmnames:(NSArray*)pcolumnNames colType:(NSArray*)types bntTarget:(id)bntTarget isAction:(BOOL) isAction{
    
    self = [super init];
    self.view.frame = frame;
	columnNames = pcolumnNames;
    target = bntTarget;
    isGridEditAble = NO;
    listSize = alistSize;
    columnTypes = types;
    
    return self;
}


- (void)dealloc
{
    [headerTable release];
    [columnNames release];
    [columnTypes release];
    [super dealloc];
}



#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    headerTable = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50) style:UITableViewStylePlain] autorelease];
    
    headerTable.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    headerTable.allowsSelection = NO;
    headerTable.scrollEnabled = NO;
    headerTable.delegate = self;
    headerTable.dataSource = self;
    
    [self.view addSubview:headerTable];
    
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableArray *dataRowItems = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    float colWidth;
    
    //Calcualte width of column
    if(!isGridEditAble){
        if (isPortrait) {
            if ([columnNames count]>5) {
                colWidth =  ((tableView.frame.size.width - 90) /([columnNames count] - 2))-10;
            }else colWidth =  ((tableView.frame.size.width - 90) /([columnNames count] - 1))-10;
        
        }else colWidth =  ((tableView.frame.size.width - 90) /([columnNames count] -1) )-10;
    }else {
        if (isPortrait) {
            if ([columnNames count]>5)
                colWidth =  ((tableView.frame.size.width) /([columnNames count] - 2))-30;
            else colWidth =  ((tableView.frame.size.width) /([columnNames count] - 1))-30;
        }else colWidth =  ((tableView.frame.size.width) /([columnNames count] - 1))-30;
    
    }
    
    static NSString *customCellIdentifier = @"customCell";
	CustomDataGridRow *cell = nil;
    
	cell = (CustomDataGridRow *)[tableView dequeueReusableCellWithIdentifier:customCellIdentifier];
    
	if (cell == nil) {
		cell = [[[CustomDataGridRow alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:customCellIdentifier itemPadding:10 scaleToFill:YES] autorelease];
    }

    cell.contentView.backgroundColor = [UIColor colorWithRed:(42.0/255.0) green:(192.0/255.0) blue:(235.0/255.0) alpha:1];
    
    for (int i=0; i<[columnNames count]; i++) {
      if (i == 4 && isPortrait && [columnNames count]>5) NSLog(@"Hide the last column");
      else {    
          NSString* colName = [columnNames objectAtIndex:i];
          if (!isGridEditAble) {
             if (colName == @"Id") {
                 colName = @"Action";
                 CustomDataGridRowItem *rowItem = [[[CustomDataGridRowItem alloc] initWithRowItemType:YES columnType:0 entityName:nil fieldName:nil baseSize:CGSizeMake(90, 39) controlLabel:colName listener:nil gridItem:nil buttonTarget:nil tag:indexPath.row navigateListener:nil isView:YES] autorelease];
                
                 [dataRowItems addObject:rowItem];
                
             }else {
                
                 CustomDataGridRowItem *rowItem = [[[CustomDataGridRowItem alloc] initWithRowItemType:YES columnType:[[columnTypes objectAtIndex:i] intValue] entityName:nil fieldName:nil baseSize:CGSizeMake(colWidth, 39) controlLabel:colName listener:nil gridItem:nil buttonTarget:target tag:indexPath.row navigateListener:nil isView:YES] autorelease];
                
                 [dataRowItems addObject:rowItem];
             }

          }else {
             if (colName != @"Id") {
                 int type = 0;
                 if ([[columnTypes objectAtIndex:i] intValue] == 5) type = 5;
                 else if ([[columnTypes objectAtIndex:i] intValue] == 10) type = 10;
                 else if ([[columnTypes objectAtIndex:i] intValue] == 9) type = 9;
                 else if ([[columnTypes objectAtIndex:i] intValue] == 7) type = 7;
                 else if ([[columnTypes objectAtIndex:i] intValue] == 6) type = 6;
                 
                 CustomDataGridRowItem *rowItem = [[[CustomDataGridRowItem alloc] initWithRowItemType:YES columnType:type entityName:nil fieldName:nil baseSize:CGSizeMake(colWidth, 39) controlLabel:colName listener:nil gridItem:nil buttonTarget:target tag:indexPath.row navigateListener:nil isView:NO] autorelease];
                
                 [dataRowItems addObject:rowItem];
             }
          }
       } 
    }
    
    cell.rowItems = dataRowItems;
    
    return cell;    
}



@end
