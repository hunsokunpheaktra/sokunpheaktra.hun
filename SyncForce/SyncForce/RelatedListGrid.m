//
//  RelatedListGrid.m
//  SyncForce
//
//  Created by Gaeasys on 11/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomDataGrid.h"
#import "CustomDataGridHeader.h"
#import "CustomDataGridPaging.h"
#import "EntityManager.h"
#import "GridItem.h"
#import "Item.h"
#import "Entity.h"
#import "EditViewController.h"
#import "ObjectDetailViewController.h"
#import "RelatedListGrid.h"
#import "Datagrid.h"


@implementation RelatedListGrid

@synthesize listener,dataTable,columnNames,datas,header,paging,tFooter,tHeader,searchBar,colSort, dataModel,isGridEdit,buttonCancelSave,buttonAddEdit,dataFirstLoad,isMassAdd,isNotAdd,isRequireAction,listSize;

@synthesize sortChange,j,dataView,cnt1,cnt2;

-(id)initWithPopulate:(NSObject<DataModel> *) adataModel listener:(NSObject<DatagridListener> *) alistener requireAction:(BOOL)requireAction{
    
    
    [super init];
    self.dataModel = adataModel;
    [self.dataModel populate];
    listener = alistener;
    
    columnNames = [[NSArray alloc] initWithObjects: [dataModel getColumnName:0],[dataModel getColumnName:1],[dataModel getColumnName:2],[dataModel getColumnName:3],[dataModel getColumnName:4] ,nil] ;
    
    
    datas = [[NSMutableArray alloc] init];
    
    
    if ([dataModel getRowCount]<ROW_NUMBER) {
        dataView = [dataModel getRowCount];
    }else {
        dataView = ROW_NUMBER;
    }
    
    dataFirstLoad = [[NSMutableDictionary alloc] init];
    isGridEdit = NO;
    isMassAdd  = NO;
    isNotAdd   = NO;
    isRequireAction = requireAction;
    cnt1 = ROW_NUMBER;
    cnt2 = 0;
    j = 0;
    
    sortChange = 1;
    
    return self;
}

- (void)navigate:(int)row parentController:(UIViewController*)parent accountId:(NSString*)accId{
    
    Item *item = [[Item alloc] init];
    item.entity = [dataModel getEntityName];
    item.fields = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    for(int i=0;i<[dataModel getColumnCount];i++){
        
        [item.fields setValue:[dataModel getValueAt:row columnIndex:i] forKey:[dataModel getColumnName:i]];
        
    }
    
    ObjectDetailViewController *editView = [[ObjectDetailViewController alloc] init:item mode:[Datagrid getEditImg] objectId:accId];
    
    
    [self.navigationController pushViewController:editView animated:YES];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [self.dataModel populate];
    [self.dataTable reloadData];
}

- (void)dealloc
{
    [header release];
    [datas release];
    [columnNames release];
    [dataTable release];
    [super dealloc];
}


