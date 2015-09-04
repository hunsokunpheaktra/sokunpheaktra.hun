//
//  ScreenMergeRecords.m
//  SyncForce
//
//  Created by Gaeasys on 12/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MergeRecordDetail.h"
#import "DatabaseManager.h"
#import "EntityManager.h"
#import "EditLayoutSectionsInfoManager.h"
#import "RecordTypeMappingInfoManager.h"
#import "Section.h"
#import "FieldInfoManager.h"
#import "NumberHelper.h"
#import "DatetimeHelper.h"
#import "MergeRecordPopover.h"


@implementation MergeRecordDetail

@synthesize dataTable;
@synthesize radios;
@synthesize sectionRadio;
@synthesize headers;
@synthesize popoverController;
@synthesize sfItem,localItem;
@synthesize entityName;
@synthesize listRecordsMerge;
@synthesize myToolbar;
@synthesize fieldkeys;

-(id) initWithEntity:(NSString*)entity {
    entityName = entity;
    return self;
}

- (void)dealloc{
    [super dealloc];
    [headers release];
    [fieldkeys release];
    [tmpLocaItem release];
    [tmpSfitem release];
    [layoutItems release];
    [mapSections release];
}

-(void) initView {
    
    // radios = [[NSMutableDictionary alloc] init];
    //  sectionRadio = [[NSMutableDictionary alloc] init];
    headers  = [[NSMutableArray alloc] init];
    fieldkeys = [[NSMutableArray alloc] init];
    
    tmpLocaItem = [[Item alloc] init:entityName fields:localItem.fields];
    tmpSfitem   = [[Item alloc] init:entityName fields:nil];  
    
    //Group items(Field) by heading
    NSMutableArray* sectionNameOrder = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    NSMutableDictionary* filters = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
    layoutItems = [[NSMutableDictionary alloc] initWithCapacity:1];
    mapSections = [[NSMutableDictionary alloc] initWithCapacity:1];
    entityInfo = [InfoFactory getInfo:entityName];
    
    
    NSMutableDictionary *cri = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
    NSArray* tmpLayoutId;
    
    
    if ([[sfItem.fields allKeys] containsObject:@"RecordTypeId"]) {
    
        if ([sfItem.fields objectForKey:@"recordTypeId"] != nil && ![[sfItem.fields objectForKey:@"recordTypeId"] isEqualToString:@""]) {    
            [cri setValue:[[ValuesCriteria alloc] initWithString:[sfItem.fields objectForKey:@"recordTypeId"]] forKey:@"RecordTypeId"];
            [cri setValue:[[ValuesCriteria alloc] initWithString:entityName] forKey:@"entity"];
            tmpLayoutId = [RecordTypeMappingInfoManager list:cri];
    
        }else {
            [cri setValue:[[ValuesCriteria alloc] initWithString:@"012000000000000AAA"] forKey:@"RecordTypeId"];
            [cri setValue:[[ValuesCriteria alloc] initWithString:@"Master"] forKey:@"name"];
            [cri setValue:[[ValuesCriteria alloc] initWithString:entityName] forKey:@"entity"];
            tmpLayoutId = [RecordTypeMappingInfoManager list:cri];
        }

        //[filters setValue:[ValuesCriteria criteriaWithString:entityName] forKey:@"entity"];
        filters = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
        [filters setValue:[ValuesCriteria criteriaWithString:self.entityName] forKey:@"entity"];
        [filters setValue:[ValuesCriteria criteriaWithString:[[[tmpLayoutId objectAtIndex:0] fields] objectForKey:@"layoutId"]] forKey:@"Id"];
        
        } else [filters setValue:[ValuesCriteria criteriaWithString:entityName] forKey:@"entity"];
    
    for(Item *item in [EditLayoutSectionsInfoManager list:filters]){
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
        Section *section = [[Section alloc] initWithName:heading];
        for(Item *item in [mapSections valueForKey:heading]){
            NSString *fieldname = [item.fields valueForKey:@"value"];
            if ([[[localItem fields] allKeys] containsObject:fieldname]) {
               if ([[sfItem fields] objectForKey:fieldname] !=(id)kCFNull || [[[localItem fields] objectForKey:fieldname] length] >0) {
                   NSString* valueSf = [[sfItem fields] objectForKey:fieldname];
                   NSString* valueLocal  = [[localItem fields] objectForKey:fieldname];
                   Item *info = [entityInfo getFieldInfoByName:fieldname];
                   NSString *fieldType = [info.fields objectForKey:@"type"];
                   
                   if ([fieldType isEqualToString:@"currency"]) {
                       if ([[sfItem fields] objectForKey:fieldname] !=(id)kCFNull) { 
                           valueSf = [NumberHelper formatCurrencyValue:[valueSf doubleValue]];
                       }   
                       valueLocal  = [NumberHelper formatCurrencyValue:[valueLocal doubleValue]];
                   }
                   
                   if ([fieldType isEqualToString:@"double"]) {
                       if (valueSf != (id)kCFNull) {
                           valueSf = [NumberHelper formatNumberDisplay:[valueSf doubleValue]];
                       }else valueSf = @"" ;
                       
                       valueLocal = [NumberHelper formatNumberDisplay:[valueLocal doubleValue]];
                   }
                   
                   if ([fieldType isEqualToString:@"percent"]) {
                       if (valueSf != (id)kCFNull) {
                           valueSf = [NumberHelper formatPercentValue:[valueSf doubleValue]];
                       }else valueSf = @"" ;
                       
                       valueLocal = [NumberHelper formatPercentValue:[valueLocal doubleValue]];
                   }
                   
                   
                   if (![valueLocal isEqualToString:valueSf]) {
                       [section.fields addObject:fieldname];
                       [layoutItems setValue:item forKey:fieldname];
                   }    
               }   
            }
            
        }
        
        if ([section.fields count]>0) {
            [detailSections addObject:section];
        }
        
    }
    
    sections = [detailSections copy];
    
    for (int i =0; i<[sections count]; i++) {
        [headers insertObject:[[[UIView alloc] init] autorelease] atIndex:i];
    }
 
}

