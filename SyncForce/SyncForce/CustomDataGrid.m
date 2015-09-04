//
//  CustomDataGrid.m
//  Datagrid
//
//  Created by Gaeasys on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomDataGrid.h"
#import "Item.h"
#import "ObjectDetailViewController.h"
#import "FieldsDisplayViewController.h"
#import "ValuesCriteria.h"
#import "AddEditViewController.h"
#import "RelatedListsInfoManager.h"
#import "RecordTypeMappingInfoManager.h"


@implementation CustomDataGrid

@synthesize listener,dataModel,dataTable,searchBar,toolbarAddEdit,toolbarPaging;
@synthesize parentController,parentType,childType,parentId;

-(id)initWithPopulate:(NSObject<DataModel> *) adataModel listener:(NSObject<DatagridListener> *)alistener rowNumber:(int)nbRow{
    
    self = [super init];
    
    self.dataModel = adataModel;
    [self.dataModel populate];
    listener = alistener;
    default_row_number = nbRow;
    
    dataFirstLoad = [[NSMutableDictionary alloc] init];
    datas = [[NSMutableArray alloc] init];
    
    number_of_row   = ([dataModel getRowCount]<default_row_number)?[dataModel getRowCount]:default_row_number;
    end_index       = default_row_number;
    start_index     = 0;
    sort_order      = 1;
    
    isFollowDataModelRowOrder = YES;
    isGridEdit = NO;
    
    [self initView];
    
    return self;
}


- (void)updateFieldDisplay:(NSString*)newValue index:(int)index{
}

-(void)didUpdate:(Item *)newItem{
    if(parentController)      
        [parentController reloadRelatedList] ;  
    [self initWithPopulate:dataModel listener:listener rowNumber:default_row_number];
    [self.dataTable reloadData];
}

- (void)navigate:(int)row parentController:(UIViewController*)parent accountId:(NSString*)accId{
    
    Item *item = [[Item alloc] init];
    item.entity = [dataModel getEntityName];
    item.fields = [[NSMutableDictionary alloc] initWithCapacity:1];

    NSString* tmpId ;
    if ([datas count] < 1) {    
        tmpId = accId;
        for(int i=0;i<[dataModel getColumnCount];i++){
            [item.fields setValue:[dataModel getValueAt:row columnIndex:i] forKey:[dataModel getColumnName:i]];
        }
    } else {
        tmpId = [[datas objectAtIndex:row] lastObject];
        for(int i=0;i<[dataModel getColumnCount];i++){
            [item.fields setValue:[[datas objectAtIndex:row] objectAtIndex:i] forKey:[dataModel getColumnName:i]];
        }
    }
    
    
    detailView = [[ObjectDetailViewController alloc] init:item mode:@"Edit" objectId:tmpId];
    detailView.start_number = start_index;
    detailView.selectedRowNumber = row;
    detailView.parentType = parentType;
    detailView.parentId = parentId;
    detailView.childType = childType;
    detailView.parentClass = self;
    
    if(parentController){
        [parentController.navigationController pushViewController:detailView animated:YES];
    }else{
        [self.navigationController pushViewController:detailView animated:YES];
    }
    [detailView release];
    
}

- (void)dealloc
{
    [super dealloc];
    [listener release];
    [dataModel release];
    [dataTable release];
    [datas release];
    [dataFirstLoad release];
    [detailView release];
}



