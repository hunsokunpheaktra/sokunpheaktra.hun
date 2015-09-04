//
//  SublistDetailView.m
//  CRMiOS
//
//  Created by Sy Pauv on 11/15/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "SublistDetailPopup.h"


@implementation SublistDetailPopup

@synthesize popoverController, tableView, listFields, item, canDelete, listener, parentItem, navController;

- (NSArray *)getSublistFields {
    NSObject<Subtype> *sinfo = [Configuration getSubtypeInfo:[Configuration getSubtype:self.parentItem]];
    NSObject<Sublist> *slinfo = [sinfo getSublist:self.item.sublist];
    NSMutableArray *tmpfields = [[NSMutableArray alloc] initWithCapacity:1];
    for (NSString *field in [slinfo fields]) {
        if ([field rangeOfString:@"Id"].location == NSNotFound) {
            [tmpfields addObject:field];
        }
    }
    return tmpfields;
}

- (id)initWithItem:(SublistItem *)newItem parentItem:(Item *)newParentItem listener:(NSObject<CreationListener, UpdateListener> *)newListener navController:(UINavigationController *)newNavController {
    self.item = newItem;
    self.parentItem = newParentItem;
    self.listener = newListener;
    self.listFields = [self getSublistFields];
    self.canDelete = YES;
    self.listener = newListener;
    self.navController = newNavController;
    return [super init];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 480, 480) style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    if (self.canDelete) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
        footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        if ([self.item updatable]) {
            UIButton *btnEdit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [btnEdit setTitle:NSLocalizedString(@"EDIT", "Edit button") forState:UIControlStateNormal];
            btnEdit.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            [btnEdit setFrame:CGRectMake(290, 2, 100, 32)];
            [btnEdit addTarget:self action:@selector(editDetail) forControlEvents:UIControlEventTouchUpInside];
            [footerView addSubview:btnEdit];
        }

        
        UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnDelete setBackgroundImage:[[UIImage imageNamed:@"delete_button.png"] stretchableImageWithLeftCapWidth:8.0f topCapHeight:0.0f] forState:UIControlStateNormal];
        [btnDelete setTitle:NSLocalizedString(@"DELETE", "Delete button") forState:UIControlStateNormal];
        [btnDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnDelete.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        btnDelete.titleLabel.shadowColor = [UIColor lightGrayColor];
        btnDelete.titleLabel.shadowOffset = CGSizeMake(0, -1);
        btnDelete.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        [btnDelete setFrame:CGRectMake([self.item updatable] ? 180 : 290, 2, 100 , 32)];
        [btnDelete addTarget:self action:@selector(deleteConfirm:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:btnDelete];
        [self.tableView setTableFooterView:footerView];
    }
    
    self.view = self.tableView;
    
}

- (void)editDetail {
    [self.popoverController dismissPopoverAnimated:YES];

    SublistEditVC *sublistVC = [[SublistEditVC alloc] initWithDetail:self.item parentItem:self.parentItem updateListener:self.listener isCreate:NO];
    // remove all the existing views
    [self.navController pushViewController:sublistVC animated:YES];
    [sublistVC release];
    
    return;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [listFields count];
}

- (float)computeHeight:(int)row {
    NSString *code = [listFields objectAtIndex:row];
    CRMField *field = [FieldsManager read:[NSString stringWithFormat:@"%@ %@", item.entity, item.sublist] field:code];
    if ([code isEqualToString:@"Attachment"]) {
        NSString *value = [self.item.fields objectForKey:code];
        NSData *attachment = [Base64 decode:value];
        if ([UITools contentTypeIsImageData:attachment]) {
            UIImage *image = [UIImage imageWithData:attachment];
            CGSize imageSize = [UITools computeImageSize:image forSize:260];
            return imageSize.height + 20;
        } else {
            return 80;
        }
    } else if ([field.type isEqualToString:@"Text (Long)"]) {
        NSString *text = [self.item.fields objectForKey:code];
        CGSize constraint = CGSizeMake(tableView.frame.size.width-90 , 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:16] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        CGFloat height = MAX(size.height, 44.0f);
        return height ;
    }
    
    return  44.0;
}

- (float)totalHeight {
    float height = 20;
    for (int i = 0; i < [listFields count]; i++) {
        height += [self computeHeight:i];
    }
    if (canDelete) height += 44;
    return height;
}

