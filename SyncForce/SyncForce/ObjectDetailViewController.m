//
//  EditViewController.m
//  SyncForce
//
//  Created by Gaeasys Admin on 11/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ObjectDetailViewController.h"
#import "Section.h"
#import "CustomCell.h"
#import "EditLayoutSectionsInfoManager.h"
#import "DetailLayoutSectionsInfoManager.h"
#import "EntityManager.h"
#import "Entity.h"
#import "InfoFactory.h"
#import "ValuesCriteria.h"
#import "Datagrid.h"
#import "UITool.h"
#import "DatePopupViewController.h"
#import "EntityManager.h"
#import "FieldInfoManager.h"
#import "NumberHelper.h"
#import "DatetimeHelper.h"
#import "EditViewController.h"
#import "Datagrid.h"
#import "RelatedListsInfoManager.h"
#import "HtmlHelper.h"
#import "DatabaseManager.h"
#import "UnderLineButton.h"
#import "RecordTypeMappingInfoManager.h"
#import "CustomUITextField.h"

#import "AddEditViewController.h"

#import "JTRevealSidebarView.h"
#import "JTNavigationView.h"

@implementation ObjectDetailViewController

@synthesize detail,tableDetail,keyInfo;
@synthesize sections,layoutItems,mode,objectId,mapSections;
@synthesize start_number, end_number,selectedRowNumber;
@synthesize parentType, childType, parentId,parentClass;



- (id)init:(Item*)item mode:(NSString*)pMode objectId:(NSString *)pobjectId {
        
    self = [super init];
    isFirstLoadRelatedList = YES;
    self.detail = item;
    self.mode = pMode;
    self.objectId = pobjectId;

    if(!mapRecordTypeLayout)
        mapRecordTypeLayout = [[NSMutableDictionary alloc] init];

    
    Item *tmp = [EntityManager find:detail.entity column:@"Id" value:self.objectId];
    NSString* rtId = [tmp.fields valueForKey:@"RecordTypeId"]==nil?@"012000000000000AAA":[tmp.fields valueForKey:@"RecordTypeId"];    
    
    if(!entityInfo || ![[entityInfo getName] isEqualToString:self.detail.entity] || ![[mapRecordTypeLayout allKeys] containsObject:rtId])
        [self mapData:rtId];
    else {
        listField = [[mapRecordTypeLayout objectForKey:rtId] objectForKey:@"ListField"];
        mapSections = [[mapRecordTypeLayout objectForKey:rtId] objectForKey:@"MapSections"]; 
        sectionNameOrder = [[mapRecordTypeLayout objectForKey:rtId] objectForKey:@"SectionNameOrder"];
        sectionNameRowSection = [[mapRecordTypeLayout objectForKey:rtId] objectForKey:@"SectionNameRowSection"];
        sections = [[mapRecordTypeLayout objectForKey:rtId] objectForKey:@"Sections"];
    
    }   
    
    NSString* tm = @"";
    if([tmp.entity isEqualToString:@"Case"] || [tmp.entity isEqualToString:@"Task"] ||  [tmp.entity isEqualToString:@"Event"]) tm = @"Subject";
    else if ([tmp.entity isEqualToString:@"Contract"]) tm = @"ContractNumber";
    else tm = @"Name";
    
    NSString *name = [tmp.fields valueForKey:tm];

    self.title = name==nil?[NSString stringWithFormat:@"%@",[entityInfo getLabel]]:[NSString stringWithFormat:@"%@(%@)",[entityInfo getLabel],name==nil?@"":name];
   
    
    NSMutableDictionary *dicData = [[[NSMutableDictionary alloc] init] autorelease];
    for(Item *item in listField){
        NSString *fieldName = [item.fields valueForKey:@"value"];
        [dicData setValue:[tmp.fields valueForKey:fieldName] forKey:fieldName];
    }
    
    [dicData setValue:self.objectId forKey:@"Id"];
    if ([[entityInfo getAllFields] containsObject:@"recordTypeId"])
        [dicData setValue:rtId forKey:@"recordTypeId"];

    detail = [[Item alloc] init:detail.entity fields:dicData];
    
    return self;
}

-(void)dealloc{
    [super dealloc];
    [detail release];
    [entityInfo release];
    [layoutItems release];
    [sections release];
    [fieldinfos release];
    [mapSections release];
    [screenRelatedList release];
    [relatedLists release];
    [segment release];
    [relatedHeader release];
    [editView release];
    [mapRefName release];
    [tableNameExist release];
}
- (void)updateFieldDisplay:(NSString*)newValue index:(int)index{
}

- (void)mustUpdate:(NSString *)val{
    
}

-(void)didUpdate:(Item *)newItem{
    CGRect rect = keyInfo.view.frame;
    [self init:newItem mode:mode objectId:objectId];
    [keyInfo initWitFrame:rect data:newItem parent:self];
    [keyInfo.tableKey reloadData]; 
    [self.tableDetail reloadData];
}

