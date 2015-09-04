//
//  DirectoryListViewController.m
//  Datagrid
//
//  Created by Gaeasys Admin on 10/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DirectoryListViewController.h"


@implementation DirectoryListViewController

@synthesize selectedItem,directoryList,listView;
@synthesize mainmediaviewer;


-(void) recursivelyRetrieveDirectories:(NSMutableArray *)listDir directoryPath:(NSString *)directoryPath
                           fileManager:(NSFileManager*)filemgr{
    NSArray *list = [filemgr contentsOfDirectoryAtPath:directoryPath error:nil];
    int count = [list count];
    for (int i = 0; i < count; i++){
        NSString *fn = [list objectAtIndex: i];
        NSString *fnWithPath = [[NSString alloc] initWithFormat:@"%@/%@",directoryPath, fn];
        NSDictionary *attribs = [filemgr attributesOfItemAtPath: fnWithPath error: NULL];
        if([attribs objectForKey: NSFileType] == NSFileTypeDirectory){
            MediaItem *mediaItem = [[MediaItem alloc] initAsDirectory:fnWithPath filename:fn];
            [listDir addObject:mediaItem];
            [self recursivelyRetrieveDirectories:listDir directoryPath:fnWithPath fileManager:filemgr];
        }
    }
}

- (id)initWithRootPath:(NSString *)prootPath mainmediaviewer:(MainMediaViewer *)pmainmediaviewer{
    self = [super init];
    if (self) {
        // Custom initialization
        NSFileManager *filemgr = [NSFileManager defaultManager];
        NSMutableArray *listDir = [[NSMutableArray alloc] init];
        [self recursivelyRetrieveDirectories:listDir directoryPath:prootPath fileManager:filemgr];
        directoryList = [[NSArray alloc] initWithArray:listDir];
        [listDir release];
        [filemgr release];
        
        UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        mainView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self setView:mainView];
        
        
        // Navigation Bar
        NSArray *arrayPath = [prootPath componentsSeparatedByString:@"/"];
        NSString *root = [NSString stringWithFormat:@"... / %@",[ arrayPath objectAtIndex:arrayPath.count-1]] ;
        UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [navigationBar setTintColor:[UIColor colorWithRed:(23.0/255.0) green:(155.0/255.0) blue:(192.0/255.0) alpha:1]];
        UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:root];
        [navigationBar setItems:[NSArray arrayWithObject:navItem]];
        navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        [navigationBar setFrame:CGRectMake(0, 50, 200, 44)];
        [mainView addSubview:navigationBar];
        
        // List view
        listView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 200, 112) style:UITableViewStylePlain];
        listView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        listView.delegate = self;
        listView.dataSource = self;
        [mainView addSubview:listView]; 
    }
    self.mainmediaviewer = pmainmediaviewer;
    return self;
}

- (void)dealloc
{
    [selectedItem release];
    [directoryList release];
    [mainmediaviewer release];
    [listView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

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
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [directoryList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	
	// Configure the cell...
    MediaItem *item = [directoryList objectAtIndex:indexPath.row];
    if(item == nil) return cell;
    cell.textLabel.text = [item filename];
    cell.imageView.image = [UIImage imageNamed:item.iconname];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    //[item release];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedItem = [directoryList objectAtIndex:indexPath.row];
    [self.mainmediaviewer.mediasViewer  fileFilter:self.selectedItem.filepath typeFilters:[NSArray arrayWithObjects:@".pdf",@".xls",@".xlsx",@".ppt",@".pptx",@".doc",@".docx",@".png",@".jpg",@".mov",@".mp4",@".m4v", nil]];
    if (self.mainmediaviewer.mediasViewer.popoverController != nil) {
        [self.mainmediaviewer.mediasViewer.popoverController dismissPopoverAnimated:YES];
    }
}

@end
