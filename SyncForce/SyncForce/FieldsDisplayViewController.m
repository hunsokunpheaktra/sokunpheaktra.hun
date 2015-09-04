//
//  FieldsDisplayViewController.m
//  SyncForce
//
//  Created by Gaeasys on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FieldsDisplayViewController.h"
#import "FilterFieldManager.h"
#import "ValuesCriteria.h"
#import "FieldInfoManager.h"
#import "EntityManager.h"
#import "DataType.h"
#import "RecordTypeMappingInfoManager.h"
#import "EditLayoutSectionsInfoManager.h"
#import "DetailLayoutSectionsInfoManager.h"


@implementation FieldsDisplayViewController

- (id)initWithEntity:(NSString*)newEntity parentView:(id)parent {
    
    self = [super init];
    entity = newEntity;
    parentView = parent;
    
    self.tableView = [[[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UIView* view = [[[UIView alloc] init] autorelease];
    [view setBackgroundColor:[UIColor colorWithRed:(208.0/255.0) green:(238.0/255.0) blue:(248.0/255.0) alpha:1]];
    self.tableView.backgroundView = view;
    
    UIBarButtonItem *bntSave = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SAVE", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(saveField:)] autorelease];
    self.navigationItem.rightBarButtonItem = bntSave;
    
    UIBarButtonItem *bntCancel = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)] autorelease];
    self.navigationItem.leftBarButtonItem = bntCancel;

    NSMutableDictionary *localCriteria = [[[NSMutableDictionary alloc] init] autorelease];
    [localCriteria setValue:[[[ValuesCriteria alloc] initWithString:entity] autorelease] forKey:@"objectName"];
    
    arrayFieldDisplay = [[NSMutableArray alloc] initWithArray:[FilterFieldManager list:localCriteria]];
        
    NSMutableDictionary *cri = [[NSMutableDictionary alloc] init];
    [cri setValue:[[ValuesCriteria alloc] initWithString:@"012000000000000AAA"] forKey:@"RecordTypeId"];
    [cri setValue:[[ValuesCriteria alloc] initWithString:@"Master"] forKey:@"name"];
    [cri setValue:[[ValuesCriteria alloc] initWithString:entity] forKey:@"entity"];
    Item*layout = [RecordTypeMappingInfoManager find:cri];
    
    [cri removeAllObjects];
    [cri setValue:[ValuesCriteria criteriaWithString:entity] forKey:@"entity"];
    if([[[layout fields] objectForKey:@"layoutId"] length]>0)
        [cri setValue:[ValuesCriteria criteriaWithString:[[layout fields] objectForKey:@"layoutId"]] forKey:@"Id"];
    
    NSArray*tmpLayout = [EditLayoutSectionsInfoManager list:cri];
    NSMutableDictionary*dic = [[NSMutableDictionary alloc] init];
    
    for (Item*item in tmpLayout) {
        [dic setValue:[item.fields objectForKey:@"label"] forKey:[item.fields objectForKey:@"value"]];
    }
    
    [cri removeAllObjects];
    [cri setValue:[ValuesCriteria criteriaWithString:entity] forKey:@"entity"];
    [cri setValue:[ValuesCriteria criteriaWithString:[[layout fields] objectForKey:@"layoutId"]] forKey:@"Id"];
    [cri setValue:[[ValuesCriteria alloc] initWithString:@"System Information"] forKey:@"heading"];
    [cri setValue:[[ValuesCriteria alloc] initWithString:@"Field"] forKey:@"type"];
    tmpLayout = [DetailLayoutSectionsInfoManager list:cri];
    for (Item*item in tmpLayout) {
        [dic setValue:@"System Information" forKey:[item.fields objectForKey:@"value"]];
    }
    
    [cri removeAllObjects];
    [cri setValue:[[[ValuesCriteria alloc] initWithString:entity] autorelease] forKey:@"entity"];
    NSArray* listField = [[FieldInfoManager list:cri] retain];
    
    arrayNameLabel = [[NSMutableDictionary alloc] init];
    listLabel= [[NSMutableArray alloc] init];
    
    for (Item* item in listField) {
        NSString*label = [dic objectForKey:[item.fields objectForKey:@"name"]];
        if ([label isEqualToString:@"System Information"]) {
            label = [item.fields objectForKey:@"label"];
            if ([label hasSuffix:@" ID"]) label = [label substringToIndex:[label length]-3];
        }
        
        if ([[dic allKeys] containsObject:[item.fields objectForKey:@"name"]]) { 
            [arrayNameLabel setObject:item forKey:label];
            [listLabel addObject:[NSDictionary dictionaryWithObject:label forKey:@"label"]];
        }
    }
    
    
    NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"label" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
    NSArray *descriptors = [NSArray arrayWithObjects:descriptor, nil];
    NSArray *sortListLabel = [listLabel sortedArrayUsingDescriptors:descriptors];
    [listLabel removeAllObjects];
    for (NSDictionary* dict in sortListLabel) {
        [listLabel addObject:[dict objectForKey:@"label"]];
    }
        
    allElements = [[NSMutableArray alloc] initWithCapacity:1];
    
    [listField release];
    [cri release];
    
    return self;

}