- (void)mustUpdate:(NSString *)val header:(NSString *)header sender:(id)sender{
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    
    isRevealSideBar = NO;
    mapRefName = [[NSMutableDictionary alloc] init];
    tableNameExist = [[NSMutableDictionary alloc] init];

    
    UIInterfaceOrientation mainOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    UIView *mainscreen = [[UIView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    
    CGRect rect = mainscreen.frame;
    rect.size.width = (UIInterfaceOrientationIsPortrait(mainOrientation))?768:1024;
    rect.size.height = (UIInterfaceOrientationIsPortrait(mainOrientation))?1024:768;
    
    _revealView = [[JTRevealSidebarView defaultViewWithFrame:mainscreen.bounds] retain];
    _revealView.contentView._navigationBar.tintColor = [UIColor colorWithRed:(23.0/255.0) green:(155.0/255.0) blue:(192.0/255.0) alpha:1];    
    
    _revealView.contentView.navigationItem.RightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(toggleButtonPressed:)] autorelease];
    
    _revealView.contentView.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(returnToParentView:)] autorelease];
    
    // set title of navigation bar
    UIView *v = [[[UIView alloc] init] autorelease];
    v.title = self.title;
    [_revealView.contentView setRootView:v];
  
    
    // Detail view table
    self.tableDetail = [[UITableView alloc] initWithFrame:CGRectMake(0,50+70+50, rect.size.width, rect.size.height-100-70) style:UITableViewStylePlain];
    self.tableDetail.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableDetail.delegate = self;
    self.tableDetail.dataSource = self;
    self.tableDetail.backgroundColor = [UIColor whiteColor];
    self.tableDetail.sectionHeaderHeight = 0;
    
    UIImageView *background = [[[UIImageView alloc] initWithFrame:self.tableDetail.backgroundView.frame] autorelease];
    background.image = [UIImage imageNamed:@"gridGradient.png"];
    background.contentMode = UIViewContentModeScaleToFill;
    self.tableDetail.backgroundView = background;
    
    // Information key field view
    rect = self.tableDetail.frame;
    rect.origin.y = 22;
    rect.size.height = 76;
    rect.size.width = (UIInterfaceOrientationIsPortrait(mainOrientation))? 768 : 1024;
    
    // add information key
    keyInfo = [[KeyInformationView alloc] initWitFrame:rect data:detail parent:self];
    [_revealView.contentView addSubview:keyInfo.view];
    
    
    UIBarButtonItem* buttonEdit = [[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editClick:)] autorelease];
    [buttonEdit setStyle:UIBarButtonItemStyleBordered];
    
    // Toolbar for segment control
    toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0,50+70, self.tableDetail.frame.size.width, 50)] autorelease];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    segment = [[UISegmentedControl alloc] initWithItems:relatedHeader];
    segment.frame = CGRectMake(0, 10 , tableDetail.frame.size.width - 80, 50);
    segment.selectedSegmentIndex = 0;
    [segment setSegmentedControlStyle:UISegmentedControlStyleBar];
    
    [segment addTarget:self action:@selector(changeRelatedList:) forControlEvents:UIControlEventValueChanged];
    [segment sizeToFit];
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 8, toolbar.frame.size.width - 80, 50)];
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.contentSize = CGSizeMake(segment.frame.size.width, 50);
    [scroll addSubview:segment];
    [segment release];
    
     UIBarButtonItem *segBarBtn = [[UIBarButtonItem alloc] initWithCustomView:scroll];

    [toolbar setItems:[NSArray arrayWithObjects:segBarBtn,buttonEdit,nil]];
    
    // add tool bar
    [_revealView.contentView addSubview:toolbar];
    [scroll release];
   
    // add detail view
    [_revealView.contentView addSubview:self.tableDetail];
    
    [[[[_revealView.subviews objectAtIndex:0] subviews] objectAtIndex:0] removeFromSuperview];
    
    // Setup a view to be the rootView of the sidebar
    _revealView.sidebarView._navigationBar.tintColor = [UIColor colorWithRed:(190.0/255.0) green:(190.0/255.0) blue:(190.0/255.0) alpha:1];
    SidBarDetailView* tableSideBar = [[SidBarDetailView alloc] initWithRevealView:_revealView entityName:detail.entity parent:self];
    [_revealView.sidebarView pushView:tableSideBar.view animated:NO];  
    
    self.view = mainscreen;
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:_revealView];
    
}



- (void)editClick:(id)sender{
    
    [self.navigationController.navigationBar setHidden:NO];
   /* editView = [[EditViewController alloc] init:detail mode:[Datagrid getEditImg] objectId:self.objectId relationField:nil];
    editView.updateInfo = self;
    [self.navigationController pushViewController:editView animated:YES];
    [editView release];
    */
    
    
    AddEditViewController* editV = [[AddEditViewController alloc] init:detail mode:@"Edit" objectId:self.objectId relationField:nil];
    editV.updateInfo = self;
    [self.navigationController pushViewController:editV animated:YES];
    [editV release];

    
}