#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    
    self.navigationController.navigationBar.hidden = NO;
    
    UIView *mainscreen = [[UIView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    [mainscreen setBackgroundColor:[UIColor darkGrayColor]];
    
    UIInterfaceOrientation mainOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    float tWidth,tHeight; 
    
    if (UIInterfaceOrientationIsPortrait(mainOrientation)){
        tWidth = 768;
        tHeight = 1024;
        
    }else{
        tWidth = 1024;
        tHeight = 768;
    }
    
    if (isRequireAction) {
        listSize = [[NSArray alloc] initWithObjects:@"70",@"150",@"100",@"80", [NSString stringWithFormat:@"%f",tWidth-420], nil];
    }else {
        listSize = [[NSArray alloc] initWithObjects:@"70",[NSString stringWithFormat:@"%f",tWidth-570],@"150",@"150",@"180", nil];
        
    }
    
    // create grid header
    tHeader = [[UIView alloc] initWithFrame:CGRectMake(0,0,mainscreen.frame.size.width, mainscreen.frame.size.height)];
    tHeader.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    buttonCancelSave = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, tWidth, 50)];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CANCEL", Nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancelEdit:)];
    cancel.width = 122;
    
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SAVE", Nil) style:UIBarButtonItemStyleBordered target:self action:@selector(saveEditColumn:)];
    save.width = 121;
    
    UIBarButtonItem *sep = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    [buttonCancelSave setItems:[NSArray arrayWithObjects:cancel,sep,save,nil]];
    buttonCancelSave.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [buttonCancelSave setHidden:YES];
    
    buttonAddEdit = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, tWidth, 50)];
    buttonAddEdit.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIBarButtonItem *addRow = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addRowRecord:)];
    addRow.style = UIBarButtonItemStyleBordered;
    addRow.width = 78;
    
    UIBarButtonItem *addForm = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ADD" , Nil) style:UIBarButtonItemStyleBordered target:self action:@selector(addFormRecord:)]; 
    addForm.width = 78;//(82, 0, 80, 50)
    
    UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"EDIT", Nil) style:UIBarButtonItemStyleBordered target:self action:@selector(editButtonClick:)];
    edit.width = 78;
    
    //[buttonAddEdit addSubview:addRow];
    
    // create search bar
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 1, tWidth - 240, 50)];
    //searchBar.tintColor = [UIColor colorWithWhite:10 alpha:1.0];
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchBar.showsCancelButton = NO;
    searchBar.delegate = self;
    
    UIBarButtonItem *barSearch = [[UIBarButtonItem alloc] initWithCustomView:searchBar];
    
    [buttonAddEdit setItems:[NSArray arrayWithObjects:addRow,barSearch,addForm,edit, nil]];
    
    
    
    header = [[CustomDataGridHeader alloc] initWithPopulate:CGRectMake(0,50,tWidth, mainscreen.frame.size.height) listSize:listSize withColunmnames:columnNames bntTarget:self isAction:isRequireAction];
    
    [tHeader addSubview:buttonAddEdit];
    [tHeader addSubview:buttonCancelSave];
    [tHeader addSubview:header.view];
    
    // create grid data
    dataTable = [[UITableView alloc] initWithFrame:CGRectMake(0,100,mainscreen.frame.size.width, mainscreen.frame.size.height - 150) style:UITableViewStylePlain];
    dataTable.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    dataTable.allowsSelection = NO;
    dataTable.delegate = self;
    dataTable.dataSource = self;
    
    // ceate grid paging
    tFooter = [[UIView alloc] initWithFrame:CGRectMake(0,tHeight-163,tWidth, 50)]; 
    [tFooter setBackgroundColor:[UIColor darkGrayColor]];
    
    paging = [[CustomDataGridPaging alloc] initWithPopulate:self];
    paging.view.frame = tFooter.bounds;
    paging.record.title = [NSString stringWithFormat:@"%d%@%d of %d", cnt2 + 1, @"-", cnt1,[dataModel getRowCount]] ;
    paging.bntPrev.enabled = NO;
    if ([dataModel getRowCount] < ROW_NUMBER) {
        paging.bntNext.enabled = NO;
    }
    
    
    
    [tFooter addSubview:paging.view];
    
    [mainscreen addSubview:tHeader];
    [mainscreen addSubview:self.dataTable];
    [mainscreen addSubview:tFooter];
    
    self.view = mainscreen;
    
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)addRowRecord:(id)sender {
    
    if (j==1) {
        [datas release];
        datas = [[NSMutableArray alloc] init];
    }
    
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    for (int i =0; i< [dataModel getColumnCount]; i++) {
        [data addObject:@""];
    }
    [datas addObject:data];
    
    j = 0;
    
    dataView = dataView + 1; 
    [dataTable reloadData];
    
}

- (void)addFormRecord:(id)sender {
    
    EditViewController *modelView = [[EditViewController alloc] init:[[Item alloc] init:[dataModel getEntityName] fields:nil] mode:@"add" objectId:nil];
    
    [self.navigationController pushViewController:modelView animated:YES];
    [modelView release];
    
    /*UIViewController *modelViewController = [[UIViewController alloc] init];
     CustomDataGridNewItem *modelView = [[CustomDataGridNewItem alloc] initWithObjectName:[dataModel getEntityName] target:self];
     
     modelViewController.view = modelView.view;
     
     modelViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
     modelViewController.modalPresentationStyle = UIModalPresentationFormSheet;
     
     [self.navigationController pushViewController:modelViewController animated:YES];
     
     [self presentModalViewController:modelViewController animated:YES];
     
     modelViewController.view.superview.frame = CGRectMake(50, 50, 680, 950);
     modelViewController.view.superview.center = self.view.center;*/
    
}