#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)initView
{
    
    self.navigationController.navigationBar.hidden = NO;
    
    UIView *mainscreen = [[UIView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    [mainscreen setBackgroundColor:[UIColor darkGrayColor]];
    
    UIInterfaceOrientation mainOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    float tWidth,tHeight; 
    
    if (UIInterfaceOrientationIsPortrait(mainOrientation)){
        tWidth = 768;
        tHeight = 1024;
        isPortrait = YES;
    }else{
        tWidth = 1024;
        tHeight = 768;
        isPortrait = NO;
    }
    
    
    // create grid
    dataTable = [[UITableView alloc] initWithFrame:CGRectMake(0,50,mainscreen.frame.size.width, mainscreen.frame.size.height - 100) style:UITableViewStylePlain];
    dataTable.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    dataTable.allowsSelection = NO;
    dataTable.delegate = self;
    dataTable.dataSource = self;
    
    UIImageView *background = [[UIImageView alloc] initWithFrame:dataTable.backgroundView.frame];
    background.image = [UIImage imageNamed:@"gridGradient.png"];
    background.contentMode = UIViewContentModeScaleToFill;
    dataTable.backgroundView = background;
    [background release];
    
    // create save/cancel toolbar
    toolbarCancelSave = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, dataTable.frame.size.width, 50)] autorelease];
    toolbarCancelSave.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    // cancel button
    UIBarButtonItem *cancel = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CANCEL", Nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancelEdit:)] autorelease];
    cancel.width = 122;
    
    // save button
    UIBarButtonItem *save = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SAVE", Nil) style:UIBarButtonItemStyleBordered target:self action:@selector(saveEditColumn:)] autorelease];
    save.width = 121;
    
    // separator space
    UIBarButtonItem *sep = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil] autorelease];
    
    // add button items to toolbar
    [toolbarCancelSave setItems:[NSArray arrayWithObjects:cancel,sep,save,nil]];
    [toolbarCancelSave setHidden:YES];
    
    // create add/edit/search/switch coloumn toolbar
    toolbarAddEdit = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, dataTable.frame.size.width, 50)] autorelease];
    toolbarAddEdit.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // new record button
    UIBarButtonItem *addForm = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ADD" , Nil) style:UIBarButtonItemStyleBordered target:self action:@selector(addFormRecord:)] autorelease]; 
    addForm.width = 78;
    
    // edit record button
    UIBarButtonItem *edit = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"EDIT", Nil) style:UIBarButtonItemStyleBordered target:self action:@selector(editButtonClick:)] autorelease];
    edit.width = 78;
    
    // search bar
    searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 1, tWidth - 240, 50)] autorelease];
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchBar.showsCancelButton = NO;
    searchBar.delegate = self;
    
    // switch column button 
    UIBarButtonItem *btnChooseColumns = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CHANGE_COLUMN", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(fieldsFilter:)] autorelease];    
    UIBarButtonItem *barSearch = [[[UIBarButtonItem alloc] initWithCustomView:searchBar] autorelease];
    
    // add button items to toolbar
    [toolbarAddEdit setItems:[NSArray arrayWithObjects:barSearch,sep,btnChooseColumns,addForm,edit, nil]];
    

    // ceate paging toolbar
    toolbarPaging = [[UIToolbar alloc] initWithFrame:CGRectMake(0,tHeight-163,tWidth, 50)];
    toolbarPaging.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // previous click button 
    bntPrev = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(prevClick:)] autorelease];
    bntPrev.style = UIBarButtonItemStyleBordered;
    
    // paging button
    record = [[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil] autorelease];
    record.width = 100;
    
    // next click button
    bntNext = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(nextClick:)] autorelease];
    bntNext.style = UIBarButtonItemStyleBordered;
    
    // set up fisrt load paging
    record.title = [NSString stringWithFormat:@"%d%@%d of %d", start_index + 1, @"-", end_index,[dataModel getRowCount]] ;
    bntPrev.enabled = NO;
    
    if ([dataModel getRowCount] <= default_row_number) {
        bntNext.enabled = NO;
        record.title = [NSString stringWithFormat:@"%d%@%d of %d", start_index + 1, @"-", [dataModel getRowCount],[dataModel getRowCount]] ;
        if ([dataModel getRowCount] == 0) 
            record.title = [NSString stringWithFormat:@"%d%@%d of %d", 0 , @"-", 0,[dataModel getRowCount]] ;
    }
    
    // add items to toolbar
    toolbarPaging.items = [NSArray arrayWithObjects:bntPrev,record,bntNext, nil];
    
    
    [mainscreen addSubview:toolbarAddEdit];
    [mainscreen addSubview:toolbarCancelSave];
    [mainscreen addSubview:self.dataTable];
    [mainscreen addSubview:toolbarPaging];
    
    self.view = mainscreen;
    
    [self chooseView];
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(IBAction)fieldsFilter:(id)sender {
    
    FieldsDisplayViewController *chooseFields = [[FieldsDisplayViewController alloc] initWithEntity:[dataModel getEntityName] parentView:self];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:chooseFields];
    [chooseFields release];
    nav.navigationBar.tintColor = [UIColor colorWithRed:(23.0/255.0) green:(155.0/255.0) blue:(192.0/255.0) alpha:1];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:nav animated:YES];
    [nav release];
}


