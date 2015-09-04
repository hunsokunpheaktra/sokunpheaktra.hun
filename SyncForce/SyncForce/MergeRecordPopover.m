//
//  ListRecordsMerge.m
//  SyncForce
//
//  Created by Gaeasys on 12/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MergeRecordPopover.h"
#import "EntityManager.h"
#import "SfMergeRecords.h"
#import "SynchronizeViewController.h"


@implementation MergeRecordPopover

static NSString *indexAlphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";

@synthesize listView;
@synthesize mainmediaviewer;
@synthesize listrecods;
@synthesize mergeScreen;
@synthesize sfRecords;
@synthesize recordsSf;
@synthesize indexSelected;
@synthesize sortListRecords;
@synthesize sectionTitle;

- (id)initWithRootPath:(NSString *)entity mainmediaviewer:(MainMergeRecord *)pmainmediaviewer localRecord:(NSArray*)local sfRecords:(NSArray*)sf{
    self = [super init];
    
    mapIndexMergeSection = [[NSMutableDictionary alloc] init];
    mapIndexMergeField = [[NSMutableDictionary alloc] init];
    mapMergeItem = [[NSMutableDictionary alloc] init];
    
    
    if (self) {
        UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        mainView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self setView:mainView];
        
        self.listrecods = local; 
        self.sfRecords = sf;
        
        sectionTitle = [[NSMutableArray alloc] init];
        sortListRecords = [[NSMutableArray alloc] init];
        
        
        for( int x = 0; x < [indexAlphabet length]; x++ ) {
            NSMutableArray* array = [NSMutableArray array];
            for (Item* item in listrecods) {
                NSString* name = [[item fields] objectForKey:@"Name"];
                
                
                if ([[name substringWithRange:NSMakeRange(0,1)] caseInsensitiveCompare:[indexAlphabet substringWithRange:NSMakeRange(x, 1)]] == NSOrderedSame) {
                    [array addObject:item];
                }
                
            }
            if ([array count]>0) {
                [sortListRecords addObject:[NSDictionary dictionaryWithObjectsAndKeys:array,[indexAlphabet substringWithRange:NSMakeRange(x, 1)], nil]];
                [sectionTitle addObject:[indexAlphabet substringWithRange:NSMakeRange(x, 1)]];
            } 
        }
        
        
        NSString *root = NSLocalizedString(@"ALL_RECORDS", @"All Records");
        UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [navigationBar setTintColor:[UIColor colorWithRed:(23.0/255.0) green:(155.0/255.0) blue:(192.0/255.0) alpha:1]];
        UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:root];
        [navigationBar setItems:[NSArray arrayWithObject:navItem]];
        navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [mainView addSubview:navigationBar];
        
        // List view
        listView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 200, 112) style:UITableViewStylePlain];
        listView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        listView.delegate = self;
        listView.dataSource = self;
        [mainView addSubview:listView]; 
    }
    self.mainmediaviewer = pmainmediaviewer;
    
    for (int section = 0; section< [sortListRecords count]; section++) {
        NSArray* tmp = [[sortListRecords objectAtIndex:section] objectForKey:[sectionTitle objectAtIndex:section]];
        for (int row = 0; row < [tmp count]; row++) {
            Item *item = [tmp objectAtIndex:row];
            [mapMergeItem setObject:item forKey:[NSString stringWithFormat:@"%d%d",section,row]];
        }
    }
    
    return self;
}



- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
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


#pragma mark - View lifecycle


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [sortListRecords count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    NSArray* tmp = [[sortListRecords objectAtIndex:section] objectForKey:[sectionTitle objectAtIndex:section]];
    return [tmp count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [sectionTitle objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {          
    NSArray *ret = [NSArray array];
    
    for( int x = 0; x < [indexAlphabet length]; x++ ) 
        ret = [ret arrayByAddingObject:[indexAlphabet substringWithRange:NSMakeRange(x, 1)]];
    
    return ret;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {   
    
    for (int i = 0; i< [sectionTitle count];i++) {
        if ([[sectionTitle objectAtIndex:i] isEqualToString:title]) {
            return  i;
        }
    }
    
    return  -1;
}



// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    Item* item = [[[[sortListRecords objectAtIndex:indexPath.section] allValues] objectAtIndex:0] objectAtIndex:indexPath.row];
    
    NSString* tm = @"";
    
    if([item.entity isEqualToString:@"Case"] || [item.entity isEqualToString:@"Task"] || [item.entity isEqualToString:@"Event"]) 
        tm = @"Subject";
    else if ([item.entity isEqualToString:@"Contract"]) tm = @"ContractNumber";
    else tm = @"Name";
    
    cell.textLabel.text = [item.fields objectForKey:tm];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    


    Item* local = [[[[sortListRecords objectAtIndex:indexPath.section] allValues] objectAtIndex:0] objectAtIndex:indexPath.row];
    Item* sf;
    
    for (Item* sItem in sfRecords) {
        if ([[local.fields objectForKey:@"Id"] isEqualToString:[sItem.fields objectForKey:@"Id"]]) {
            sf = sItem;
            break;
        }
    }
    
    
    if ([[[mapIndexMergeSection objectForKey:[NSString stringWithFormat:@"%d%d",indexPath.section,indexPath.row]] allValues] count] == 0) {
        
        [mapIndexMergeSection setObject:[[NSMutableDictionary alloc] init] forKey:[NSString stringWithFormat:@"%d%d",indexPath.section,indexPath.row]];
        [mapIndexMergeField setObject:[[NSMutableDictionary alloc] init] forKey:[NSString stringWithFormat:@"%d%d",indexPath.section,indexPath.row]];     
    } 
    
    
    mainmediaviewer.mergeView.sectionRadio = [mapIndexMergeSection objectForKey:[NSString stringWithFormat:@"%d%d",indexPath.section,indexPath.row]];
    mainmediaviewer.mergeView.radios = [mapIndexMergeField objectForKey:[NSString stringWithFormat:@"%d%d",indexPath.section,indexPath.row]];
    mainmediaviewer.mergeView .sfItem = sf;
    mainmediaviewer.mergeView .localItem = local;
    mainmediaviewer.mergeView.listRecordsMerge = self;
    [mainmediaviewer.mergeView initView];
    [mainmediaviewer.mergeView.dataTable reloadData];
    
    if (mainmediaviewer.mergeView.popoverController != nil) {
        [mainmediaviewer.mergeView.popoverController dismissPopoverAnimated:YES];
    }
    
    indexSelected = indexPath;
    
}


- (void) mergeClick :(NSMutableDictionary*) sectionsRadio radios:(NSMutableDictionary*)radios itemMerge:(Item*)item {
    
    [mapIndexMergeSection setObject:sectionsRadio forKey:[NSString stringWithFormat:@"%d%d",indexSelected.section,indexSelected.row]];
    [mapIndexMergeField setObject:radios forKey:[NSString stringWithFormat:@"%d%d",indexSelected.section,indexSelected.row]];
    [mapMergeItem setObject:item forKey:[NSString stringWithFormat:@"%d%d",indexSelected.section,indexSelected.row]];
    
}

- (void) afterSaveRecordsMerged{
    
    for (int section = 0; section< [sortListRecords count]; section++) {
        NSArray* tmp = [[sortListRecords objectAtIndex:section] objectForKey:[sectionTitle objectAtIndex:section]];
        for (int row = 0; row < [tmp count]; row++) {
            Item *item = [mapMergeItem objectForKey:[NSString stringWithFormat:@"%d%d",section,row]];
            [EntityManager update:item modifiedLocally:YES];
        }
    }
    
}


@end
