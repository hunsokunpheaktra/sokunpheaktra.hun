//
//  AgendaDetailViewController.m
//  CRMiOS
//
//  Created by Sy Pauv on 12/9/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "AgendaDetailViewController.h"

@implementation AgendaDetailViewController

@synthesize account, contact, appointment;
@synthesize contactNameLabel, contactPicture,phoneNo,email;

-(id)initWithItem:(Item *)newItem{
    
    self.appointment = newItem;
    return  [super initWithStyle:UITableViewStyleGrouped];

}

- (void)dealloc
{
    
    [contactPicture release];
    [contactNameLabel release];
    [phoneNo release];
    [email release];
    
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
    
    UIView *header = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 120)] autorelease];
    self.contactPicture = [[UIImageView alloc]init];
    [contactPicture setFrame:CGRectMake(32, 18, 95, 95)];
    
    contactPicture.layer.cornerRadius = 10;
    contactPicture.layer.borderWidth = 0.5;
    contactPicture.layer.shadowOffset=CGSizeMake(2, 2);
    contactPicture.layer.shadowColor=[UIColor grayColor].CGColor;
    contactPicture.layer.borderColor = [[UIColor grayColor] CGColor];
    contactPicture.clipsToBounds = YES;
    
    self.contactNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(152, 25, 216, 20)];
    contactNameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    contactNameLabel.lineBreakMode = UILineBreakModeTailTruncation;
    contactNameLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    contactNameLabel.textColor = [UIColor colorWithRed:0.1 green:0.3 blue:0.5 alpha:1.0];
    contactNameLabel.backgroundColor = [UIColor clearColor];
    
    
    self.phoneNo = [[UILabel alloc] initWithFrame:CGRectMake(152, 60, 216, 20)];
    phoneNo.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    phoneNo.lineBreakMode = UILineBreakModeTailTruncation;  
    phoneNo.backgroundColor = [UIColor clearColor];
    
    self.email = [[UILabel alloc] initWithFrame:CGRectMake(152, 80, 216, 20)];
    email.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    email.lineBreakMode = UILineBreakModeTailTruncation;  
    email.textColor = [UIColor grayColor];
    email.backgroundColor = [UIColor clearColor];

    [header addSubview:contactNameLabel];
    [header addSubview:phoneNo];
    [header addSubview:email];

    [contactPicture setImage:[UIImage imageNamed:@"no_picture.png"]];
    [header addSubview:contactPicture];

    [self.tableView setTableHeaderView:header];
    [self.tableView setScrollEnabled:NO];
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
   
    if (section==0) {
        return NSLocalizedString(@"Contact_SINGULAR",nil);
    }
    return NSLocalizedString(@"Account_SINGULAR",nil);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section==0) {
        return contact!=nil;
    }
    return  account!=nil;;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell...
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.accessoryType=UITableViewCellAccessoryDetailDisclosureButton;
    Item *item=indexPath.section==0?contact:account;
    NSObject <Subtype> *sinfo=[Configuration getSubtypeInfo:item.entity];
    cell.textLabel.text=[sinfo getDisplayText:item];
    
    return cell;
}

-(void)mustUpdate{
    self.account=nil;
    self.contact=nil;
    
    if (self.appointment!=nil) {
        self.account=[self getAccount];
        self.contact=[self getContact];
    }
    if (contact!=nil) {
        NSObject <Subtype> *sinfo=[Configuration getSubtypeInfo:contact.entity];
        contactNameLabel.text = [sinfo getDisplayText:contact];
        UIImage *img;
        NSData *dataimg = [PictureManager read:[contact.fields objectForKey:@"gadget_id"]];
        if (dataimg!=nil) {
            img = [UIImage imageWithData:dataimg];
        } else {
            img = [UIImage imageNamed:@"no_picture.png"];
        }
        [self.contactPicture setImage:img];
        email.text=[contact.fields objectForKey:@"ContactEmail"];
        phoneNo.text=[contact.fields objectForKey:@"WorkPhone"];
    
    }else{
        [self.contactPicture setImage:  [UIImage imageNamed:@"no_picture.png"]];
        email.text=@"";
        phoneNo.text=@"";
        contactNameLabel.text=@"";
    
    }
    
    [self.tableView reloadData];
}

- (void)navigateTab:(Item *)item {
    
    [PadTabTools navigateTab:item];
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section==0) {
        [self navigateTab:contact];
    } else {
        [self navigateTab:account];
    }
    
}

- (Item *)getContact{
    NSArray *criterias = [NSArray arrayWithObject:[[ValuesCriteria alloc] initWithColumn:@"Id" value:[self.appointment.fields objectForKey:@"PrimaryContactId"]]];
    return [EntityManager find:@"Contact" criterias:criterias];
}
- (Item *)getAccount{

    NSArray *criterias = [NSArray arrayWithObject:[[ValuesCriteria alloc] initWithColumn:@"Id" value:[self.appointment.fields objectForKey:@"AccountId"]]];
    return [EntityManager find:@"Account" criterias:criterias];

}



@end