- (void)cancelPopupRecordType:(id)sender{
    UINavigationController *nav;
    
    if(parentController){
        nav = parentController.navigationController;
    }else{
        nav = self.navigationController;
    }
    [nav dismissModalViewControllerAnimated:YES];
}

- (void)saveRecordType:(id)sender{
    UINavigationController *nav;
    
    if(parentController){
        nav = parentController.navigationController;
    }else{
        nav = self.navigationController;
    }
    
    NSString* relationField;
    
    if (parentId != NULL) {
        
        NSMutableDictionary *criteria = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
        [criteria setValue:[[ValuesCriteria alloc] initWithString:parentType] forKey:@"entity"];
        [criteria setValue:[[ValuesCriteria alloc] initWithString:childType] forKey:@"sobject"];
        
        for (Item* item in [RelatedListsInfoManager list:criteria]) {
            relationField = [item.fields objectForKey:@"field"];
        }
        
    }else relationField = nil;
    
    NSMutableDictionary *fields = [[NSMutableDictionary alloc] initWithCapacity:1];
    [fields setValue:recordTypeId forKey:@"recordTypeId"];
    
    Item *item = [[Item alloc] init:[dataModel getEntityName] fields:fields];
    
    AddEditViewController* editV = [[AddEditViewController alloc] init:item mode:@"Add" objectId:parentId relationField:relationField];
    editV.updateInfo = self;
    [nav dismissModalViewControllerAnimated:YES];
    [nav pushViewController:editV animated:YES];
    [editV release];
}

- (void)mustUpdate:(NSString *)val{
    recordTypeId = val;
}


- (void)addFormRecord:(id)sender {
    
    UINavigationController *nav;
    
    if(parentController){
        nav = parentController.navigationController;
    }else{
        nav = self.navigationController;
    }
    
    NSString* relationField;
    
    if (parentId != NULL) {
        
        NSMutableDictionary *criteria = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
        [criteria setValue:[[ValuesCriteria alloc] initWithString:parentType] forKey:@"entity"];
        [criteria setValue:[[ValuesCriteria alloc] initWithString:childType] forKey:@"sobject"];
        
        for (Item* item in [RelatedListsInfoManager list:criteria]) {
            relationField = [item.fields objectForKey:@"field"];
        }
        
    }else relationField = nil;
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:1];
    [dic setValue:[[[ValuesCriteria alloc] initWithString:[dataModel getEntityName]] autorelease] forKey:@"entity"];
    NSArray *listRecordType = [RecordTypeMappingInfoManager list:dic];
   
    [dic release];
    
    if(listRecordType.count > 1){
        popupRecordType = [[RecordTypeChooserViewController alloc] initWIthListItems:listRecordType parent:self entityName:[dataModel getEntityName]];

        UINavigationController *con = [[UINavigationController alloc] initWithRootViewController:popupRecordType];
        [popupRecordType release];
        con.modalPresentationStyle = UIModalPresentationFormSheet;
        con.navigationBar.tintColor = [UIColor colorWithRed:(23.0/255.0) green:(155.0/255.0) blue:(192.0/255.0) alpha:1];
        [nav presentModalViewController:con animated:YES];
        CGRect rect = con.view.superview.frame;
        rect.size = CGSizeMake(500, 300);
        rect.origin.x += 30;
        con.view.superview.frame = rect;
        [con release];
        
    }else{
  
        AddEditViewController* editV = [[AddEditViewController alloc] init:[[Item alloc] init:[dataModel getEntityName] fields:nil] mode:@"Add" objectId:parentId relationField:relationField];
        editV.updateInfo = self;
        [nav pushViewController:editV animated:YES];
        [editV release];

    }
    
    [listRecordType release];
    
}

- (void)editButtonClick:(id) sender {
    if ([dataModel getRowCount]>0) {
        isGridEdit = YES;
        [toolbarAddEdit setHidden:YES];
        [toolbarCancelSave setFrame:CGRectMake(0, 0,dataTable.frame.size.width, 50)]; 
        [toolbarCancelSave setHidden:NO];
        searchBar.hidden = YES;
        isFollowDataModelRowOrder=YES;
        datas = nil;
        [dataTable reloadData];
    }    
    
}