-(void) mapData:(NSString*) rtId{

    NSMutableDictionary* mapSectionWithRecordType = [[[NSMutableDictionary alloc] init] autorelease];
    
    entityInfo = [InfoFactory getInfo:self.detail.entity];
   
    self.layoutItems = [[NSMutableDictionary alloc] initWithCapacity:1];
    sectionNameRowSection = [[[NSMutableDictionary alloc] init] autorelease];
    
    //Group items(Field) by heading
    sectionNameOrder = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    mapSections = [[NSMutableDictionary alloc] initWithCapacity:1];
    NSMutableDictionary *dic = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
    
    
    [dic setValue:[[[ValuesCriteria alloc] initWithString:rtId] autorelease] forKey:@"recordTypeId"];
    [dic setValue:[[[ValuesCriteria alloc] initWithString:detail.entity] autorelease] forKey:@"entity"];
    Item *it = [RecordTypeMappingInfoManager find:dic];
    
    NSMutableDictionary *filters = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
    [filters setValue:[ValuesCriteria criteriaWithString:self.detail.entity] forKey:@"entity"];
    if ([[it.fields valueForKey:@"layoutId"] length]>0)
        [filters setValue:[ValuesCriteria criteriaWithString:[it.fields valueForKey:@"layoutId"]] forKey:@"Id"];
    
    listField = [DetailLayoutSectionsInfoManager list:filters];        
    
    for(Item *item in listField){
        NSString *heading = [item.fields valueForKey:@"heading"];
        if(![mapSections.allKeys containsObject:heading]){
            [sectionNameOrder addObject:heading];
            NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:1];
            [mapSections setValue:items forKey:heading];
        }
        
        [[mapSections objectForKey:heading] addObject:item];
        
    }
    
    NSMutableArray *detailSections = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    for(NSString *heading in sectionNameOrder){
        Section *section = [[[Section alloc] initWithName:heading] autorelease];
        for(int i=0;i<[[mapSections valueForKey:heading] count];i++){
            Item *item = [[mapSections valueForKey:heading] objectAtIndex:i];
            if (![[sectionNameRowSection allKeys] containsObject:heading]) {
                [sectionNameRowSection setObject:[item.fields objectForKey:@"rows"] forKey:heading];
            }
            
            NSString *fieldLabel = [item.fields valueForKey:@"label"];
            NSString *type = [item.fields valueForKey:@"type"];
            
            if(![type isEqualToString:@"Separator"] && ![[self.layoutItems allKeys] containsObject:fieldLabel]){
                [self.layoutItems setObject:[[NSMutableArray alloc] initWithObjects:item, nil] forKey:fieldLabel];
                [section.fields addObject:fieldLabel];
            }else {
                [[self.layoutItems objectForKey:fieldLabel] addObject:item];
            }
            
        }
        
        [detailSections addObject:section];
    }
    
    Section *section = [[[Section alloc] initWithName:@"Related Lists"] autorelease];
    [detailSections addObject:section];
    
    if([detail.entity isEqualToString:@"Account"]){
        Section *googleMapSection = [[[Section alloc] initWithName:@"Account Location"] autorelease];
        // [googleMapSection.fields addObject:@"header"];
        [googleMapSection.fields addObject:@"map"];
        if (![[sectionNameRowSection allKeys] containsObject:googleMapSection.name]) {
            [sectionNameRowSection setObject:@"1" forKey:googleMapSection.name];
            [sectionNameOrder addObject:googleMapSection.name];
        }
        
        if([detailSections count] > 2){
            [detailSections insertObject:googleMapSection atIndex:2];
        }else{
            [detailSections insertObject:googleMapSection atIndex:([detailSections count]-1)];
        }
    }
    
    
    sections = [detailSections copy];
    
    [mapSectionWithRecordType setValue:listField forKey:@"ListField"];
    [mapSectionWithRecordType setValue:mapSections forKey:@"MapSections"];
    [mapSectionWithRecordType setValue:sectionNameOrder forKey:@"SectionNameOrder"];
    [mapSectionWithRecordType setValue:sectionNameRowSection forKey:@"SectionNameRowSection"];
    [mapSectionWithRecordType setValue:sections forKey:@"Sections"];
    
    [mapRecordTypeLayout setValue:mapSectionWithRecordType forKey:rtId];
    
    relatedHeader = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableDictionary *criteria = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
    [criteria setValue:[[ValuesCriteria alloc] initWithString:detail.entity] forKey:@"entity"];
    
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:1];
    
    
    for(Item *item in [RelatedListsInfoManager list:criteria]){
        NSString *table = [item.fields objectForKey:@"sobject"];
        NSMutableDictionary *checkLayout = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
        [checkLayout setValue:[ValuesCriteria criteriaWithString:table] forKey:@"entity"];
        NSArray *listLayout = [EditLayoutSectionsInfoManager list:checkLayout];
        
        if([[DatabaseManager getInstance] checkTable:table]){
            if ([listLayout count]>0) {
                if ([[item.fields objectForKey:@"field"] length] > 0) {
                    [relatedHeader addObject:[item.fields objectForKey:@"label"]];
                    [arr addObject:item];
                }    
            }    
        }
    }
    
    [relatedHeader insertObject:@"Detail View" atIndex:0];
    [arr insertObject:@"" atIndex:0];
    
    relatedLists = [arr copy];
    [arr release];

}


- (void)clickToCollape:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    NSMutableArray *indexes = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];    
    Section *section = [self.sections objectAtIndex:button.tag];
    
    int nbRow ; 
    
    if ([[mapSections allKeys] containsObject:section.name]) {
        nbRow =  [[[[[mapSections objectForKey:section.name ] objectAtIndex:0] fields] objectForKey:@"rows"] intValue];
    }else 
        nbRow = [section.fields count];


    if ([sectionNameRowSection objectForKey:section.name] != nil) {
        [button setBackgroundImage:[UIImage imageNamed:@"arrow_right.png"] forState:UIControlStateNormal];
        for (int i = 0; i < nbRow; i++) {
            [indexes addObject:[NSIndexPath indexPathForRow:i inSection:button.tag]];
        }
        
        //[section.fields removeAllObjects]; // must delete before animating
        [sectionNameRowSection removeObjectForKey:section.name];
        [self.tableDetail deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];
 
    } else {
        // must add before animating
       // [section.fields addObjectsFromArray:[self fillSection:button.tag]];
        [button setBackgroundImage:[UIImage imageNamed:@"arrow_down.png"] forState:UIControlStateNormal];
        for (int i = 0; i < nbRow; i++) {
            [indexes addObject:[NSIndexPath indexPathForRow:i inSection:button.tag]];
        }
        
        [sectionNameRowSection setObject:[NSString stringWithFormat:@"%d",nbRow] forKey:section.name];
        [self.tableDetail insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];
    }
    
    
}

-(void) changeAction : (id) sender {
    UISegmentedControl* tmp = (UISegmentedControl*)sender ;
    if (tmp.selectedSegmentIndex == 0) [self performSelector:@selector(editClick:)];
    else [self performSelector:@selector(toggleButtonPressed:)];
}

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 }
 */
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [self tableView:self.tableDetail cellForRowAtIndexPath: indexPath];
    Section *section = [self.sections objectAtIndex:indexPath.section];
    
    if([section.name isEqualToString:@"Account Location"]){
        return 300;
    }

    float height = 44;
    
    for (UITextView* view in cell.contentView.subviews) {
        if ([view isKindOfClass:[UITextView class]]) {

            UIFont *font = [UIFont fontWithName:@"Helvetica" size:14.0];
            CGSize constraintSize = CGSizeMake(780.0, MAXFLOAT); //280
            CGSize bounds = [view.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
            if (height - bounds.height < 0) height = height - (height - bounds.height);
            height = MAX((44 + bounds.height),height+bounds.height);
            
            return height;
            
        }else height = 54;   
           
    }
    
    return height;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    return [self.sections count]-1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
     // [sectionNameOrder retain];
     // [sectionNameRowSection retain];

      if ([sectionNameOrder containsObject:[[self.sections objectAtIndex:section] name]]) {
         return [[sectionNameRowSection objectForKey:[[self.sections objectAtIndex:section] name]] intValue];
      }
    
      return [[[self.sections objectAtIndex:section] fields] count];
}



