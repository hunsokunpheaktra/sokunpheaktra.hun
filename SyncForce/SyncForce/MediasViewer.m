//
//  Mediaviewer.m
//  Datagrid
//
//  Created by Gaeasys Admin on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MediasViewer.h"
#import "MediaItem.h"
#import "MediaPlayer/MediaPlayer.h"
#import "MovieViewController.h"
#import "MediaHelper.h"

@implementation MediasViewer
@synthesize tableview,mainMediaViewer,popoverController;


- (void)viewDidLoad
{
    [self setTitle:NSLocalizedString(@"FILES_FOR_PREVIEW", Nil)];
    UIView *mainscreen = [[UIView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    mainscreen.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:(23.0/255.0) green:(155.0/255.0) blue:(192.0/255.0) alpha:1]];
    
    /*CGRect rect = self.navigationController.navigationBar.frame;
    rect.origin.y = 50;
    [self.navigationController.navigationBar setFrame:rect];*/
    
    // Create the list
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0,0,mainscreen.frame.size.width, mainscreen.frame.size.height) style:UITableViewStylePlain];
    self.tableview.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.tableview setDelegate:self];
    [self.tableview setDataSource:self];
    [mainscreen addSubview:self.tableview];
    
    
    [self setView:mainscreen];
    [super viewDidLoad];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return  YES;
}

-(void) viewWillAppear:(BOOL)animated {
  /*  
    CGRect rect = self.navigationController.navigationBar.frame;
    rect.origin.y = 50;
    [self.navigationController.navigationBar setFrame:rect];
   */ 
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    /*CGRect frame = [self.tableview frame];
     frame.size.height = UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ? 750 : 500;
     [self.tableview setFrame:frame];*/
    
    /*CGRect rect = self.navigationController.navigationBar.frame;
      rect.origin.y = 50;
      [self.navigationController.navigationBar setFrame:rect];
    */ 
     
}


-(void) recursivelyRetrieveFile:(NSMutableArray *)listFile directoryPath:(NSString *)directoryPath 
                    typeFilters:(NSArray*)filters 
                    fileManager:(NSFileManager*)filemgr{
    
    NSArray *filelist = [filemgr contentsOfDirectoryAtPath:directoryPath error:nil];
    int count = [filelist count];
    for (int i = 0; i < count; i++){
        
        NSString *fn = [[NSString alloc] initWithFormat:@"%@",[filelist objectAtIndex: i]];
        NSString *fnWithPath = [[NSString alloc] initWithFormat:@"%@/%@",directoryPath,fn];
        NSDictionary *attribs = [filemgr attributesOfItemAtPath: fnWithPath error: NULL];
        
        if([attribs objectForKey: NSFileType] == NSFileTypeRegular){
            
            MediaItem *mediaItem = [[MediaItem alloc] init:fnWithPath filename:fn];
            NSString *ext = mediaItem.extension;
            mediaItem.isMovie = [MediaHelper checkMovieFile:ext];
            [MediaHelper putMediaItemIcon:mediaItem];
            if(filters != nil){
                if([filters containsObject:ext]) [listFile addObject:mediaItem];
            }else{
                [listFile addObject:mediaItem];
            }
            
        }else if([attribs objectForKey: NSFileType] == NSFileTypeDirectory){
            [self recursivelyRetrieveFile:listFile directoryPath:fnWithPath typeFilters:filters fileManager:filemgr];
        }
    }
    
}

-(id)initWithFolder:(NSString*)folderName typeFilters:(NSArray*)filters{
    [super init];
    if (self) {
        
        [self fileFilter:folderName typeFilters:filters];
    }
    
    return self;
}

- (void)fileFilter:(NSString *)folderName typeFilters:(NSArray *) filters{
    
    // Custom initialization
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSMutableArray *fnlist = [[NSMutableArray alloc] init];
    [self recursivelyRetrieveFile:fnlist directoryPath:folderName typeFilters:filters fileManager:filemgr];
    
    arrayOfDocuments = [[NSArray alloc] initWithArray:fnlist];
    
    for(MediaItem * i in arrayOfDocuments){
        NSLog(@"New List %@",i.filename);
    }
    [fnlist release];
    [filemgr release];
    [self.tableview reloadData];
    [[self navigationController] popViewControllerAnimated:YES];
    
}

- (void)dealloc
{
    // Free up all the documents
    [tableview release];
	[arrayOfDocuments release];
    [mainMediaViewer release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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
#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    return [arrayOfDocuments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"tableRow";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    MediaItem * item = (MediaItem*)[arrayOfDocuments objectAtIndex:indexPath.row];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:
                      [[NSBundle mainBundle] pathForResource:item.iconname ofType:@"png"]];
    [[cell imageView] setImage:image];
    [[cell textLabel] setText: item.filename];
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [image release];
    return cell;
}




#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // viewer : mp4, mov
    MediaItem * item = ((MediaItem*)[arrayOfDocuments objectAtIndex:indexPath.row]);
    if(item.isMovie){
        MovieViewController *movieplayer = [[MovieViewController alloc] initWithFilePath:item.filepath];
        [[self navigationController] pushViewController:movieplayer animated:YES];
    }else{
        // viewer : xsl, png, pdf, doc
        // When user taps a row, create the preview controller
        QLPreviewController *previewer = [[[QLPreviewController alloc] init] autorelease];
        // Set data source
        [previewer setDataSource:self];
        // Which item to preview
        [previewer setCurrentPreviewItemIndex:indexPath.row];
        // Push new viewcontroller, previewing the document
        [[self navigationController] pushViewController:previewer animated:YES];
    }
}


#pragma mark -
#pragma mark Preview Controller

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller 
{
	return [arrayOfDocuments count];
}

- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index 
{
	// Break the path into it's components (filename and extension)
	//NSArray *fileComponents = [[arrayOfDocuments objectAtIndex: index] componentsSeparatedByString:@"."];
    
	// Use the filename (index 0) and the extension (index 1) to get path
    //NSString *path = [[NSBundle mainBundle] pathForResource:[fileComponents objectAtIndex:0] ofType:[fileComponents objectAtIndex:1]];
    //NSLog(@"selected File Path : %@",path);
	return [NSURL fileURLWithPath:((MediaItem*)[arrayOfDocuments objectAtIndex: index]).filepath];
}

@end