-(void)cancelEdit:(id) sender {
   
     isGridEdit = NO;
    [toolbarAddEdit setHidden:NO];
    [toolbarCancelSave setHidden:YES];
    searchBar.hidden = NO;
    
    isGridEdit = NO;

    [dataTable reloadData];
        
        for (NSString *keyDic in [dataFirstLoad allKeys]) {
            NSArray *dataInRow = [dataFirstLoad objectForKey:keyDic];
                        
            if ([dataInRow count]>0) {
                for (int i = 0; i< [dataModel getColumnCount] ; i++) {
                    if (isPortrait && i == 4 && [dataModel getColumnCount]>5){
                    }else {
                       if (isPortrait && i == [dataInRow count]) 
                         [dataModel setValueAt:[keyDic intValue] columnIndex:i oldValue:nil newValue:[dataInRow objectAtIndex:i-1]];
                       else 
                           [dataModel setValueAt:[keyDic intValue] columnIndex:i oldValue:nil newValue:[dataInRow objectAtIndex:i]];    
                       
                        
                    }    
                }
            }   
        }
    
    
    [listener clearListEdit];
    
    [searchBar resignFirstResponder];

}


-(IBAction) editColumn:(UITextField*) sender {
    
    int rowIndex = [[[[sender layer] valueForKey:@"index"] objectAtIndex:0] intValue];
    int columnIndex = [[[[sender layer] valueForKey:@"index"] objectAtIndex:1] intValue];
    
    NSString *oldValue = [[dataFirstLoad objectForKey:[NSString stringWithFormat:@"%d", rowIndex]] objectAtIndex:columnIndex];
    NSString *newValue = [sender text]; 
    
    [dataModel setValueAt:rowIndex columnIndex:columnIndex oldValue:oldValue newValue:newValue]; 
    
}


- (IBAction) checkBoxClicked:(id)sender {
    
    UIButton *checkBox = (UIButton *)sender;
    
    int rowIndex = [[[[sender layer] valueForKey:@"index"] objectAtIndex:0] intValue];
    int columnIndex = [[[[sender layer] valueForKey:@"index"] objectAtIndex:1] intValue];
     NSString *oldValue = [[dataFirstLoad objectForKey:[NSString stringWithFormat:@"%d", rowIndex]] objectAtIndex:columnIndex];
    
    if ([checkBox imageForState:UIControlStateNormal] == [UIImage imageNamed:@"checkBoxChecked"]){
        [checkBox setImage:[UIImage imageNamed:@"checkBoxUnChecked"] forState:UIControlStateNormal];
        [dataModel setValueAt:rowIndex columnIndex:columnIndex oldValue:oldValue newValue:@"false"];
    }else if ([checkBox imageForState:UIControlStateNormal] == [UIImage imageNamed:@"checkBoxUnChecked"]){
        [checkBox setImage:[UIImage imageNamed:@"checkBoxChecked"] forState:UIControlStateNormal];
        [dataModel setValueAt:rowIndex columnIndex:columnIndex oldValue:oldValue newValue:@"true"];
    }
    
}

-(void) datetimeAndReferenceChanged :(NSArray*)indexRowCol value:(NSString*)newVal{
    int rowIndex = [[indexRowCol objectAtIndex:0] intValue];
    int columnIndex = [[indexRowCol objectAtIndex:1] intValue];
    NSString *oldValue = [[dataFirstLoad objectForKey:[NSString stringWithFormat:@"%d", rowIndex]] objectAtIndex:columnIndex];
    NSString *newValue = newVal; 
    [dataModel setValueAt:rowIndex columnIndex:columnIndex oldValue:oldValue newValue:newValue]; 

}


- (void)saveEditColumn:(id) sender {
    isGridEdit = NO;
    [datas removeAllObjects];
    [toolbarAddEdit setHidden:NO];
    [toolbarCancelSave setHidden:YES];
    searchBar.hidden = NO;
    isGridEdit = NO;
    [dataTable reloadData];
    [listener save];
}