- (float)tableView:(UITableView *)pTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self computeHeight:indexPath.row];

}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell...
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;

    NSString *code = [listFields objectAtIndex:indexPath.row];
    
    NSString *value = [self.item.fields objectForKey:code];
    if ([code isEqualToString:@"Attachment"]) {
        cell.textLabel.text = code;
        NSData *attachment = [Base64 decode:value];
        NSString *extension = [UITools getAttachmentExtension:self.item];
        UIImage *image;
        CGSize imageSize = CGSizeMake(60, 60);
        if ([UITools contentTypeIsImageData:attachment]) {
            image = [UIImage imageWithData:attachment];
            imageSize = [UITools computeImageSize:image forSize:260];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            NSString *fileName = [UITools getAttachmentIcon:self.item];
            image = [UIImage imageNamed:fileName];
            if ([[[self.item.fields objectForKey:@"FileExtension"] lowercaseString] isEqualToString:@"url"] || [extension isEqualToString:@"pdf"]) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        
        UIImageView *attachedImg = [[UIImageView alloc] initWithImage:image];
        [attachedImg setFrame:CGRectMake(80, 10, imageSize.width, imageSize.height)];
        if ([UITools contentTypeIsImageData:attachment]) {
            [attachedImg.layer setBorderColor: [[UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0] CGColor]];
            [attachedImg.layer setBorderWidth: 1.0];
        }
        [cell.contentView addSubview:attachedImg];
        [attachedImg release];
        
    } else {
        [UITools setupCell:cell subtype:[NSString stringWithFormat:@"%@ %@", item.entity, item.sublist] code:code value:value grouping:NO item:item iphone:NO];
    }
    
    CRMField *field = [FieldsManager read:[NSString stringWithFormat:@"%@ %@", item.entity, item.sublist] field:code];
    if ([field.type isEqualToString:@"Text (Long)"]) {
        cell.detailTextLabel.numberOfLines = 0;
    } else {
        cell.detailTextLabel.numberOfLines = 2;
    }
    cell.textLabel.numberOfLines = 2;
    
    return cell;
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

- (void)show:(CGRect)rect parentView:(UIView *)parentView {

    if ([self.popoverController isPopoverVisible]) {
        //close the popover view if toolbar button was touched
        //again and popover is already visible
        
        [self.popoverController dismissPopoverAnimated:YES];
        [self release];
        return;
    }

    //build our custom popover view
    UINavigationController *popoverContent = [[UINavigationController alloc]
                                              initWithRootViewController:self];
    NSString *sublistCode = [NSString stringWithFormat:@"%@_SINGULAR", item.sublist];
    self.title = NSLocalizedString(sublistCode, @"Sublist code");
    
    //resize the popover view shown
    //in the current view to the view's size
    self.contentSizeForViewInPopover = CGSizeMake(400, [self totalHeight]);
    
    //create a popover controller
    self.popoverController = [[UIPopoverController alloc]
                              initWithContentViewController:popoverContent];
    
    //present the popover view non-modal with a
    //refrence to the toolbar button which was pressed
    [self.popoverController presentPopoverFromRect:rect inView:parentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [popoverContent release];


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

- (void)deleteConfirm:(id)sender{
    
    // open a alert with an OK and cancel button
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DELETE_CONFIRM", "Config delete") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"DELETE", nil) otherButtonTitles:NSLocalizedString(@"CANCEL", nil), nil];
	[alert show];
	[alert release];
    
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// use "buttonIndex" to decide your action
	//
    if (buttonIndex == 0) {
        [SublistManager remove:item];
        [self.popoverController dismissPopoverAnimated:YES];
        [self.listener mustUpdate];
	} 
}

- (void)tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *code = [listFields objectAtIndex:indexPath.row];
    if ([code isEqualToString:@"Attachment"] || ([code isEqualToString:@"FileNameOrURL"] && [[[self.item.fields objectForKey:@"FileExtension"] lowercaseString] isEqualToString:@"url"])) {
        URLViewerVC *viewerVC = nil;
        if ([[[self.item.fields objectForKey:@"FileExtension"] lowercaseString] isEqualToString:@"url"]) {
            viewerVC = [[URLViewerVC alloc] initWithURL:[self.item.fields objectForKey:@"FileNameOrURL"]];
        } else {
            NSString *value = [self.item.fields objectForKey:code];
            NSData *attachment = [Base64 decode:value];
            
            NSString *extension = [UITools getAttachmentExtension:self.item];
            if ([UITools contentTypeIsImageData:attachment] || [extension isEqualToString:@"pdf"]) {
                viewerVC = [[URLViewerVC alloc] initWithData:attachment extension:extension];
            }
        }
        if (viewerVC != nil) {
            UINavigationController *viewerNavController = [[UINavigationController alloc] initWithRootViewController:viewerVC];
            [self.popoverController dismissPopoverAnimated:YES];
            gadgetAppDelegate *delegate = (gadgetAppDelegate *)[UIApplication sharedApplication].delegate;
            [delegate.tabBarController presentModalViewController:viewerNavController animated:YES];
        }
    } else {
        [UITools handleCellClick:self code:code item:self.item updateListener:nil];
    }
}
    
@end