- (void)editButtonClick:(id) sender {
    
    isNotAdd = YES;
    header.isGridEditAble = YES;
    [buttonAddEdit setHidden:YES];
    [buttonCancelSave setFrame:CGRectMake(0, 0,dataTable.frame.size.width, 50)]; 
    [buttonCancelSave setHidden:NO];
    searchBar.hidden = YES;
    
    [header.headerTable reloadData];
    j=0;
    isNotAdd = YES;
    datas = nil;
    [dataTable reloadData];
    
}

-(void)cancelEdit:(id) sender {
    isMassAdd = NO;
    isNotAdd = NO;
    [datas release];
    datas = [[NSMutableArray alloc] init];
    
    
    //[(UIBarButtonItem*)sender becomeFirstResponder];
    [searchBar becomeFirstResponder];
    [buttonAddEdit setHidden:NO];
    [buttonCancelSave setHidden:YES];
    header.isGridEditAble = NO;
    searchBar.hidden = NO;
    
    isGridEdit = NO;
    [header.headerTable reloadData];
    [dataTable reloadData];
    
    if (datas != nil) {
        
        for (NSString *keyDic in [dataFirstLoad allKeys]) {
            NSArray *dataInRow = [dataFirstLoad objectForKey:keyDic];
            
            for (int i = 0; i< [dataModel getColumnCount] ; i++) {
                [dataModel setValueAt:[keyDic intValue] columnIndex:i oldValue:nil newValue:[dataInRow objectAtIndex:i]]; 
            }
        }
    }
    [searchBar resignFirstResponder];
}


-(void)editColumn:(id) sender {
    
    int rowIndex = [[[[sender layer] valueForKey:@"index"] objectAtIndex:0] intValue];
    int columnIndex = [[[[sender layer] valueForKey:@"index"] objectAtIndex:1] intValue];
    
    NSString *oldValue = [[dataFirstLoad objectForKey:[NSString stringWithFormat:@"%d", rowIndex]] objectAtIndex:columnIndex];
    NSString *newValue = [(UITextField *)sender text]; 
    
    [dataModel setValueAt:rowIndex columnIndex:columnIndex oldValue:oldValue newValue:newValue]; 
    
}

- (void)saveEditColumn:(id) sender {
    
    isMassAdd = NO;
    isNotAdd = NO;
    [datas release];
    datas = [[NSMutableArray alloc] init];
    
    [searchBar becomeFirstResponder];
    [buttonAddEdit setHidden:NO];
    [buttonCancelSave setHidden:YES];
    searchBar.hidden = NO;
    isGridEdit = NO;
    header.isGridEditAble = NO;
    [header.headerTable reloadData];
    [dataTable reloadData];
    [listener save];
    [searchBar resignFirstResponder];
    
}

- (void) saveColumn:(id)sender {
    
    int rowIndex = [[[[sender layer] valueForKey:@"index"] objectAtIndex:0] intValue];
    int colIndex = [[[[sender layer] valueForKey:@"index"] objectAtIndex:1] intValue];
    
    NSString *newValue = [(UITextField *)sender text];
    
    [[datas objectAtIndex:rowIndex] insertObject:newValue atIndex:colIndex];
    [[datas objectAtIndex:rowIndex] removeObjectAtIndex:colIndex+1];
    
    [listener textFieldChange:sender];
}

- (void) saveAddRecord:(id)sender {
    
    //[(UIButton*)sender becomeFirstResponder];
    [searchBar becomeFirstResponder];
    
    for (int i=0; i< [[datas objectAtIndex:[[[[sender layer] valueForKey:@"index"] objectAtIndex:0] intValue]] count] ; i++) {
        
        if ([[datas objectAtIndex:[[[[sender layer] valueForKey:@"index"] objectAtIndex:0] intValue]] objectAtIndex:i] != nil) {
            
            NSString* dataOfCol = [[datas objectAtIndex:[[[[sender layer] valueForKey:@"index"] objectAtIndex:0] intValue]] objectAtIndex:i]; 
            
            [listener massAddReload:[[[[sender layer] valueForKey:@"index"] objectAtIndex:0] intValue] columnIndex:i Value:dataOfCol];
            
        } 
    }
    
    [datas removeObjectAtIndex:[[[[sender layer] valueForKey:@"index"] objectAtIndex:0] intValue]];
    [listener massAddSave:sender];
    [dataTable reloadData];
    
}