-(void)dealloc{
    [arrayFieldDisplay release];
    [arrayNameLabel release];
    [listLabel release];
    for(UIViewController *con in allElements)[con release];
    [allElements release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

-(void)mustUpdate:(NSString *)val{
    
}

-(void)updateFieldDisplay:(NSString *)newValue index:(int)index{
    
    Item* newItem = [[Item alloc] init:@"FilterField" fields:nil];
    [newItem.fields setObject:entity forKey:@"objectName"];
    [newItem.fields setObject:newValue forKey:@"fieldLabel"];
    [newItem.fields setObject:[[[arrayNameLabel objectForKey:newValue]fields]objectForKey:@"name"] forKey:@"fieldName"];
    
    [arrayFieldDisplay replaceObjectAtIndex:index withObject:newItem];
    [self.tableView reloadData];
    
}

-(void)didUpdate:(Item *)newItem{
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [arrayFieldDisplay count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 95;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
        return NSLocalizedString(@"CHOOSE_DISPLAY_FIELDS", nil); //@"Choose Fields"
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    for (UIView *view in [cell.contentView subviews]) [view removeFromSuperview];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.backgroundColor = [UIColor whiteColor];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, 200, 40)];
    label.textColor = [UIColor colorWithRed:0.298039 green:0.337255 blue:0.423529 alpha:1];
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    label.backgroundColor = [UIColor clearColor];
    label.text =[NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"COLUMN", nil) ,indexPath.row + 1];
    [cell.contentView addSubview:label];
    [label release];
    
    NSString* firstField = @"";
    if (![[[arrayFieldDisplay objectAtIndex:indexPath.row] entity] isEqualToString:@""]) {
        firstField = [[[arrayFieldDisplay objectAtIndex:indexPath.row] fields] objectForKey:@"fieldLabel"];
    }
    FilterElementViewController *e1 = [[FilterElementViewController alloc] initWithHeader:@"" title:NSLocalizedString(@"FIELDS", nil) selectValue:firstField arrItems:listLabel frame:CGRectMake(150, 10, 280, 80) updateListener:self isFieldDisplay:YES];            
    e1.tag = indexPath.row;
    [allElements addObject:e1];
    
    [cell.contentView addSubview:e1.view];
    [e1.view release]; 
    
    return cell;
}

-(IBAction)saveField:(id)sender {
    
    BOOL needWarning = NO;
    NSMutableArray* fields = [[[NSMutableArray alloc] init] autorelease];
    for (Item*item in arrayFieldDisplay) {
        if ([fields containsObject:[item.fields objectForKey:@"fieldName"]]) {
            needWarning = YES;
        }else {
            if ([item.fields objectForKey:@"fieldName"] != NULL) {
                [fields addObject:[item.fields objectForKey:@"fieldName"]];
            }   
            
        }    
    }
    
    if (needWarning == YES) {
        
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"DUPLICATED_FIELD_WARING", @"") message:NSLocalizedString(@"FIELDS_DUPLICATED", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", Nil) otherButtonTitles:nil];
        [alert show];
        [alert release];
        
    }else {

        
        [FilterFieldManager remove:entity];
        for (Item* item in arrayFieldDisplay) {
            if (![item.entity isEqualToString:@""]) 
                  [FilterFieldManager insert:item];
            
        }
        
        [[(CustomDataGrid*)parentView dataModel] populate];
        [[(CustomDataGrid*)parentView dataTable] reloadData];
        [parentView dismissModalViewControllerAnimated:YES];
    }
                        
}

-(IBAction)cancel:(id)sender {
    [parentView dismissModalViewControllerAnimated:YES];
}

@end