-(void)viewWillAppear:(BOOL)animated{
    
    [self.navigationController.navigationBar setHidden:YES];
    UIInterfaceOrientation mainOrientation = [[UIApplication sharedApplication] statusBarOrientation];    
    float width =(UIInterfaceOrientationIsPortrait(mainOrientation))?isRevealSideBar?768-270:768:isRevealSideBar?1024-270:1024;
    CGRect rect;
    
    rect = keyInfo.tableKey.frame;
    rect.size.width = width;
    keyInfo.tableKey.frame = rect;
    [keyInfo.tableKey reloadData]; 
    

    for (UIScrollView*view in toolbar.subviews) {        
        rect = view.frame;
        rect.size.width = width - 80;
        [view setFrame:rect];
    }
    
    if (![[_revealView.contentView.subviews lastObject] isKindOfClass:[UITableView class]]) {
        
        //move related list screen's (x,y) 
        rect = screenRelatedList.view.frame;
        rect.origin.y = 70+50+50;
        rect.size.width = width;
        screenRelatedList.view.frame = rect;
        
        //search bar
        rect = screenRelatedList.dataGrid.searchBar.frame;
        rect.size.width = width - 190;
        screenRelatedList.dataGrid.searchBar.frame = rect;
        
        //table related list
        [screenRelatedList.dataGrid.dataTable reloadData];
        
        //footer related list
        rect = screenRelatedList.dataGrid.toolbarPaging.frame;
        rect.origin.y = (UIInterfaceOrientationIsPortrait(mainOrientation)) ? 860-70-55 : 604-70-55;
        screenRelatedList.dataGrid.toolbarPaging.frame = rect;
        
    } 
    else {
        
        rect = self.tableDetail.frame;
        rect.size.width = width;
        rect.size.height = (_revealView.contentView.frame.size.height) - 70 - 100;
        self.tableDetail.frame = rect;
        [self.tableDetail reloadData];
    } 


    
}

- (void)reloadRelatedList{
    
    if (segmentSelectIndex && segmentSelectIndex != 0) {
        UIInterfaceOrientation mainOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        float width = (UIInterfaceOrientationIsPortrait(mainOrientation))?isRevealSideBar?768-270:768 :isRevealSideBar?1024-270:1024;
        if(screenRelatedList) [screenRelatedList release];
 
        segmentSelectIndex = segment.selectedSegmentIndex;;
        Item *item = [relatedLists objectAtIndex:segmentSelectIndex];
    
        screenRelatedList = [[ScreenRelatedList alloc] initWithData:detail.entity childType:[item.fields objectForKey:@"sobject"] parentId:self.objectId parentController:self];
        [self chooseView:width];
        
        [[_revealView.contentView.subviews lastObject] removeFromSuperview];
        [_revealView.contentView addSubview:screenRelatedList.view];
    }
}

- (void)changeRelatedList:(id)sender{
    
    UIInterfaceOrientation mainOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    if(segmentedControl.selectedSegmentIndex != 0) {
        if(screenRelatedList) [screenRelatedList release];
        if([relatedHeader count] > 0){
            isFirstLoadRelatedList = YES;
            segmentSelectIndex = [segmentedControl selectedSegmentIndex];
            Item *item = [relatedLists objectAtIndex:segmentSelectIndex];
        
            screenRelatedList = [[ScreenRelatedList alloc] initWithData:detail.entity childType:[item.fields objectForKey:@"sobject"] parentId:self.objectId parentController:self];
            float width = (UIInterfaceOrientationIsPortrait(mainOrientation))?isRevealSideBar?768-270:768 :isRevealSideBar?1024-270 : 1024;
            [self chooseView:width];
            
        }
    }else{
         isFirstLoadRelatedList = NO; 
         segmentSelectIndex = 0;
         [self dataTableReloadView];
         [[_revealView.contentView.subviews lastObject] removeFromSuperview];
         [_revealView.contentView addSubview:self.tableDetail];

    }
    
}


-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return SETTING_HEADER_HEIGHT;
}