- (IBAction)deleteRecord:(id)sender {   
    deletedRow = sender;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"CONFIRM_DELETE_RECORD", Nil)                           
                                                    message:@"Are you sure?"
                                                   delegate:self cancelButtonTitle:NSLocalizedString(@"YES", Nil) 
                                          otherButtonTitles:NSLocalizedString(@"NO", Nil), nil];
    [alert show];
    [alert release];

}


- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0) {
        
        searchBar.text = @"" ;
        ((UIButton*)deletedRow).tag =((UIButton*)deletedRow).tag + start_index ;
        [listener deleteRecordById:[deletedRow titleForState:UIControlStateDisabled]];
              
        if ([dataModel getRowCount] == start_index) {
            end_index     = end_index - default_row_number;
            start_index   = start_index - default_row_number;
            number_of_row = default_row_number;
            if (default_row_number == [dataModel getRowCount]) {
                bntPrev.enabled = NO;
            }
            
        }
        if (start_index + default_row_number > [dataModel getRowCount]) 
            number_of_row = [dataModel getRowCount] - start_index ;
        
        if ([dataModel getRowCount] == 0) number_of_row = 0 ;
        
        
        if ([datas count] > 0) {
            
            int index = (((UIButton*)deletedRow).tag );
            
            NSMutableArray* tmp = [datas mutableCopy];
            [tmp removeObjectAtIndex:index];
            
            datas = tmp;
            if ([datas count] < number_of_row) number_of_row = [datas count]; 
            isFollowDataModelRowOrder= NO;
        }
        else isFollowDataModelRowOrder = YES;
        
        [self.dataTable reloadData];

        if ([dataModel getRowCount]<end_index) 
            record.title = [NSString stringWithFormat:@"%d%@%d of %d", start_index + 1, @"-", [dataModel getRowCount],[dataModel getRowCount]];
        else 
            record.title = [NSString stringWithFormat:@"%d%@%d of %d", start_index + 1, @"-", end_index,[dataModel getRowCount]];
        
        if ([dataModel getRowCount] == 0) 
            record.title = [NSString stringWithFormat:@"%d%@%d of %d", 0 , @"-", 0,[dataModel getRowCount]] ;
        
        
	} 
    
 
}



- (IBAction)nextClick:(id)sender{
    bntPrev.enabled = YES; 
    int nbDatasFound = [datas count] > 0 ?[datas count]:[dataModel getRowCount];
    
    if(nbDatasFound>end_index){  
		end_index=end_index+default_row_number;
		start_index=start_index+default_row_number;
        
        if (start_index + default_row_number< nbDatasFound) 
            record.title = [NSString stringWithFormat:@"%d%@%d of %d", start_index + 1, @"-", end_index,nbDatasFound] ;
        else{
            record.title = [NSString stringWithFormat:@"%d%@%d of %d", start_index + 1, @"-", nbDatasFound,nbDatasFound] ;
            bntNext.enabled = NO;
        }
        
	}
        
    if (start_index + default_row_number <= nbDatasFound) number_of_row = default_row_number ;
    else if (start_index + default_row_number > nbDatasFound) number_of_row = nbDatasFound % default_row_number ;
    
    isFollowDataModelRowOrder=[datas count] >0 ?NO:YES;
	[dataTable reloadData];
    
}

- (IBAction)prevClick:(id)sender{
    bntNext.enabled = YES;
    int nbDatasFound = [datas count] > 0 ?[datas count]:[dataModel getRowCount];
    
    end_index    = end_index-default_row_number;
    start_index  = start_index-default_row_number;
    record.title = [NSString stringWithFormat:@"%d%@%d of %d", start_index + 1, @"-", end_index,nbDatasFound] ;
    if (start_index == 0) bntPrev.enabled = NO;
    
    if (start_index + default_row_number < nbDatasFound) number_of_row = default_row_number ;
    else number_of_row = nbDatasFound % default_row_number ;
    
    isFollowDataModelRowOrder=[datas count] >0 ?NO:YES;
	[dataTable reloadData];
    
}