-(void) cancelAddRecord:(id)sender {
    [datas removeObjectAtIndex:[[[[sender layer] valueForKey:@"index"] objectAtIndex:0] intValue]];
    dataView = dataView -1;
    [dataTable reloadData];
}

- (void) testAnimated :(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    // [[self dataTable] reloadData];
}

- (void)nextClick:(id)sender{
    isMassAdd = NO;
    isNotAdd = NO;
    [datas release];
    datas = [[NSMutableArray alloc] init];
    paging.bntPrev.enabled = YES;
    
    if([dataModel getRowCount]>cnt1){  
		cnt1=cnt1+ROW_NUMBER;
		cnt2=cnt2+ROW_NUMBER;
        
        if (cnt2 + ROW_NUMBER < [dataModel getRowCount]) {
            paging.record.title = [NSString stringWithFormat:@"%d%@%d of %d", cnt2 + 1, @"-", cnt1,[dataModel getRowCount]] ;
        }else{
            paging.record.title = [NSString stringWithFormat:@"%d%@%d of %d", cnt2 + 1, @"-", [dataModel getRowCount],[dataModel getRowCount]] ;
            paging.bntNext.enabled = NO;
        }
        
	}
	j=0;
    
    if (cnt2 + ROW_NUMBER < [dataModel getRowCount]) {
        dataView = ROW_NUMBER ;
    }else {
        dataView = [dataModel getRowCount] % ROW_NUMBER ;
    }
    
	[dataTable reloadData];
    
}


- (void)prevClick:(id)sender{
    
    isMassAdd = NO;
    isNotAdd = NO;
    [datas release];
    datas = [[NSMutableArray alloc] init];
    
    paging.bntNext.enabled = YES;
    
    if(cnt2 > ROW_NUMBER){
		cnt1=cnt1-ROW_NUMBER;
		cnt2=cnt2-ROW_NUMBER;
        
        paging.record.title = [NSString stringWithFormat:@"%d%@%d of %d", cnt2 + 1, @"-", cnt1,[dataModel getRowCount]] ;
        
        if (cnt2 == 0) {
            paging.bntPrev.enabled = NO;
        }
        
    }else {
        cnt1=cnt1-ROW_NUMBER;
		cnt2=cnt2-ROW_NUMBER;
        paging.record.title = [NSString stringWithFormat:@"%d%@%d of %d", cnt2 + 1, @"-", cnt1,[dataModel getRowCount]] ;
        paging.bntPrev.enabled = NO;
    }
	
	j=0;
    
    if (cnt2 + ROW_NUMBER < [dataModel getRowCount]) {
        dataView = ROW_NUMBER ;
    }else {
        dataView = [dataModel getRowCount] % ROW_NUMBER ;
    }
	[dataTable reloadData];
    
}