-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    Section *sectionData = [self.sections objectAtIndex:section];
    
    UIView *hdrView = [[[UIView alloc] initWithFrame:CGRectMake(0,0, tableView.frame.size.width, SETTING_HEADER_HEIGHT)] autorelease];
    hdrView.backgroundColor = [UIColor colorWithRed:(208.0/255.0) green:(238.0/255.0) blue:(248.0/255.0) alpha:1];
    hdrView.layer.cornerRadius = 2;
    hdrView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(64, 0, SETTING_HEADER_ROW_WIDTH, SETTING_HEADER_HEIGHT)] autorelease];
    label.font = [UIFont boldSystemFontOfSize:SETTING_HEADER_FONT_SIZE];
    label.textAlignment = UITextAlignmentLeft;
    label.textColor = [UIColor blackColor];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0, 1);
    label.backgroundColor = [UIColor clearColor];
    HtmlHelper *help = [[HtmlHelper alloc] init];
    label.text = [help convertEntiesInString:[[sections objectAtIndex:section] name]];
    [help release];
    
    if(section < ([sections count]-1)){
        
        hdrView.backgroundColor = [UIColor colorWithRed:(208.0/255.0) green:(238.0/255.0) blue:(248.0/255.0) alpha:1];
        hdrView.layer.cornerRadius = 2;
        
        UIImageView *seperat = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sectionHeaderUnderline.png"]] autorelease];
        seperat.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        seperat.frame = CGRectMake(0, SETTING_HEADER_HEIGHT+1, hdrView.frame.size.width, 5);
        
        UIButton *button = [[[UIButton alloc] initWithFrame:CGRectMake(20, 10, 30, 30)] autorelease];
        button.tag = section;
        
        [button setBackgroundImage:[UIImage imageNamed:[sectionNameRowSection objectForKey:sectionData.name] != nil ? @"arrow_down.png" : @"arrow_right.png"] forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(clickToCollape:) forControlEvents:UIControlEventTouchUpInside];
        [hdrView addSubview:button];
        [hdrView addSubview:label];
        [hdrView addSubview:seperat];
        
    }
    
   // [label release];
   // [hdrView release];


    return hdrView;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[CustomCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
   
    for (UIView *view in cell.contentView.subviews) [view removeFromSuperview];
    
    CGRect bounds = cell.contentView.bounds;
    CGRect rect = CGRectInset(bounds, 9.0, 9.0);
    rect = CGRectOffset(rect, 330.0, 0.0);
    rect.size.width = rect.size.width - 300;
 
    BOOL isPort = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    BOOL isRefFound = NO;
    
    // Configure the cell...
    Section *section = [self.sections objectAtIndex:indexPath.section];

    NSString *fieldname;
    
    if ([section.name isEqualToString:@"Additional Information"]) {
          fieldname = [section.fields objectAtIndex:2*indexPath.row];
    }else 
        fieldname = [section.fields objectAtIndex:indexPath.row];
    
    NSMutableArray* arr = [self.layoutItems valueForKey:fieldname];
    Item *info;
    NSString *fieldType;
    NSString *value = @"";
    NSString *referenceType = nil;
    NSString* fieldApi = @"";
    int nbColumn;
    
    for (Item*item in arr) {
                 
         info = [entityInfo getFieldInfoByName:[item.fields objectForKey:@"value"]];
         fieldType = [info.fields objectForKey:@"type"];
        
         fieldApi = [item.fields objectForKey:@"value"];
         nbColumn = [[item.fields objectForKey:@"columns"] intValue];
         NSString* val = [detail.fields valueForKey:[item.fields objectForKey:@"value"]];
         
        if([[item.fields objectForKey:@"type"] isEqualToString:@"Separator"]){  
            val = fieldApi;
        }else {
        
            if ([fieldType isEqualToString:@"currency"]) {
                val = [NumberHelper formatCurrencyValue:[[detail.fields valueForKey:fieldApi] doubleValue]];
            }else if ([fieldType isEqualToString:@"double"] || [fieldType isEqualToString:@"int"]) {
                val = [NumberHelper formatNumberDisplay:[[detail.fields valueForKey:fieldApi] doubleValue]];
            }else if([fieldType isEqualToString:@"percent"]) {
                val = [NumberHelper formatPercentValue:[[detail.fields valueForKey:fieldApi] doubleValue]];
            }else if([fieldType isEqualToString:@"date"] || [fieldType isEqualToString:@"datetime"]) {
                val = [DatetimeHelper display:[detail.fields valueForKey:fieldApi]];
            
            }else if([fieldType isEqualToString:@"reference"]){
                if (parentClass) {
                    val = [[((CustomDataGrid*)parentClass).listener getValueBy:fieldApi recordId:[detail.fields valueForKey:fieldApi]] objectForKey:@"Result"]; 
                    referenceType = [[((CustomDataGrid*)parentClass).listener getValueBy:fieldApi recordId:[detail.fields valueForKey:fieldApi]] objectForKey:@"RefName"];
                    isRefFound = [[[((CustomDataGrid*)parentClass).listener getValueBy:fieldApi recordId:[detail.fields valueForKey:fieldApi]] objectForKey:@"Found"] isEqualToString:@"YES"]?YES:NO;
                    
                }else {
                    val = [[self getValueBy:fieldApi recordId:[detail.fields valueForKey:fieldApi]] objectForKey:@"Result"]; 
                    referenceType = [[self getValueBy:fieldApi recordId:[detail.fields valueForKey:fieldApi]] objectForKey:@"RefName"]; 
                    isRefFound = [[[self getValueBy:fieldApi recordId:[detail.fields valueForKey:fieldApi]] objectForKey:@"RefName"] isEqualToString:@"YES"]?YES:NO;
                }   
            }
        
        }   
          
        if (val != nil) {
            value = [NSString stringWithFormat:@"%@%@",value,val];
        }

    }
    
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  
    
    if ([value hasPrefix:@","]) value = [value substringFromIndex:1];
    if ([value hasSuffix:@","]) value = [value substringToIndex:[value length]-1];
    
    float start_x = 0;
    float tWidth  = tableView.frame.size.width/4 ;
    float space = 10.f;    
    
        if(![fieldname isEqualToString:@"header"]){
            if([fieldname isEqualToString:@"map"]){
                mapcon = [[MapviewController alloc] initWithFrame:cell.contentView.frame account:detail];
                [cell.contentView addSubview:mapcon.view];
            }else{

                start_x = isRevealSideBar?15:30;
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake( start_x, 0, tWidth - space - start_x , 40)];
                label.textAlignment = UITextAlignmentRight;
                label.numberOfLines = 4;
                label.backgroundColor = [UIColor clearColor];            
                label.text = fieldname; //[fieldInfo.fields valueForKey:@"label"];
                label.textColor = [UIColor blackColor];
                label.font = [UIFont boldSystemFontOfSize:14];
                [cell.contentView addSubview:label];
                [label release];
                rect.origin.x = isPort?180:220;
                
                start_x = tWidth; 

                if([fieldType isEqualToString:@"boolean"]){
                    UIImageView *checkBox = [[UIImageView alloc] initWithFrame:CGRectMake(start_x + 10, 10, 22, 22)];
                    checkBox.contentMode = UIViewContentModeScaleAspectFit;
                    checkBox.image = [UIImage imageNamed:[value isEqualToString:@"true"]?@"check_yes.png":@"check_no.png"];
                    [cell.contentView addSubview:checkBox];
                    [checkBox release];
                }else if(isRefFound &&[fieldType isEqualToString:@"reference"] && ![referenceType isEqualToString:@"User"] && referenceType){
                    UnderLineButton *button = [UnderLineButton buttonWithType:UIButtonTypeCustom];
                    button.tag = indexPath.row;
                    rect.origin.y = rect.origin.y - 5;
                    rect.origin.x = start_x+10;
                    rect.size.width = tWidth - space;
                    rect.size.height = 30;
                    button.frame = rect;
                    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                    [button setTitle:value forState:UIControlStateNormal];
                    [button setTitle:referenceType forState:UIControlStateDisabled];
                    [button setTitle:[detail.fields valueForKey:fieldApi] forState:UIControlStateApplication];
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
                    [button addTarget:self action:@selector(openParent:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.contentView addSubview:button];
                }else{
                    
                    UIFont *font = [UIFont fontWithName:@"Helvetica" size:14.0];
                    CGSize constraintSize = CGSizeMake(780.0f, MAXFLOAT);
                    CGSize bounds = [value sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
                    
                    float tmp = isPort?(isRevealSideBar?150.f:200.f):(isRevealSideBar?200.f:260.f);
                    rect.size.width = nbColumn==1 ? (self.tableDetail.frame.size.width -tmp) : (tWidth - space);
                    
                    rect.size.height = ((CGFloat) cell.bounds.size.height + bounds.height); //[value length]>40?90:60;
                    rect.size.height = rect.size.height+bounds.height ;//isRevealSideBar?(rect.size.height+bounds.height+10):rect.size.height;
                    rect.origin.y = 0;
                    rect.origin.x = start_x;
                    
                    UITextView *textView = [[UITextView alloc] initWithFrame:rect];
                    textView.editable = NO;
                    textView.scrollEnabled = NO;
                    textView.backgroundColor = [UIColor clearColor];
                    textView.font = [UIFont systemFontOfSize:16];
                    textView.text = value;
                    [cell.contentView addSubview:textView];
                    [textView release];
                }


            }
        }
    
    
        if ([section.fields count] > [[[[[mapSections objectForKey:[section name]] objectAtIndex:0] fields] objectForKey:@"rows"] intValue]) {
            
                if ((indexPath.row + [[[[[mapSections objectForKey:[section name]] objectAtIndex:0] fields] objectForKey:@"rows"] intValue])< [section.fields count]) {

                    NSString *fieldname;
                    if (![section.name isEqualToString:@"Additional Information"]) {
                        fieldname = [section.fields objectAtIndex:(indexPath.row + [[[[[mapSections objectForKey:[section name]] objectAtIndex:0] fields] objectForKey:@"rows"] intValue])];
                        
                    }else 
                        fieldname = [section.fields objectAtIndex:(2*indexPath.row + 1)];
                    
                    
                  if(![fieldname isEqualToString:@"map"]){
                        
                    info = nil;
                    fieldType = nil;
                    referenceType = nil;
                    value = @"";
                    fieldApi = @"";  
                    
                    NSMutableArray* arr = [self.layoutItems valueForKey:fieldname];
                    
                    for (Item*item in arr) {
                        
                        info = [entityInfo getFieldInfoByName:[item.fields objectForKey:@"value"]];
                        fieldType = [info.fields objectForKey:@"type"];
                        fieldApi = [item.fields objectForKey:@"value"];
                        NSString* val = [detail.fields valueForKey:[item.fields objectForKey:@"value"]];
                        
                        if([[item.fields objectForKey:@"type"] isEqualToString:@"Separator"]){  
                            if(value) val = fieldApi;
                        }else {
                        
                            if ([fieldType isEqualToString:@"currency"]) {
                                val = [NumberHelper formatCurrencyValue:[[detail.fields valueForKey:fieldApi] doubleValue]];
                            }else if ([fieldType isEqualToString:@"double"] || [fieldType isEqualToString:@"int"]) {
                                val = [NumberHelper formatNumberDisplay:[[detail.fields valueForKey:fieldApi] doubleValue]];
                            }else if([fieldType isEqualToString:@"percent"]) {
                                val = [NumberHelper formatPercentValue:[[detail.fields valueForKey:fieldApi] doubleValue]];
                            }else if([fieldType isEqualToString:@"date"] || [fieldType isEqualToString:@"datetime"]) {
                                val = [DatetimeHelper display:[detail.fields valueForKey:fieldApi]];
                            
                            }else if([fieldType isEqualToString:@"reference"]){
                                if (parentClass) {    
                                    val = [[((CustomDataGrid*)parentClass).listener getValueBy:fieldApi recordId:[detail.fields valueForKey:fieldApi]] objectForKey:@"Result"];
                                    referenceType = [[((CustomDataGrid*)parentClass).listener getValueBy:fieldApi recordId:[detail.fields valueForKey:fieldApi]] objectForKey:@"RefName"];
                                } else {
                                    val = [[self getValueBy:fieldApi recordId:[detail.fields valueForKey:fieldApi]] objectForKey:@"Result"]; 
                                    referenceType = [[self getValueBy:fieldApi recordId:[detail.fields valueForKey:fieldApi]] objectForKey:@"RefName"]; 
                                }  
                            }
                        }
                        

                        if (val != nil) {
                            value = [NSString stringWithFormat:@"%@%@",value,val];
                        }
                
                     }
                
                      value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  

                      if ([value hasPrefix:@","]) value = [value substringFromIndex:1];
                      if ([value hasSuffix:@","]) value = [value substringToIndex:[value length]-1];
                  
                          
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(2*start_x + (isRevealSideBar?15:30), 0, tWidth - space - (isRevealSideBar?15:30), 40)];
                    label.textAlignment = UITextAlignmentRight;
                    label.numberOfLines = 4;
                    label.backgroundColor = [UIColor clearColor];
                    label.text =  fieldname ;//[fieldInfo.fields valueForKey:@"label"];
                    label.textColor = [UIColor blackColor];
                    label.font = [UIFont boldSystemFontOfSize:14];
                    [cell.contentView addSubview:label];
                    [label release];
                    rect.origin.x = isPort?530:690;
                      
                      start_x = 3 * tWidth;
                      
                    if([fieldType isEqualToString:@"boolean"]){
                        UIImageView *checkBox = [[UIImageView alloc] initWithFrame:CGRectMake(start_x+10, 10, 22, 22)];
                        checkBox.contentMode = UIViewContentModeScaleAspectFit;
                        checkBox.image = [UIImage imageNamed:[value isEqualToString:@"true"]?@"check_yes.png":@"check_no.png"];
                        [cell.contentView addSubview:checkBox];
                        [checkBox release];
                    }else if([fieldType isEqualToString:@"reference"] && ![referenceType isEqualToString:@"User"] && referenceType){
                        UnderLineButton *button = [UnderLineButton buttonWithType:UIButtonTypeCustom];
                        button.tag = indexPath.row;
                        rect.size.width = tWidth - space;
                        rect.size.height = 30;
                        rect.origin.y = rect.origin.y + 5;
                        rect.origin.x = start_x ; //rect.origin.x + 2;
                        button.frame = rect;
                        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                        [button setTitle:value forState:UIControlStateNormal];
                        [button setTitle:referenceType forState:UIControlStateDisabled];
                        [button setTitle:[detail.fields valueForKey:fieldApi] forState:UIControlStateApplication];
                        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
                        [button addTarget:self action:@selector(openParent:) forControlEvents:UIControlEventTouchUpInside];
                        [cell.contentView addSubview:button];
                    }else{
                        
                        UIFont *font = [UIFont fontWithName:@"Helvetica" size:14.0];
                        CGSize constraintSize = CGSizeMake(780.0f, MAXFLOAT);
                        CGSize bounds = [value sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
                        
                        rect.origin.x = start_x;
                        rect.size.width = tWidth - space;
                        rect.size.height = ((CGFloat) cell.bounds.size.height + bounds.height); //[value length]>20?90:60;
                        rect.size.height = rect.size.height+bounds.height;//isRevealSideBar?rect.size.height+bounds.height:rect.size.height;
                        UITextView *textView = [[UITextView alloc] initWithFrame:rect];
                        textView.editable = NO;
                        textView.scrollEnabled = NO;
                        textView.backgroundColor = [UIColor clearColor];
                        textView.font = [UIFont systemFontOfSize:16];
                        textView.text = value;
                        [cell.contentView addSubview:textView];
                        [textView release];
                    }

                }    
            }    
        
        }
    
    
    return cell;
}

- (void)openParent:(id)sender{
    
    NSString *entity = [sender titleForState:UIControlStateDisabled];
    NSString *value = [sender titleForState:UIControlStateApplication];
    
    Item *item = [[Item alloc] init:entity fields:nil];
    [item.fields setValue:value forKey:@"Id"];
     ObjectDetailViewController *detailCon = [[ObjectDetailViewController alloc] init:item mode:nil objectId:value];

    
    NSMutableDictionary *criterias = [[[NSMutableDictionary alloc] init] autorelease];
    [criterias setValue:[[ValuesCriteria alloc] initWithString:[item.fields valueForKey:@"Id"]] forKey:@"Id"];

    Item* tmp = [EntityManager find:item.entity criterias:criterias];
    detailCon.selectedRowNumber = [[tmp.fields objectForKey:@"local_id"] intValue] - 1;
    detailCon.start_number = ([[tmp.fields objectForKey:@"local_id"] intValue] / 10) * 10;
   // detailCon.end_number = detailCon.start_number + 10; 
     
    [self.navigationController pushViewController:detailCon animated:YES];
    [detailCon release];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    
    return YES;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
   
    float width =(UIInterfaceOrientationIsPortrait(toInterfaceOrientation))?isRevealSideBar?768-270:768:isRevealSideBar?1024-270:1024;
    CGRect rect = keyInfo.tableKey.frame;
    rect.size.width = width;
    keyInfo.tableKey.frame = rect;
    [keyInfo.tableKey reloadData]; 
    
    
    for (UIScrollView*view in toolbar.subviews) {
        rect = view.frame;
        rect.size.width = width - 80;
        [view setFrame:rect];
    }
    
    if (![[_revealView.contentView.subviews lastObject] isKindOfClass:[UITableView class]]) {
        
        rect = screenRelatedList.view.frame;
        rect.size.width = width;
        screenRelatedList.view.frame = rect;
        
        //search bar
        rect = screenRelatedList.dataGrid.searchBar.frame;
        rect.size.width = width - 190;
        screenRelatedList.dataGrid.searchBar.frame = rect;
        
        // grid reload
        [screenRelatedList.dataGrid.dataTable reloadData];
        
        //footer related list
        rect = screenRelatedList.dataGrid.toolbarPaging.frame;
        rect.origin.y = (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) ? 860-70-55 : 604-70-55;
        screenRelatedList.dataGrid.toolbarPaging.frame = rect;
    } 
    else [self dataTableReloadView];

}


-(void) chooseView :(float)width{

    //move related list screen's (x,y) 
    CGRect rect = screenRelatedList.view.frame;
    rect.origin.x =  0 ;//isRevealSideBar?270 : 0;
    rect.origin.y = 70+50+50;
    rect.size.width = width;
    screenRelatedList.view.frame = rect;
    
    //search bar
    rect = screenRelatedList.dataGrid.searchBar.frame;
    rect.size.width = width - 190;
    screenRelatedList.dataGrid.searchBar.frame = rect;
    
    //table related list
    [screenRelatedList.dataGrid.dataTable reloadData];
    
    //footer related list
    rect = screenRelatedList.dataGrid.toolbarPaging.frame;
    rect.origin.y = rect.origin.y - 75;
    screenRelatedList.dataGrid.toolbarPaging.frame = rect;
    
    [[_revealView.contentView.subviews lastObject] removeFromSuperview];
    [_revealView.contentView addSubview:screenRelatedList.view];
    

}

-(void)dataTableReloadView {
    
    UIInterfaceOrientation mainOrientation = [[UIApplication sharedApplication] statusBarOrientation];

    CGRect rect = self.tableDetail.frame;
    rect.origin.x = 0;//isRevealSideBar?270:0;
    rect.size.width = ((UIInterfaceOrientationIsPortrait(mainOrientation)) ? 768:1024) - (isRevealSideBar?270:0) ;
    rect.size.height =((UIInterfaceOrientationIsPortrait(mainOrientation)) ? 1024:768) - 70-150;
    self.tableDetail.frame = rect;
    [self.tableDetail reloadData]; 

}

#pragma mark Actions

- (void)toggleButtonPressed:(id)sender {
    
        UIInterfaceOrientation mainOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
        isRevealSideBar = ![_revealView isSidebarShowing];
    
        CGRect rect;
        float start_x = 0; // isRevealSideBar?270:0;
        float width =(UIInterfaceOrientationIsPortrait(mainOrientation))?768:1024;
              width = width - (isRevealSideBar?270:0);
    
        
        rect = keyInfo.view.frame;
        rect.origin.x = start_x;
        rect.size.width = width;
        keyInfo.view.frame = rect;
    
        rect = keyInfo.tableKey.frame;
        rect.size.width = width;
        keyInfo.tableKey.frame = rect;
        [keyInfo.tableKey reloadData];
    
        rect = [[_revealView.contentView.subviews objectAtIndex:1] frame];
        rect.origin.x = start_x;
        rect.size.width = width;
        [[_revealView.contentView.subviews objectAtIndex:1] setFrame:rect];
       
        for (UIScrollView*view in toolbar.subviews) {
            rect = view.frame;
            rect.size.width = width - 80;
            [view setFrame:rect];
        }

        if (![[_revealView.contentView.subviews lastObject] isKindOfClass:[UITableView class]]) {
            
            //move related list screen's (x,y) 
            rect = screenRelatedList.view.frame;
            rect.size.width = width;
            screenRelatedList.view.frame = rect;
            
            //search bar
            rect = screenRelatedList.dataGrid.searchBar.frame;
            rect.size.width = width - 190;
            screenRelatedList.dataGrid.searchBar.frame = rect;
            
            //table related list
            [screenRelatedList.dataGrid.dataTable reloadData];
            
            //footer related list
            rect = screenRelatedList.dataGrid.toolbarPaging.frame;
            rect.origin.y = (UIInterfaceOrientationIsPortrait(mainOrientation)) ? 860-70-55 : 604-70-55;
            screenRelatedList.dataGrid.toolbarPaging.frame = rect;
            
        } 
        else {
            isFirstLoadRelatedList = NO;
            [self dataTableReloadView];
        } 
    

    [_revealView revealSidebar: ! [_revealView isSidebarShowing]];
    
}


-(void)returnToParentView:(id)sender {
   //   [self.navigationController.navigationBar setHidden:YES];
      [self.navigationController popViewControllerAnimated:YES];
}

-(NSMutableDictionary*) getValueBy:(NSString*)fieldName recordId:(NSString*)recordId {
    
    NSArray *arr;
    Item *tmpItem ;
    
    NSMutableDictionary*result = [[NSMutableDictionary alloc] init]; 
    
    if (![[mapRefName allKeys] containsObject:fieldName]) {
        arr = [FieldInfoManager referenceToEntitiesByField:detail.entity field:fieldName];
        [mapRefName setValue:arr forKey:fieldName];
    }else arr = [mapRefName objectForKey:fieldName];
    
    
    for (NSString*name in arr) {
        if ([[tableNameExist allKeys] containsObject:name]) {
            if ([[tableNameExist objectForKey:name] valueForKey:recordId] != nil) {
                [result setValue:[[tableNameExist objectForKey:name] valueForKey:recordId] forKey:@"Result"];
                [result setValue:name forKey:@"RefName"];
                [result setValue:@"YES" forKey:@"Found"];

                return  result;
            }   
            else {
                tmpItem = [EntityManager find:name column:@"Id" value:recordId];
                [result setValue:name forKey:@"RefName"];
                [result setValue:@"YES" forKey:@"Found"];
                if (tmpItem != nil) {
                    
                    NSMutableDictionary* mapIdName = [[NSMutableDictionary alloc] init];
                    [mapIdName setValue:[tmpItem.fields objectForKey:@"Name"] forKey:recordId];
                    
                    [tableNameExist setValue:mapIdName forKey:name];
                    [mapIdName release];
                    
                   
                    [result setValue:[tmpItem.fields objectForKey:@"Name"] forKey:@"Result"];
                    
                }else 
                   [result setValue:recordId forKey:@"Result"];
                  
                
                
                return result;
                
            }
            
        } else {
            if ([[DatabaseManager getInstance] checkTable:name]) {
                tmpItem = [EntityManager find:name column:@"Id" value:recordId];
                if (tmpItem != nil) {
                    
                    NSMutableDictionary* mapIdName = [[NSMutableDictionary alloc] init];
                    [mapIdName setValue:[tmpItem.fields objectForKey:@"Name"] forKey:recordId];
                    
                    [tableNameExist setValue:mapIdName forKey:name];
                    [mapIdName release];
                    
                    [result setValue:[tmpItem.fields objectForKey:@"Name"] forKey:@"Result"];
                    [result setValue:name forKey:@"RefName"];
                    [result setValue:@"YES" forKey:@"Found"];
                    
                    return result;
                }
            }else{
                [result setValue:recordId forKey:@"Result"];
                [result setValue:name forKey:@"RefName"];
                [result setValue:@"NO" forKey:@"Found"];
                
            }
        }
    }
    
    return result;
}


- (void)pushContentView:(id)sender {
    UIView *subview = [[UIView alloc] initWithFrame:CGRectZero];
    subview.backgroundColor = [UIColor blueColor];
    subview.title           = @"Pushed Subview";
    [_revealView.contentView pushView:subview animated:YES];
    [subview release];
}


@end
