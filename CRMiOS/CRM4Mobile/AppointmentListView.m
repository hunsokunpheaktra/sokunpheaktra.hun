//
//  AppointmentListView.m
//  CRMiOS
//
//  Created by Sy Pauv on 12/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "AppointmentListView.h"


@implementation AppointmentListView
@synthesize  listItems,mytable,criterias;

-(id)initwithCriteria:(NSDictionary *)criteria{   
    
    self.criterias=criteria;
    return [super init];
    
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSObject<Subtype> *sinfo = [Configuration getSubtypeInfo:@"Appointment"];
    self.title=[sinfo localizedPluralName];
    UIInterfaceOrientation deviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    // Create the list
    self.mytable = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 0, 
                                                                 UIDeviceOrientationIsPortrait(deviceOrientation) ? 324 : 176
                                                                 ) style:UITableViewStylePlain];
    self.mytable.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.mytable setDelegate:self];
    [self.mytable setDataSource:self];
    self.view=self.mytable;
    
    [self reloadData];
    
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

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
       return [self.listItems count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Item *item = [listItems objectAtIndex:indexPath.row];
    
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [self.mytable dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	// Configure the cell...
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:@"Appointment"];
	cell.textLabel.text = [sinfo getDisplayText:item];
    cell.detailTextLabel.text = [sinfo getDetailText:item];
    NSString *icon = [sinfo getIcon:item];
    
    if (icon != Nil) {
        cell.imageView.image = [UIImage imageNamed:icon];
    } else {
        cell.imageView.image = nil;
    }
    
    while ([cell.contentView.subviews count] > 0) {
        [[cell.contentView.subviews objectAtIndex:0] removeFromSuperview];
    }
    if ([[item.fields objectForKey:@"favorite"]isEqualToString:@"1"]) {
        UIImageView *star = [[UIImageView alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width - 40 ,4, 32, 32)];
        star.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [star setImage:[UIImage imageNamed:@"btn_star_big_on.png"]];
        [cell.contentView addSubview:star];
        [star release];
    }else{
        [cell setAccessoryView:nil];
    }
    
    UIView *bg = [[UIView alloc] initWithFrame:cell.frame];
    
    if ([[item.fields objectForKey:@"modified"] isEqualToString:@"1"] && [item.fields objectForKey:@"Id"] !=nil ) {        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"row_updated.png"]];
        [imageView setFrame:CGRectMake(0, 0, 12, 12)];
        [bg addSubview:imageView];
        [imageView release];
        
    } else if ([[item.fields objectForKey:@"modified"] isEqualToString:@"1"] && [item.fields objectForKey:@"Id"] == nil){
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"row_new.png"]];
        [imageView setFrame:CGRectMake(0, 0, 12, 12)];
        [bg addSubview:imageView];
        [imageView release];
        
    } else if ([item.fields objectForKey:@"error"] != nil) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"row_error.png"]];
        [imageView setFrame:CGRectMake(0, 0, 12, 12)];
        [bg addSubview:imageView];
        [imageView release];
    }
    
    cell.backgroundView = bg;
    [bg release];
    
    return cell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{


    [self.mytable deselectRowAtIndexPath:indexPath animated:NO];
    Item *item = [listItems objectAtIndex:indexPath.row];
    DetailViewController *detailController = [[DetailViewController alloc] initWithItem:item listener:self];
    [self.navigationController pushViewController:detailController animated:YES];
    [detailController release];

}

- (void)reloadData{
    self.listItems = [EntityManager list:@"Appointment" entity:@"Activity" criterias:[NSArray arrayWithObject:criterias]];
    [self.mytable reloadData];
}

-(void)mustUpdate{
    [self reloadData];
}
@end