-(void)sortDatas:(id)sender {
    
    
    Boolean sort ;
    
    
    if ([colSort isEqualToString:[[sender layer] valueForKey:@"test"]] || colSort == nil) {
        
        if (sortChange == 1) {
            
            colSort = [[sender layer] valueForKey:@"test"];
            sort = YES;
            sortChange = 2;
            
        }else if (sortChange == 2){
            
            colSort = [[sender layer] valueForKey:@"test"];
            sort = NO;
            sortChange =0;
            
        }else {
            
            colSort = [[sender layer] valueForKey:@"test"];
            sortChange = 1;
            j = 0;
            [datas release];
            datas = [[NSMutableArray alloc] init];
            [dataTable reloadData];
            return;
        }
        
    } else {
        
        colSort = [[sender layer] valueForKey:@"test"];
        sort = YES;
        sortChange = 2;
        
    } 
    
    
    int cnt1Temp;
    
    if (cnt2 + ROW_NUMBER < [dataModel getRowCount]) {
        cnt1Temp = cnt1;
    }else {
        cnt1Temp = [dataModel getRowCount];
    }
    
    
    int nbCol;
    
    
    NSMutableArray *arraySort = [[NSMutableArray alloc] init];
    
    for (int k=cnt2; k<cnt1Temp; k++) {
        
        NSMutableArray *tmpData = [[NSMutableArray alloc] init];
        
        for (int col = 0; col < [dataModel getColumnCount]; col++) {
            
            NSString *columnName = [dataModel getColumnName:col];
            
            if ([[dataModel getValueAt:k columnIndex:col] length]>0) {
                [tmpData addObject:[dataModel getValueAt:k columnIndex:col]];
                
            }else {
                [tmpData addObject:@""];
            }
            
            if ([colSort isEqualToString:columnName]) {
                nbCol = col;
            }
            
        }
        
        
        if ([dataModel getValueAt:k columnIndex:nbCol] != NULL) {
            
            NSDictionary *tData = [NSDictionary dictionaryWithObjectsAndKeys:[dataModel getValueAt:k columnIndex:nbCol],@"colName",tmpData,@"itemSort", nil];
            
            [arraySort addObject:tData];
            
        } else {
            
            NSDictionary *tData = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"colName",tmpData,@"itemSort", nil];
            
            [arraySort addObject:tData];
        }
        
    }
    
    
    NSSortDescriptor *descriptor =[[[NSSortDescriptor alloc] initWithKey:@"colName" ascending:sort selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
    
    NSArray *descriptors = [NSArray arrayWithObjects:descriptor, nil];
    
    NSArray *sortedArray = [arraySort sortedArrayUsingDescriptors:descriptors];
    NSMutableArray *sortedItem = [[NSMutableArray alloc] init]; 
    
    for (NSDictionary *d in sortedArray) {
        
        if ([d objectForKey:@"itemSort"] != nil) {
            
            [sortedItem addObject:[d objectForKey:@"itemSort"]];
            
        } 
    }
    
    datas = sortedItem;
    dataView = [datas count];
    j = 1;
    [dataTable reloadData];
    
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Table view data source

/*-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
 
 NSArray *tempArray = [[NSArray alloc] initWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
 
 
 return tempArray;
 }
 
 -(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
 
 return index;
 }*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{   
    
	return dataView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableArray *arrayDataRow = [[NSMutableArray alloc] init];
    
    //  float colWidth = (dataTable.frame.size.width /[columnNames count]);
    
    float colWidth ;
    
    int rowIdex;
    
    static NSString *customCellIdentifier = @"customCell";
	CustomDataGridRow *cell = nil;
    
	cell = (CustomDataGridRow *)[tableView dequeueReusableCellWithIdentifier:customCellIdentifier];
	if (cell == nil)
    {
		cell = [[[CustomDataGridRow alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:customCellIdentifier itemPadding:3 scaleToFill:YES] autorelease];
    }
    
    
    // alternative color 
    
    UIColor *rowColor;
    
    if ((indexPath.row % 2) == 0) {
        
        [cell.contentView setBackgroundColor:[UIColor whiteColor]];
        rowColor = [UIColor whiteColor];
        
        
    } else {
        
        [cell.contentView setBackgroundColor:[UIColor colorWithRed:0.1 green:0.3 blue:0.5 alpha:0.5]];
        rowColor = [UIColor clearColor];
        
    }
    
    
    // row's items
    
    NSMutableArray *dataRowItems = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    
    
    for (int i=0; i<[dataModel getColumnCount]; i++) {
        
        colWidth = [[listSize objectAtIndex:i] floatValue];
        
        NSString* colName = [dataModel getColumnName:i];
        NSString* datastring;
        
        // display 50 records
        if(j==0){
            
            if(cnt1==ROW_NUMBER){
                
                if ((dataView - indexPath.row) > (dataView - [datas count])) {
                    
                    isGridEdit = YES;
                    isMassAdd = YES;
                    rowIdex = indexPath.row;
                    datastring = [[datas objectAtIndex: indexPath.row] objectAtIndex:i];
                    
                } else {
                    
                    isMassAdd = NO;
                    isGridEdit = NO;
                    if (isNotAdd) {
                        isGridEdit = YES;
                    }
                    rowIdex = indexPath.row - [datas count];
                    
                    datastring =[dataModel getValueAt:indexPath.row - [datas count] columnIndex:i] ;
                    
                    
                    if (datastring != nil) {
                        [arrayDataRow addObject:datastring];
                    }else [arrayDataRow addObject:@""];
                    
                    
                }
            }
            
            if(cnt1>ROW_NUMBER){
                
                if ((dataView - indexPath.row) > (dataView - [datas count])) {
                    
                    isGridEdit = YES;
                    isMassAdd = YES;
                    rowIdex = indexPath.row;
                    datastring = [[datas objectAtIndex: indexPath.row] objectAtIndex:i];
                    
                } else {
                    
                    if ((indexPath.row + cnt2)<[dataModel getRowCount] + [datas count]) {    
                        
                        isMassAdd = NO;
                        isGridEdit = NO;
                        if (isNotAdd) {
                            isGridEdit = YES;
                        }
                        
                        rowIdex = indexPath.row + cnt2 - [datas count]; 
                        
                        datastring = [dataModel getValueAt:indexPath.row + cnt2 - [datas count] columnIndex:i] ;
                        
                        
                        if (datastring != nil) {
                            [arrayDataRow addObject:datastring];
                        } else [arrayDataRow addObject:@""];
                        
                    }
                    
                }   
            }
            
        }  
        
        else {
            
            datastring = [[datas objectAtIndex: indexPath.row] objectAtIndex:i];
        }
        
        
        if (!isGridEdit) {
            
            if (colName == @"Id") {
                
                if (isRequireAction) {                      
                    
                    //colWidth = ((dataTable.frame.size.width - 70)/([columnNames count]-1));
                    
                    GridItem* item = [[GridItem alloc]init];
                    [item setObjectName:[dataModel getEntityName]];
                    [item setEntityId:datastring];
                    [item setClickReason:@"button_lupe_29x30"];
                    
                    CustomDataGridRowItem *rowItem = [[[CustomDataGridRowItem alloc] initWithRowItemType:YES columnType:0 isHeader:NO rowColor:rowColor baseSize:CGSizeMake(70, 54) normalImage:nil selectedImage:nil controlLabel:datastring listener:listener gridItem:item buttonTarget:nil buttonAction:nil tag:indexPath.row navigateListener:self] autorelease];
                    
                    
                    [dataRowItems addObject:rowItem];
                    
                    
                    
                    
                } else {
                    
                    //   colWidth = ((dataTable.frame.size.width - 70)/([columnNames count]-1));
                    
                    CustomDataGridRowItem *rowItem = [[[CustomDataGridRowItem alloc] initWithRowItemType:YES columnType:0 isHeader:YES rowColor:rowColor baseSize:CGSizeMake(70, 54) normalImage:nil selectedImage:nil controlLabel:nil listener:nil gridItem:nil buttonTarget:nil buttonAction:nil tag:indexPath.row navigateListener:self] autorelease];
                    
                    
                    [dataRowItems addObject:rowItem];                 
                }   
                
                
            } else {
                
                CustomDataGridRowItem *rowItem = [[[CustomDataGridRowItem alloc] initWithRowItemType:NO columnType:[dataModel getColumType:i] isHeader:NO rowColor:rowColor baseSize:CGSizeMake(colWidth, 54) normalImage:nil selectedImage:nil controlLabel:datastring listener:nil gridItem:nil buttonTarget:nil buttonAction:nil tag:indexPath.row navigateListener:self] autorelease];
                
                [dataRowItems addObject:rowItem];
            }
            
            
        } else {
            
            if (!isMassAdd) {
                
                // float colWidth = (dataTable.frame.size.width /([columnNames count] -1));
                
                if (colName != @"Id") {
                    
                    CustomDataGridRowItem *rowItem = [[[CustomDataGridRowItem alloc] initWithColumnType:[dataModel getColumType:i] isMassAdd:NO itemTypeButton:NO rowIndex:rowIdex columnIndex:i rowColor:rowColor baseSize:CGSizeMake(colWidth+2+ 70/4, 54) normalImage:nil selectedImage:nil controlLabel:datastring buttonTarget:self buttonAction:nil] autorelease];
                    
                    [dataRowItems addObject:rowItem];
                }
                
                [dataFirstLoad setObject:arrayDataRow forKey:[NSString stringWithFormat:@"%d",rowIdex]];
                
            } else {
                
                if (colName == @"Id") {
                    
                    
                    // colWidth = ((dataTable.frame.size.width - 70)/([columnNames count]-1));
                    
                    
                    
                    CustomDataGridRowItem *rowItem = [[[CustomDataGridRowItem alloc] initWithColumnType:[dataModel getColumType:i] isMassAdd:isMassAdd itemTypeButton:YES rowIndex:rowIdex columnIndex:i rowColor:rowColor baseSize:CGSizeMake(70, 54) normalImage:nil selectedImage:nil controlLabel:nil buttonTarget:self buttonAction:nil ] autorelease];                        
                    [dataRowItems addObject:rowItem];
                    
                    
                } else {
                    
                    CustomDataGridRowItem *rowItem = [[[CustomDataGridRowItem alloc] initWithColumnType:[dataModel getColumType:i] isMassAdd:isMassAdd itemTypeButton:NO rowIndex:rowIdex columnIndex:i rowColor:rowColor baseSize:CGSizeMake(colWidth , 54) normalImage:nil selectedImage:nil controlLabel:datastring buttonTarget:self buttonAction:nil] autorelease];
                    
                    [dataRowItems addObject:rowItem];
                }
                
                
                
            }
            
        }
        
    }
    
    cell.rowItems = dataRowItems;
    
    return cell;
}




#pragma mark UISearchBarDelegate 

-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    
}

-(void) searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
}

-(void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
}

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    isMassAdd = NO;
    
    NSMutableArray *searchResult = [[NSMutableArray alloc] init];
    
    int cnt1Temp;
    
    if (cnt2 + ROW_NUMBER < [dataModel getRowCount]) {
        cnt1Temp = cnt1;
    }else {
        cnt1Temp = [dataModel getRowCount];
    }
    
    for (int i = cnt2; i<cnt1Temp; i++) {
        
        NSMutableArray *tmpData = [[NSMutableArray alloc] init]; 
        
        for (int k = 0; k<[dataModel getColumnCount]; k++) {
            
            if ([dataModel getColumnName:k] == @"Id") {
                
                NSString *tmpString = [dataModel getValueAt:i columnIndex:k];
                [tmpData addObject:tmpString];
                
            } else {  
                
                NSString *tmpString = [dataModel getValueAt:i columnIndex:k];
                
                if ([tmpString length]>0) {
                    
                    [tmpData addObject:tmpString];
                    
                } else {
                    [tmpData addObject:@""];
                }
                
                
                if ( [searchText length]>0) {
                    
                    if([tmpString length]>0) { 
                        
                        if ([tmpString rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                            
                            [searchResult removeObject:tmpData];
                            [searchResult addObject:tmpData];
                            
                        }
                        
                    }
                    
                }  else {
                    
                    [searchResult removeObject:tmpData];
                    [searchResult addObject:tmpData];
                    
                } 
                
            }
            
        }
        
    }
    
    datas = searchResult;
    dataView = [datas count];
    j = 1;
    [dataTable reloadData];
    
    
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}



-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    UIInterfaceOrientation orient = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (UIInterfaceOrientationIsPortrait(orient)){
        
        if (isRequireAction) {
            listSize = [[NSArray alloc] initWithObjects:@"70",@"150",@"100",@"80",@"348", nil];
        }else {
            listSize = [[NSArray alloc] initWithObjects:@"70",@"198",@"150",@"150", @"180", nil];
            
        }
        searchBar.frame = CGRectMake(270, 0, 768 - 270, 50); // CGRectMake(246, 0, tWidth - 246, 50)  
        header.headerTable.frame = CGRectMake(0, 0, 768, 50);
        header.listSize = listSize;
        tFooter.frame = CGRectMake(0,860,768, 50);
        
        [header.headerTable reloadData];
        [dataTable reloadData];
        
        
    }else{
        
        if (isRequireAction) {
            listSize = [[NSArray alloc] initWithObjects:@"70",@"130",@"100",@"80", @"564", nil];;
        }else {
            listSize = [[NSArray alloc] initWithObjects:@"70",@"405",@"200",@"150", @"180", nil];
            
        }
        
        
        searchBar.frame = CGRectMake(270, 0, 1024 - 270 , 50);
        header.headerTable.frame = CGRectMake(0, 0, 1024, 50); 
        header.listSize = listSize;
        tFooter.frame = CGRectMake(0,604,1024, 50);
        
        [header.headerTable reloadData];
        [dataTable reloadData];
        
    }
    
}


@end