-(void)sortDatas:(id)sender {
    
    UIButton* button = (UIButton*)sender;
    NSString* colName = [button titleForState:UIControlStateDisabled];
    
    BOOL sort ;
    
    if ([column_Sorted_Name isEqualToString:colName] || column_Sorted_Name == nil) {
        if (sort_order == 1) {
            column_Sorted_Name = colName;
            sort = YES;
            sort_order = 2;
        }else if (sort_order == 2){
            column_Sorted_Name = colName;
            sort = NO;
            sort_order =0;
        }else {
            column_Sorted_Name = colName;
            sort_order = 1;
            [datas release];
            datas = [[NSMutableArray alloc] init];
            isFollowDataModelRowOrder = YES;
            [dataTable reloadData];
            return;
        }
        
    } else {
        column_Sorted_Name = colName;
        sort = YES;
        sort_order = 2;
    } 
    
    
    int nbCol;
    
    NSMutableArray *arraySort = [[[NSMutableArray alloc] init] autorelease];
    for (int k=0; k<[dataModel getRowCount]; k++) {
        NSMutableArray *tmpData = [[[NSMutableArray alloc] init] autorelease];
        for (int col = 0; col < [dataModel getColumnCount]; col++) {
            NSString *columnName = [dataModel getColumnName:col];
            if ([[dataModel getValueAt:k columnIndex:col] length]>0) 
                 [tmpData addObject:[dataModel getValueAt:k columnIndex:col]];
            else [tmpData addObject:@""];
            
            if ([column_Sorted_Name isEqualToString:columnName]) nbCol = col;
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
    NSMutableArray *sortedItem = [[[NSMutableArray alloc] init] autorelease]; 
    
    for (NSDictionary *d in sortedArray) {
        if ([d objectForKey:@"itemSort"] != nil) 
            [sortedItem addObject:[d objectForKey:@"itemSort"]];
    }
    
    
    datas = [sortedItem copy];
    isFollowDataModelRowOrder = NO;
    [dataTable reloadData];
    
}


#pragma mark - Table view delegate

#pragma mark - Table view data source


-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    UIView *hdrView = [[[UIView alloc] initWithFrame:CGRectMake(0,0, tableView.frame.size.width, 50)] autorelease];
    [hdrView setBackgroundColor:[UIColor colorWithRed:(208.0/255.0) green:(238.0/255.0) blue:(248.0/255.0) alpha:1]];
    
    int   colType;
    float colWidth;
    float start_x = 25;
    
    // Calcuate width of column
    if (!isGridEdit) {
        if (isPortrait) {
            if ([dataModel getColumnCount] > 5) {
                colWidth =  ((tableView.frame.size.width - 90) /([dataModel getColumnCount] - 2))-10;
            }else colWidth =  ((tableView.frame.size.width - 90) /([dataModel getColumnCount] - 1))-10;     
        }else colWidth =  ((tableView.frame.size.width - 90) /([dataModel getColumnCount] - 1))-10;
    }else {
        if (isPortrait) {
            if ([dataModel getColumnCount]>5)
                colWidth =  ((tableView.frame.size.width-55) /([dataModel getColumnCount] - 2));
            else colWidth =  ((tableView.frame.size.width-50) /([dataModel getColumnCount] - 1));
        }else{
            if ([dataModel getColumnCount]>5)
                colWidth =  ((tableView.frame.size.width-70) /([dataModel getColumnCount] - 1));    
            else colWidth =  ((tableView.frame.size.width-55) /([dataModel getColumnCount] - 1));
        }    
    }
    
    
    for (int i=0; i<[dataModel getColumnCount]; i++) {

        if (i == 4 && isPortrait && [dataModel getColumnCount] > 5) NSLog(@"Hide the last column");              
        else {
            
            colType = [dataModel getColumType:i];
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            if (isGridEdit)
                 button.frame = CGRectMake(start_x,0,colWidth+7, 50);
            else button.frame = CGRectMake(start_x,0,7+([[dataModel getColumnName:i] isEqualToString:@"Id"]?90:colWidth), 50); 
            
        if (!(isGridEdit && [[dataModel getColumnName:i] isEqualToString:@"Id"])) {
            
            UILabel* label = [[UILabel alloc] init];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setText:[[dataModel getColumnName:i] isEqualToString:@"Id"]?@"Action":[dataModel getColumnName:i]];
            label.font = [UIFont boldSystemFontOfSize:14];
            label.textColor = [UIColor whiteColor];
            
            if (!isGridEdit && (TYPE_INT == colType || TYPE_DOUBLE == colType || TYPE_PERCENT == colType || TYPE_CURRENCY == colType))
                label.textAlignment = UITextAlignmentRight;
            else if (TYPE_BOOLEAN == colType)
                label.textAlignment = UITextAlignmentCenter;
            else label.textAlignment = UITextAlignmentLeft;
            
            CGRect rect = button.frame;
            rect.origin.x = (i==0)?25.0:5.0;
            rect.size.width -= 10.0;
            label.frame = rect;
            [button addSubview:label];
                      
           
            start_x = start_x+ button.frame.size.width+1;
           
            button.backgroundColor = [UIColor colorWithRed:(42.0/255.0) green:(192.0/255.0) blue:(235.0/255.0) alpha:1];
            [button setTitle:label.text forState:UIControlStateDisabled];
        
            if (![label.text isEqualToString:@"Action"])
                [button addTarget:self action:@selector(sortDatas:) forControlEvents:UIControlEventTouchUpInside];
            
            [hdrView addSubview:button];
 
            if(i==0) {
                rect = button.frame;
                rect.origin.x = -1;
                rect.size.width += 26;
                button.frame = rect;
            }
           
          }  

        }
    }
    
    UIButton* tmp = (UIButton*)[hdrView.subviews lastObject];
    CGRect rect = tmp.frame;
    if (rect.origin.x + rect.size.width < tableView.frame.size.width) rect.size.width +=(tableView.frame.size.width - rect.origin.x - rect.size.width) ;
    tmp.frame = rect;
    
    
    return hdrView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{   
	return number_of_row;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableArray *arrayDataRow = [[[NSMutableArray alloc] init] autorelease];
    float colWidth = 0;
    int rowIdex = 0;
    

    static NSString *customCellIdentifier = @"customCell";
    CustomDataGridRow *cell = nil;
	cell = (CustomDataGridRow *)[tableView dequeueReusableCellWithIdentifier:customCellIdentifier];
	if (cell == nil){
		cell = [[[CustomDataGridRow alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:customCellIdentifier itemPadding:10 scaleToFill:YES] autorelease];
    }
    
    // alternative color 
    if ((indexPath.row % 2) == 0)
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"gridGradient.png"]]];
    else
        cell.contentView.backgroundColor = [UIColor colorWithRed:(208.0/255.0) green:(238.0/255.0) blue:(248.0/255.0) alpha:1];
    
    // Calcuate width of column
    if (!isGridEdit) {
        if (isPortrait) {
            if ([dataModel getColumnCount] > 5) {
                colWidth =  ((tableView.frame.size.width - 90) /([dataModel getColumnCount] - 2))-10;
            }else colWidth =  ((tableView.frame.size.width - 90) /([dataModel getColumnCount] - 1))-10;     
        }else colWidth =  ((tableView.frame.size.width - 90) /([dataModel getColumnCount] - 1))-10;
    }else {
        if (isPortrait) {
            if ([dataModel getColumnCount]>5)
                colWidth =  ((tableView.frame.size.width) /([dataModel getColumnCount] - 2))-30;
            else colWidth =  ((tableView.frame.size.width) /([dataModel getColumnCount] - 1))-30;
        }else colWidth =  ((tableView.frame.size.width) /([dataModel getColumnCount] - 1))-30;    
    }

    
    // row's items
    NSMutableArray *dataRowItems = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];

    for (int i=0; i<[dataModel getColumnCount]; i++) {
        if (i == 4 && isPortrait && [dataModel getColumnCount] > 5) NSLog(@"Hide the last column");              
        else {
            NSString* colName = [dataModel getColumnName:i];
            NSString* datastring;
            
            // display 10 records            
            rowIdex = end_index>default_row_number? (indexPath.row + start_index) : indexPath.row;     
            datastring = (isFollowDataModelRowOrder) ? [dataModel getValueAt:rowIdex columnIndex:i] :[[datas objectAtIndex: rowIdex] objectAtIndex:i];
        
            if (datastring != nil) [arrayDataRow addObject:datastring];
            else [arrayDataRow addObject:@""]; 
            
            if (!isGridEdit) {
                // draw table item
                if (colName == @"Id") {                      
                    CustomDataGridRowItem *rowItem = [[[CustomDataGridRowItem alloc] initWithRowItemType:YES columnType:0 entityName:nil fieldName:nil baseSize:CGSizeMake(90, 54) controlLabel:datastring listener:listener gridItem:nil buttonTarget:self tag:indexPath.row navigateListener:self isView:YES] autorelease];
                    
                    [dataRowItems addObject:rowItem];
                } else {
                    NSString* recordId;
                    for(int i=0;i<[dataModel getColumnCount];i++){
                        if ([[dataModel getApiColumnName:i] isEqualToString:@"Id"] ) {
                            recordId = [dataModel getValueAt:rowIdex columnIndex:i];
                            break;
                        }
                    }
                
                    CustomDataGridRowItem *rowItem = [[[CustomDataGridRowItem alloc] initWithRowItemType:NO columnType:[dataModel getColumType:i] entityName:[dataModel getEntityName] fieldName:[dataModel getApiColumnName:i] baseSize:CGSizeMake(colWidth, 54) controlLabel:datastring listener:listener gridItem:recordId buttonTarget:nil tag:rowIdex navigateListener:self isView:YES] autorelease];
                
                    [dataRowItems addObject:rowItem];
                }
            
            } else {
                // draw table item
                if (colName != @"Id") {
                    NSString* recordType = @"012000000000000AAA";
                    for(int i=0;i<[dataModel getColumnCount];i++){
                        if ([[dataModel getApiColumnName:i] isEqualToString:@"RecordTypeId"] ) {
                            recordType = [dataModel getValueAt:rowIdex columnIndex:i];
                            break;
                        }
                    }

                    CustomDataGridRowItem *rowItem = [[[CustomDataGridRowItem alloc] initWithColumnType:[dataModel getColumType:i] entityName:[dataModel getEntityName] fieldName:[dataModel getApiColumnName:i] recordTypeId:recordType rowIndex:rowIdex columnIndex:i baseSize:CGSizeMake(colWidth, 34) controlLabel:datastring listener:listener buttonTarget:self] autorelease];
                    
                    [dataRowItems addObject:rowItem];
                }
                
                [dataFirstLoad setObject:arrayDataRow forKey:[NSString stringWithFormat:@"%d",rowIdex]];
            }
        }
    }      
    
    cell.rowItems = dataRowItems;
    
    return cell;
}