-(UIView*) titleView {
    
    myToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    myToolbar.tintColor = [UIColor colorWithRed:(42.0/255.0) green:(192.0/255.0) blue:(235.0/255.0) alpha:1];
    
    UIButton* names = [UIButton buttonWithType:UIButtonTypeCustom];
    [names setTitle:NSLocalizedString(@"FIELD_NAME", @"Field Name") forState:UIControlStateNormal];
    names.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    names.frame = CGRectMake(0, 0,(self.myToolbar.frame.size.width/3)-20, 50); //230
    
    UIButton* sp1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [sp1 setBackgroundColor:[UIColor grayColor]];
    sp1.frame = CGRectMake((self.myToolbar.frame.size.width/3)-20, 0, 1, 50);//230
    
    UIButton* local = [UIButton buttonWithType:UIButtonTypeCustom];
    [local setTitle:NSLocalizedString(@"LOCAL_RECORD", @"Local") forState:UIControlStateNormal];
    local.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    local.frame = CGRectMake((self.myToolbar.frame.size.width/3)-19, 0, (self.myToolbar.frame.size.width/3)-20, 50); //231
    
    UIButton* sp2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [sp2 setBackgroundColor:[UIColor grayColor]];
    sp2.frame = CGRectMake(2*(self.myToolbar.frame.size.width/3)-39, 0, 1, 50); //473
    
    UIButton* sf = [UIButton buttonWithType:UIButtonTypeCustom];
    [sf setTitle:NSLocalizedString(@"REMOTE_RECORD", @"Remote") forState:UIControlStateNormal];
    sf.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    sf.frame = CGRectMake(2*(self.myToolbar.frame.size.width/3)-38, 0, (self.myToolbar.frame.size.width/3)-20, 50);
    
    UIBarButtonItem* space1  = [[[UIBarButtonItem alloc] initWithCustomView:sp1] autorelease]; 
    UIBarButtonItem* space2  = [[[UIBarButtonItem alloc] initWithCustomView:sp2] autorelease];
    UIBarButtonItem* fieldNames = [[[UIBarButtonItem alloc] initWithCustomView:names] autorelease];
    UIBarButtonItem* localRocord = [[[UIBarButtonItem alloc] initWithCustomView:local] autorelease];
    UIBarButtonItem* sfRocord = [[[UIBarButtonItem alloc] initWithCustomView:sf] autorelease];

    myToolbar.items = [NSArray arrayWithObjects:fieldNames,space1,localRocord,space2,sfRocord, nil];    
    
    return myToolbar;
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad{
    self.title = NSLocalizedString(@"RECORDS_MERGE", @"Records to merge");
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:(23.0/255.0) green:(155.0/255.0) blue:(192.0/255.0) alpha:1]];
    
    UIView *mainscreen = [[UIView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    
    dataTable = [[[UITableView alloc] initWithFrame:CGRectMake(0,50,mainscreen.frame.size.width, mainscreen.frame.size.height-100) style:UITableViewStylePlain] autorelease];
    dataTable.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    dataTable.allowsSelection = NO;
    dataTable.delegate = self;
    dataTable.dataSource = self; 
    
    UIImageView *background = [[[UIImageView alloc] initWithFrame:dataTable.frame] autorelease];
    background.image = [UIImage imageNamed:@"gridGradient.png"];
    background.contentMode = UIViewContentModeScaleToFill;
    dataTable.backgroundView = background;
    
    [mainscreen addSubview:[self titleView]];
    [mainscreen addSubview:dataTable];
    
    self.view = mainscreen;
    
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

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    UIInterfaceOrientation orient = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (UIInterfaceOrientationIsPortrait(orient)){
        
        [self viewDidLoad];
    }else{
        
        [self viewDidLoad];
    }
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    if (localItem != nil) return [sections count];
    else return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if (localItem != nil) return [[[sections objectAtIndex:section] fields] count];
    else return 0;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath: indexPath];
    
    float height = 44;
    
    for (UILabel* view in cell.contentView.subviews) {
        if ([view isKindOfClass:[UITextView class]]) {
            
            UIFont *font = [UIFont fontWithName:@"Helvetica" size:14.0];
            CGSize constraintSize = CGSizeMake(780.0, MAXFLOAT); //280
            CGSize bounds = [view.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
            
            height = MAX((44 + bounds.height), height);
            
            return height;
            
        }else height = 54;   
        
    }
    
    
    return height;

}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    
    UIView *hdrView = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.dataTable.frame.size.width, 48)];
    hdrView.backgroundColor = [UIColor colorWithRed:(208.0/255.0) green:(238.0/255.0) blue:(248.0/255.0) alpha:1]; 
    hdrView.layer.cornerRadius = 2;
    
    UIImageView *seperat = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sectionHeaderUnderline.png"]];
    seperat.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    seperat.frame = CGRectMake(0, 48+1, hdrView.frame.size.width, 4);
    
    UIButton *button =[[UIButton alloc]initWithFrame:CGRectMake(20, 10, 30, 30)];
    button.tag = section;
    [button setBackgroundImage:[UIImage imageNamed:[[[sections objectAtIndex:section] fields] count] > 0 ? @"arrow_down.png" : @"arrow_right.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickToCollape:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(54, 0, self.dataTable.frame.size.width/3 -54, 48)]; //400
    label.font = [UIFont boldSystemFontOfSize:18];
    label.textAlignment = UITextAlignmentLeft;
    label.highlightedTextColor = [UIColor whiteColor];
    label.textColor = [UIColor darkGrayColor];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0, 1);
    label.backgroundColor = [UIColor clearColor];
    label.text = [[sections objectAtIndex:section] name];
    
    
    UIButton *btLocal = [[UIButton alloc]initWithFrame:CGRectMake(self.dataTable.frame.size.width/3, 0, 40, 48)];
    [btLocal addTarget:self action:@selector(radiosButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    btLocal.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btLocal.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    btLocal.tag = section;
    [[btLocal layer] setValue:@"1" forKey:@"indexSection"]; 
    [btLocal setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btLocal.titleLabel.font =[UIFont systemFontOfSize:14.f];
    
    
    UIButton *btSf = [[UIButton alloc]initWithFrame:CGRectMake(2*(self.dataTable.frame.size.width/3), 0, 40, 48)];
    [btSf addTarget:self action:@selector(radiosButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    btSf.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btSf.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    btSf.tag = section;
    [[btSf layer] setValue:@"2" forKey:@"indexSection"]; 
    [btSf setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btSf.titleLabel.font =[UIFont systemFontOfSize:14.f];
    
    if ([[[headers objectAtIndex:section] subviews] count] != 0) {
        btLocal = [[[headers objectAtIndex:section] subviews] objectAtIndex:3];
        btSf = [[[headers objectAtIndex:section] subviews] objectAtIndex:5];
        
        btLocal.frame = CGRectMake(self.dataTable.frame.size.width/3, 0, 40, 48);
        btSf.frame = CGRectMake(2*(self.dataTable.frame.size.width/3), 0, 40, 48);
    }else {
        NSArray* tmp = [sectionRadio objectForKey:[NSString stringWithFormat:@"%d", section]];
        if ([tmp count] > 0) {
            if ([[[[sectionRadio objectForKey:[NSString stringWithFormat:@"%d",section]] objectAtIndex:0] imageView] image] == [UIImage imageNamed:@"radio-off.png"] && [[[[sectionRadio objectForKey:[NSString stringWithFormat:@"%d",section]] objectAtIndex:1] imageView] image] == [UIImage imageNamed:@"radio-on.png"]) {
                
                [btLocal setImage:[UIImage imageNamed:@"radio-off.png"] forState:UIControlStateNormal];
                [btSf setImage:[UIImage imageNamed:@"radio-on.png"] forState:UIControlStateNormal];
                
            }else if ([[[[sectionRadio objectForKey:[NSString stringWithFormat:@"%d",section]] objectAtIndex:0] imageView] image] == [UIImage imageNamed:@"radio-on.png"] && [[[[sectionRadio objectForKey:[NSString stringWithFormat:@"%d",section]] objectAtIndex:1] imageView] image] == [UIImage imageNamed:@"radio-off.png"]) {
                
                [btLocal setImage:[UIImage imageNamed:@"radio-on.png"] forState:UIControlStateNormal];
                [btSf setImage:[UIImage imageNamed:@"radio-off.png"] forState:UIControlStateNormal];
            }else {
                [btLocal setImage:[UIImage imageNamed:@"radio-off.png"] forState:UIControlStateNormal];
                [btSf setImage:[UIImage imageNamed:@"radio-off.png"] forState:UIControlStateNormal];
            }
        }else {
            [btLocal setImage:[UIImage imageNamed:@"radio-off.png"] forState:UIControlStateNormal];
            [btSf setImage:[UIImage imageNamed:@"radio-off.png"] forState:UIControlStateNormal];
        }
        
    }
    
    UILabel* text1 = [[UILabel alloc] initWithFrame:CGRectMake(40+ self.dataTable.frame.size.width/3, 0,self.dataTable.frame.size.width/3 - 40, 48)];
    text1.backgroundColor = [UIColor clearColor];
    text1.text = NSLocalizedString(@"SELECT_ALL_RECORDS", @"Select all in this section");
    
    UILabel* text2 = [[UILabel alloc] initWithFrame:CGRectMake(40+ 2*(self.dataTable.frame.size.width/3), 0,self.dataTable.frame.size.width/3 - 40, 48)];
    text2.backgroundColor = [UIColor clearColor];
    text2.text =  NSLocalizedString(@"SELECT_ALL_RECORDS", @"Select all in this section");
    
    NSDictionary* tmp = [NSDictionary dictionaryWithObjectsAndKeys:[[NSArray alloc] initWithObjects:btLocal,btSf, nil], [NSString stringWithFormat:@"%d", section],nil];
    [sectionRadio addEntriesFromDictionary:tmp];
    
    [hdrView addSubview:button];
    [hdrView addSubview:label];
    [hdrView addSubview:seperat];
    [hdrView addSubview:btLocal];
    [hdrView addSubview:text1];
    [hdrView addSubview:btSf];
    [hdrView addSubview:text2];
    
    [headers replaceObjectAtIndex:section withObject:hdrView];
    
    return hdrView;
    
}

- (void)clickToCollape:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    NSMutableArray *indexes = [[NSMutableArray alloc] initWithCapacity:1];
    
    if ([[[sections objectAtIndex:button.tag] fields] count] > 0) {
        [button setBackgroundImage:[UIImage imageNamed:@"arrow_right.png"] forState:UIControlStateNormal];
        for (int i = 0; i < [[[sections objectAtIndex:button.tag] fields] count]; i++) {
            [indexes addObject:[NSIndexPath indexPathForRow:i inSection:button.tag]];
            
        }
        
        //  [list removeAllObjects]; // must delete before animating
        [[[sections objectAtIndex:button.tag] fields] removeAllObjects];
        [self.dataTable deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];    
        [self.dataTable reloadData];
    } else {
        // must add before animating
        //[list addObjectsFromArray:[self fillSectionData:button.tag]];
        
        NSString *heading = [[sections objectAtIndex:button.tag] name];
        
        Section *section = [[Section alloc] initWithName:heading];
        for(Item *item in [mapSections valueForKey:heading]){
            NSString *fieldname = [item.fields valueForKey:@"value"];
            if ([[[localItem fields] allKeys] containsObject:fieldname]) {
                if ([[sfItem fields] objectForKey:fieldname] !=(id)kCFNull || [[[localItem fields] objectForKey:fieldname] length] >0) {
                    NSString* valueSf = [[sfItem fields] objectForKey:fieldname];
                    NSString* valueLocal  = [[localItem fields] objectForKey:fieldname];
                    Item *info = [entityInfo getFieldInfoByName:fieldname];
                    NSString *fieldType = [info.fields objectForKey:@"type"];
                    
                    if ([fieldType isEqualToString:@"currency"]) {
                        if ([[sfItem fields] objectForKey:fieldname] !=(id)kCFNull) { 
                            valueSf = [NumberHelper formatCurrencyValue:[valueSf doubleValue]];
                        }   
                        valueLocal  = [NumberHelper formatCurrencyValue:[valueLocal doubleValue]];
                    }
                    
                    if ([fieldType isEqualToString:@"double"]) {
                        if (valueSf != (id)kCFNull) {
                            valueSf = [NumberHelper formatNumberDisplay:[valueSf doubleValue]];
                        }else valueSf = @"" ;
                        
                        valueLocal = [NumberHelper formatNumberDisplay:[valueLocal doubleValue]];
                    }
                    
                    if ([fieldType isEqualToString:@"percent"]) {
                        if (valueSf != (id)kCFNull) {
                            valueSf = [NumberHelper formatPercentValue:[valueSf doubleValue]];
                        }else valueSf = @"" ;
                        
                        valueLocal = [NumberHelper formatPercentValue:[valueLocal doubleValue]];
                    }
                    
                    
                    if (![valueLocal isEqualToString:valueSf]) {
                        [section.fields addObject:fieldname];
                        [layoutItems setValue:item forKey:fieldname];
                    }    
                }   
            }
            
        }
        
        
        NSMutableArray *tmp = [NSMutableArray arrayWithArray:sections];
        [tmp removeObjectAtIndex:button.tag];
        [tmp insertObject:section atIndex:button.tag];
        
        sections = [tmp copy];
        
        for (int i = 0; i < [[[sections objectAtIndex:button.tag] fields] count]; i++) {
            [indexes addObject:[NSIndexPath indexPathForRow:i inSection:button.tag]];
        }
        
        [self.dataTable insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];
        [self.dataTable reloadData];
        if ([[[sections objectAtIndex:button.tag] fields] count] > 0) {
            [button setBackgroundImage:[UIImage imageNamed:@"arrow_down.png"] forState:UIControlStateNormal];
        }
        
    }
    
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    //}
    
    int index = 0;
    for (int i=0; i< indexPath.section; i++) {
        index=[[[sections objectAtIndex:indexPath.section-i-1] fields] count]+index;
    }
   
    // Configure the cell...
    Section *section = [sections objectAtIndex:indexPath.section];
    NSString *fieldname = [section.fields objectAtIndex:indexPath.row];
    Item *fieldInfo = [layoutItems valueForKey:fieldname];
    Item *info = [entityInfo getFieldInfoByName:fieldname];
    NSString *fieldType = [info.fields objectForKey:@"type"];
    
    NSString* rowKey = fieldname ;//[NSString stringWithFormat:@"%d%d", indexPath.row,indexPath.section];
    [fieldkeys addObject:fieldname];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, tableView.rowHeight)];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, self.dataTable.frame.size.width/3 -50, tableView.rowHeight)]; //214
    label.text = [fieldInfo.fields valueForKey:@"label"];
    [label setBackgroundColor:[UIColor clearColor]];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont boldSystemFontOfSize:14];
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.textAlignment = UITextAlignmentRight;
    label.numberOfLines = 0;
    
    [view addSubview:label];
    
    
    UIButton *btLocal = [[UIButton alloc]initWithFrame:CGRectMake((tableView.frame.size.width)/3, 0, 40, tableView.rowHeight)];
    [btLocal addTarget:self action:@selector(radioButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    btLocal.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btLocal.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    btLocal.tag = indexPath.row + index;//edit
    
    if ([[[[sectionRadio objectForKey:[NSString stringWithFormat:@"%d",indexPath.section]] objectAtIndex:0] imageView] image] == [UIImage imageNamed:@"radio-off.png"]) {
        if ([radios objectForKey:rowKey] == nil) {
            [btLocal setImage:[UIImage imageNamed:@"radio-off.png"] forState:UIControlStateNormal];
        }else {
            UIButton* tmp = [[radios objectForKey:rowKey] objectAtIndex:0];
            if (tmp.imageView.image == [UIImage imageNamed:@"radio-off.png"]) {
                [btLocal setImage:[UIImage imageNamed:@"radio-off.png"] forState:UIControlStateNormal];
            }else [btLocal setImage:[UIImage imageNamed:@"radio-on.png"] forState:UIControlStateNormal];
        }
    }    
    else [btLocal setImage:[UIImage imageNamed:@"radio-on.png"] forState:UIControlStateNormal];
    
    [btLocal setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btLocal.titleLabel.font =[UIFont systemFontOfSize:14.f];
    [[btLocal layer] setValue:[NSArray arrayWithObjects:@"1",[NSString stringWithFormat:@"%d",indexPath.section], nil] forKey:@"index"]; 
    
    [view addSubview:btLocal];
    
    
    UILabel* local = [[UILabel alloc] initWithFrame:CGRectMake(40+(tableView.frame.size.width)/3, 0, (tableView.frame.size.width)/3 -40, tableView.rowHeight)];    
    NSString *value ;
    
    if ([[localItem fields] objectForKey:fieldname] == NULL) {
        value = @"";
    }else value = [[localItem fields] objectForKey:fieldname];
    
    if ([fieldType isEqualToString:@"currency"]) {
        value = [NumberHelper formatCurrencyValue:[value doubleValue]];
    }else if ([fieldType isEqualToString:@"double"] || [fieldType isEqualToString:@"int"]) {
        value = [NumberHelper formatNumberDisplay:[value doubleValue]];
    }else if([fieldType isEqualToString:@"percent"]) {
        value = [NumberHelper formatPercentValue:[value doubleValue]];
    }else if([fieldType isEqualToString:@"date"] || [fieldType isEqualToString:@"datetime"]) {
        value = [DatetimeHelper display:value];
    }else if([fieldType isEqualToString:@"reference"]){
        
        NSArray *arr = [FieldInfoManager referenceToEntitiesByField:entityName field:fieldname];
        Item *item = [EntityManager find:[arr objectAtIndex:0] column:@"Id" value:value];
        value = [item.fields objectForKey:@"Name"];
        
    }
    
    
    local.text = value;    
    [local setBackgroundColor:[UIColor clearColor]];
    local.lineBreakMode = UILineBreakModeWordWrap;
    local.numberOfLines = 0;
    
    if([fieldType isEqualToString:@"boolean"]) {
        UIButton *checkBox = [UIButton buttonWithType:UIButtonTypeCustom];
        [checkBox setFrame:CGRectMake(40+(tableView.frame.size.width)/3, 10, 50, 24)];
        [checkBox setImage:[UIImage imageNamed:@"checkBoxChecked"] forState:UIControlStateNormal];
        
        if([local.text isEqualToString:@""]||[local.text isEqualToString:@"0"]||[local.text isEqualToString:@"false"]||[local.text isEqualToString:@"NO"]){
            [checkBox setImage:[UIImage imageNamed:@"checkBoxUnchecked"] forState:UIControlStateNormal];   
        }
        
        [view addSubview:checkBox];
        
    } else [view addSubview:local];
    
    
    UIButton *btSf = [[UIButton alloc]initWithFrame:CGRectMake(2* (tableView.frame.size.width)/3, 0, 40, tableView.rowHeight)];
    [btSf addTarget:self action:@selector(radioButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    btSf.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btSf.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    btSf.tag = indexPath.row + index;
    
    if ([[[[sectionRadio objectForKey:[NSString stringWithFormat:@"%d",indexPath.section]] objectAtIndex:1] imageView] image] == [UIImage imageNamed:@"radio-off.png"]) {
        if ([radios objectForKey:rowKey] == nil) {
            [btSf setImage:[UIImage imageNamed:@"radio-off.png"] forState:UIControlStateNormal];
        }else {
            UIButton* tmp = [[radios objectForKey:rowKey] objectAtIndex:1];
            if (tmp.imageView.image == [UIImage imageNamed:@"radio-off.png"]) {
                [btSf setImage:[UIImage imageNamed:@"radio-off.png"] forState:UIControlStateNormal];
            }else [btSf setImage:[UIImage imageNamed:@"radio-on.png"] forState:UIControlStateNormal];
        }
    }    
    else [btSf setImage:[UIImage imageNamed:@"radio-on.png"] forState:UIControlStateNormal];
    
    [btSf setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btSf.titleLabel.font =[UIFont systemFontOfSize:14.f];
    [[btSf layer] setValue:[NSArray arrayWithObjects:@"2",[NSString stringWithFormat:@"%d",indexPath.section] ,nil] forKey:@"index"]; 
    
    [view addSubview:btSf];
    
    UILabel* sf = [[UILabel alloc] initWithFrame:CGRectMake(40+ 2*(tableView.frame.size.width)/3, 0, (tableView.frame.size.width)/3 - 40, tableView.rowHeight)];
    
    if ([sfItem.fields objectForKey:fieldname] !=(id)kCFNull) {
        sf.text = [sfItem.fields objectForKey:fieldname];
    }else  sf.text = @"";
    
    if ([fieldType isEqualToString:@"currency"]) {
        sf.text = [NumberHelper formatCurrencyValue:[sf.text doubleValue]];
    }else if ([fieldType isEqualToString:@"double"] || [fieldType isEqualToString:@"int"]) {
        sf.text = [NumberHelper formatNumberDisplay:[sf.text doubleValue]];
    }else if([fieldType isEqualToString:@"percent"]) {
        sf.text = [NumberHelper formatPercentValue:[sf.text doubleValue]];
    }else if([fieldType isEqualToString:@"date"] || [fieldType isEqualToString:@"datetime"]) {
        sf.text = [DatetimeHelper display:sf.text];
    }else if([fieldType isEqualToString:@"reference"]){
        NSArray *arr = [FieldInfoManager referenceToEntitiesByField:entityName field:fieldname];
        Item *item = [EntityManager find:[arr objectAtIndex:0] column:@"Id" value:sf.text];
        sf.text = [item.fields objectForKey:@"Name"];
        
    }
    
    [sf setBackgroundColor:[UIColor clearColor]];
    sf.lineBreakMode = UILineBreakModeWordWrap; 
    sf.numberOfLines = 0;
    
    if([fieldType isEqualToString:@"boolean"]) {
        UIButton *checkBox = [UIButton buttonWithType:UIButtonTypeCustom];
        [checkBox setFrame:CGRectMake(40+ 2*(tableView.frame.size.width)/3, 10, 50, 24)];
        [checkBox setImage:[UIImage imageNamed:@"checkBoxChecked"] forState:UIControlStateNormal];
        
        if([sf.text isEqualToString:@""]||[sf.text isEqualToString:@"0"]||[sf.text isEqualToString:@"false"]||[sf.text isEqualToString:@"NO"]){
            [checkBox setImage:[UIImage imageNamed:@"checkBoxUnchecked"] forState:UIControlStateNormal];   
        }
        
        [view addSubview:checkBox];
        
    } else [view addSubview:sf];
    
    
    if ([[btLocal imageView] image] == [UIImage imageNamed:@"radio-on.png"] && [[btSf imageView] image] == [UIImage imageNamed:@"radio-off.png"] ) 
    {
        [tmpLocaItem.fields setObject:local.text forKey:fieldname];
    }else if  ([[btLocal imageView] image] == [UIImage imageNamed:@"radio-off.png"] && [[btSf imageView] image] == [UIImage imageNamed:@"radio-on.png"] )
    {
        
        if (sf.text == (id)kCFNull || sf.text == NULL) {
            sf.text = @"" ;
        } 
        
         [tmpLocaItem.fields setObject:sf.text forKey:fieldname];
    }
    
    NSDictionary* tmp = [NSDictionary dictionaryWithObjectsAndKeys:[[[NSArray alloc] initWithObjects:btLocal,btSf, nil] autorelease],rowKey, nil];
    
    [radios addEntriesFromDictionary:tmp];
    
    [cell.contentView addSubview:view];
    
    
    return cell;
}


- (void)splitViewController:(MGSplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController: (UIPopoverController *)pc
{
    barButtonItem.title = NSLocalizedString(@"LIST", Nil); // TODO Translate
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
    self.popoverController = pc;
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController:(MGSplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self.navigationItem setLeftBarButtonItem:nil];
    self.popoverController = nil;
}


-(IBAction) radioButtonClicked:(UIButton *) sender{
   
    if ([[[sender layer] valueForKey:@"index"] objectAtIndex:0] == @"1") {
        [sender setImage:[UIImage imageNamed:@"radio-on.png"] forState:UIControlStateNormal];
        NSArray* array = [radios objectForKey:[fieldkeys objectAtIndex:sender.tag]];
       [[array objectAtIndex:1] setImage:[UIImage imageNamed:@"radio-off.png"] forState:UIControlStateNormal];

      
        for (NSString* field in [[sections objectAtIndex:[[[[sender layer] valueForKey:@"index"] objectAtIndex:1] intValue]] fields]) {
            
            if ([fieldkeys containsObject:field]) {
                
                NSArray* tmp = [radios objectForKey:field];
                if ([[[tmp objectAtIndex:0] imageView] image] == [UIImage imageNamed:@"radio-off.png"]) {
                    [[[sectionRadio objectForKey:[[[sender layer] valueForKey:@"index"] objectAtIndex:1]] objectAtIndex:0] setImage:[UIImage imageNamed:@"radio-off.png"] forState:UIControlStateNormal];
                    [[[sectionRadio objectForKey:[[[sender layer] valueForKey:@"index"] objectAtIndex:1]] objectAtIndex:1] setImage:[UIImage imageNamed:@"radio-off.png"] forState:UIControlStateNormal];
                    break;
                }else {
                    [[[sectionRadio objectForKey:[[[sender layer] valueForKey:@"index"] objectAtIndex:1]] objectAtIndex:0] setImage:[UIImage imageNamed:@"radio-on.png"] forState:UIControlStateNormal];
                    [[[sectionRadio objectForKey:[[[sender layer] valueForKey:@"index"] objectAtIndex:1]] objectAtIndex:1] setImage:[UIImage imageNamed:@"radio-off.png"] forState:UIControlStateNormal];
                } 
            }
            
        }
        
        Item *info = [entityInfo getFieldInfoByName:[fieldkeys objectAtIndex:sender.tag]];
        NSString *fieldType = [info.fields objectForKey:@"type"];
        NSString* value = [localItem.fields objectForKey:[fieldkeys objectAtIndex:sender.tag]];
        
        if([fieldType isEqualToString:@"reference"]){
            NSArray *arr = [FieldInfoManager referenceToEntitiesByField:entityName field:[fieldkeys objectAtIndex:sender.tag]];
            Item *item = [EntityManager find:[arr objectAtIndex:0] column:@"Name" value:value];
            [[tmpLocaItem fields] setValue:[item.fields objectForKey:@"Id"] forKey:[fieldkeys objectAtIndex:sender.tag]];
        }else{
            [[tmpLocaItem fields] setValue:value forKey:[fieldkeys objectAtIndex:sender.tag]];
        }
        
    }else{
        [sender setImage:[UIImage imageNamed:@"radio-on.png"] forState:UIControlStateNormal];
        NSArray* array = [radios objectForKey:[fieldkeys objectAtIndex:sender.tag]];
        [[array objectAtIndex:0] setImage:[UIImage imageNamed:@"radio-off.png"] forState:UIControlStateNormal];
        
        for (NSString* field in [[sections objectAtIndex:[[[[sender layer] valueForKey:@"index"] objectAtIndex:1] intValue]] fields]) {
            
            if ([fieldkeys containsObject:field]) {
                
                NSArray* tmp = [radios objectForKey:field];
                if ([[[tmp objectAtIndex:1] imageView] image] == [UIImage imageNamed:@"radio-off.png"]) {
                    [[[sectionRadio objectForKey:[[[sender layer] valueForKey:@"index"] objectAtIndex:1]] objectAtIndex:0] setImage:[UIImage imageNamed:@"radio-off.png"] forState:UIControlStateNormal];
                    [[[sectionRadio objectForKey:[[[sender layer] valueForKey:@"index"] objectAtIndex:1]] objectAtIndex:1] setImage:[UIImage imageNamed:@"radio-off.png"] forState:UIControlStateNormal];
                    break;
                }else {
                    [[[sectionRadio objectForKey:[[[sender layer] valueForKey:@"index"] objectAtIndex:1]] objectAtIndex:1] setImage:[UIImage imageNamed:@"radio-on.png"] forState:UIControlStateNormal];
                    [[[sectionRadio objectForKey:[[[sender layer] valueForKey:@"index"] objectAtIndex:1]] objectAtIndex:0] setImage:[UIImage imageNamed:@"radio-off.png"] forState:UIControlStateNormal];
                }
            }    
        }
        
        Item *info = [entityInfo getFieldInfoByName:[fieldkeys objectAtIndex:sender.tag]];
        NSString *fieldType = [info.fields objectForKey:@"type"];
        NSString* value ;
        if ([sfItem.fields objectForKey:[fieldkeys objectAtIndex:sender.tag]] == (id)kCFNull) {
            value = @"";
        }else  value = [sfItem.fields objectForKey:[fieldkeys objectAtIndex:sender.tag]];
        
        
        if([fieldType isEqualToString:@"reference"]){
            NSArray *arr = [FieldInfoManager referenceToEntitiesByField:entityName field:[fieldkeys objectAtIndex:sender.tag]];
            Item *item = [EntityManager find:[arr objectAtIndex:0] column:@"Name" value:value];
            [[tmpLocaItem fields] setValue:[item.fields objectForKey:@"Id"] forKey:[fieldkeys objectAtIndex:sender.tag]];
        }else{
            [[tmpLocaItem fields] setValue:value forKey:[fieldkeys objectAtIndex:sender.tag]];
        }
        
    }
    
    
    [listRecordsMerge mergeClick:sectionRadio radios:radios itemMerge:tmpLocaItem]; 
}



-(IBAction) radiosButtonClicked:(UIButton *) sender{
    
    
    if ([[sender layer] valueForKey:@"indexSection"] == @"1") {
        [sender setImage:[UIImage imageNamed:@"radio-on.png"] forState:UIControlStateNormal];
        NSArray* array = [sectionRadio objectForKey:[NSString stringWithFormat:@"%d", sender.tag]];
        [[array objectAtIndex:1] setImage:[UIImage imageNamed:@"radio-off.png"] forState:UIControlStateNormal];
        
        for (NSString* field in [[sections objectAtIndex:sender.tag] fields]) {
            if ([fieldkeys containsObject:field]) {
                
                NSArray* tmp = [radios objectForKey:field];
                
                [[tmp objectAtIndex:0] setImage:[UIImage imageNamed:@"radio-on.png"] forState:UIControlStateNormal];
                [[tmp objectAtIndex:1] setImage:[UIImage imageNamed:@"radio-off.png"] forState:UIControlStateNormal];
            }
        }
        
        for (NSString* field in fieldkeys) {
            if ( [[[[radios objectForKey:field] objectAtIndex:0] imageView] image] == [UIImage imageNamed:@"radio-on.png"])
            { 
                Item *info = [entityInfo getFieldInfoByName:field];
                NSString *fieldType = [info.fields objectForKey:@"type"];
                NSString* value = [localItem.fields objectForKey:field];
                
                if([fieldType isEqualToString:@"reference"]){
                    NSArray *arr = [FieldInfoManager referenceToEntitiesByField:entityName field:field];
                    Item *item = [EntityManager find:[arr objectAtIndex:0] column:@"Name" value:value];
                    [[tmpLocaItem fields] setValue:[item.fields objectForKey:@"Id"] forKey:field];
                }else{
                    [[tmpLocaItem fields] setValue:value forKey:field];
                }
                
            }    
            
        }
        
    }
    else{
        
        [sender setImage:[UIImage imageNamed:@"radio-on.png"] forState:UIControlStateNormal];
        NSArray* array = [sectionRadio objectForKey:[NSString stringWithFormat:@"%d", sender.tag]];
        [[array objectAtIndex:0] setImage:[UIImage imageNamed:@"radio-off.png"] forState:UIControlStateNormal];
        
        for (NSString* field in [[sections objectAtIndex:sender.tag] fields]) {
            if ([fieldkeys containsObject:field]) {
                NSArray* tmp = [radios objectForKey:field];
                [[tmp objectAtIndex:1] setImage:[UIImage imageNamed:@"radio-on.png"] forState:UIControlStateNormal];
                [[tmp objectAtIndex:0] setImage:[UIImage imageNamed:@"radio-off.png"] forState:UIControlStateNormal];
            }    
        }
        
        
        for (NSString* field in fieldkeys) {
            
            if ( [[[[radios objectForKey:field] objectAtIndex:1] imageView] image] == [UIImage imageNamed:@"radio-on.png"]){
                
                Item *info = [entityInfo getFieldInfoByName:field];
                NSString *fieldType = [info.fields objectForKey:@"type"];
                NSString* value ;
                
                if ([sfItem.fields objectForKey:field] == (id)kCFNull) {
                    value = @"";
                }else  value = [sfItem.fields objectForKey:field];
                
                
                if([fieldType isEqualToString:@"reference"]){
                    NSArray *arr = [FieldInfoManager referenceToEntitiesByField:entityName field:field];
                    Item *item = [EntityManager find:[arr objectAtIndex:0] column:@"Name" value:value];
                    [[tmpLocaItem fields] setValue:[item.fields objectForKey:@"Id"] forKey:field];
                }else{
                    [[tmpLocaItem fields] setValue:value forKey:field];
                }
                
            } 
        }
        
        
    }
    
    [listRecordsMerge mergeClick:sectionRadio radios:radios itemMerge:tmpLocaItem]; 
    
}



@end
