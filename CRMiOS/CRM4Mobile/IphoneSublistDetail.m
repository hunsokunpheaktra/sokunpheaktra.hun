//
//  IphoneSublistDetail.m
//  CRMiOS
//
//  Created by Sy Pauv on 11/21/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "IphoneSublistDetail.h"


@implementation IphoneSublistDetail

@synthesize item, parentItem;

- (NSArray *)getSublistFields {
    NSString *subtype = [Configuration getSubtype:self.parentItem];
    NSObject<Subtype> *sinfo = [Configuration getSubtypeInfo:subtype];
    NSObject<Sublist> *slinfo = [sinfo getSublist:self.item.sublist];
    NSMutableArray *tmpfields = [[NSMutableArray alloc] initWithCapacity:1];
    for (NSString *field in slinfo.fields) {
        if ([field rangeOfString:@"Id"].location==NSNotFound) {
            [tmpfields addObject:field];
        }
    }
    return tmpfields;
}


- (id)initWithItem:(SublistItem *)newItem parent:(Item *)newParentItem {
    
    self.item = newItem;
    self.parentItem = newParentItem;
   
    listFields = [self getSublistFields];
    
    return [super initWithStyle:UITableViewStyleGrouped];
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

- (void)viewDidLoad
{
    NSString *sublistCode = [NSString stringWithFormat:@"%@_SINGULAR", self.item.sublist];
    self.title = NSLocalizedString(sublistCode, @"Sublist code");
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
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [listFields count];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *code = [listFields objectAtIndex:indexPath.row];
    if ([item.sublist isEqualToString:@"Attachment"] && [code isEqualToString:@"Attachment"]) {
        NSString *value = [item.fields objectForKey:code];
        NSData *attachment = [Base64 decode:value];
        if ([UITools contentTypeIsImageData:attachment]) {
            UIImage *image = [UIImage imageWithData:attachment];
            CGSize imageSize = [UITools computeImageSize:image forSize:180];
            return imageSize.height + 20;
        } else {
            return 64;
        }
    }
    
    return 44.0;
}



// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell...
    
    NSString *code = [listFields objectAtIndex:indexPath.row];
    
    NSString *value = [self.item.fields objectForKey:code];
    if ([code isEqualToString:@"Attachment"]) {
        cell.textLabel.text = code;
        NSData *attachment = [Base64 decode:value];
        UIImage *image;
        CGSize imageSize = CGSizeMake(44, 44);
        if ([UITools contentTypeIsImageData:attachment]) {
            image = [UIImage imageWithData:attachment];
            imageSize = [UITools computeImageSize:image forSize:180];
        } else {
            NSString *fileName = [UITools getAttachmentIcon:self.item];
            image = [UIImage imageNamed:fileName];
        }
        
        UIImageView *attachedImg = [[UIImageView alloc]initWithImage:image];
        [attachedImg setFrame:CGRectMake(80, 10, imageSize.width, imageSize.height)];
        if ([UITools contentTypeIsImageData:attachment]) {
            [attachedImg.layer setBorderColor: [[UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0] CGColor]];
            [attachedImg.layer setBorderWidth: 1.0];
        }
        [cell.contentView addSubview:attachedImg];
        [attachedImg release];
    } else {
        [UITools setupCell:cell subtype:[FieldsManager getSublistCode:self.item.entity sublist:self.item.sublist]  code:code value:value grouping:NO item:item iphone:YES];
    }
    
    cell.textLabel.numberOfLines = 3;
    cell.detailTextLabel.numberOfLines = 5;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

@end