#pragma mark UISearchBarDelegate 

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    NSMutableArray *searchResult = [[[NSMutableArray alloc] init] autorelease];

    for (int i = 0; i<[dataModel getRowCount]; i++) {
        
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
    
    datas = [searchResult copy];
    
    if([datas count]<=default_row_number){ 
        number_of_row = [datas count];
        start_index = [datas count] ==0 ? -1 : 0;
        end_index = [datas count];
    }else {
        number_of_row = default_row_number;
        start_index = 0;
        end_index = start_index + default_row_number;
    }    
    
    if (end_index < [datas count]) {
        record.title = [NSString stringWithFormat:@"%d%@%d of %d", start_index + 1, @"-", end_index, [datas count]] ;
        bntPrev.enabled = NO;
        bntNext.enabled = YES;
    } else {
        record.title = [NSString stringWithFormat:@"%d%@%d of %d", start_index + 1, @"-", [datas count], [datas count]] ; 
        bntPrev.enabled = NO;
        bntNext.enabled = NO;
    }
    
    isFollowDataModelRowOrder = NO;
    [dataTable reloadData];
}


-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setHidden:NO];
    [self chooseView];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}


-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
     [self chooseView];  
}

- (void)chooseView{
    [dataFirstLoad removeAllObjects];
    UIInterfaceOrientation orient = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect rect;
    [dataTable reloadData];
    if (UIInterfaceOrientationIsPortrait(orient)){

        isPortrait = YES;
        
        rect = searchBar.frame;
        rect.size.width = [toolbarAddEdit.items count] ==5? 530-80 : 580;
        searchBar.frame = rect;
        
        rect = toolbarPaging.frame;
        rect.origin.y = 860;
        toolbarPaging.frame = rect;
        
    }else {

        isPortrait = NO;
        
        rect = searchBar.frame;
        rect.size.width = [toolbarAddEdit.items count] ==5? 785-80 : 825;
        searchBar.frame = rect;
      
        rect = toolbarPaging.frame;
        rect.origin.y = 604;
        toolbarPaging.frame = rect;
        
    }
        
    

}



@end
