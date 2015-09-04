//
//  DetialViewController.m
//  CRM
//
//  Created by MACBOOK on 4/8/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "DetailViewController.h"


@implementation DetailViewController

@synthesize listField;
@synthesize relatedItems;
@synthesize relations;
@synthesize item;
@synthesize tableView;
@synthesize toolbar;
@synthesize listener;
@synthesize sinfo;
@synthesize sections, pages;
@synthesize subtype;
@synthesize sectionData;
@synthesize currentPage;
@synthesize favoriteButton;
@synthesize subListNames;
@synthesize sublistValues;

@synthesize contactNameLabel,accountNameLabel,contactPicture;
@synthesize workAction,imagePicker;

#pragma mark -
#pragma mark Initialization

- (id)initWithItem:(Item *)newItem listener:(NSObject <UpdateListener> *)newListener {
    
	self = [super init];
    self.item = newItem;
    self.listener = newListener;
    self.subtype = [Configuration getSubtype:self.item];
    self.sinfo = [Configuration getSubtypeInfo:subtype];
    
    // create the view
    [self setView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)]];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // create the table view
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 200, 156) style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.view addSubview:self.tableView];
    
    
    //check any disable action
    [self checkAction];
    
    // relation 
    self.relatedItems = nil;
    self.relations = nil;

    
    // Create the header
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 1)];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    headerView.backgroundColor = [UIColor clearColor];
    
    // errors
    if ([self.item.fields objectForKey:@"error"] != nil) {
        
        CGRect rect = headerView.frame;
        rect.size.height += 80;
        headerView.frame = rect;
        
        UIImageView *erroricon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"log-warning.png"]];
        [erroricon setFrame:CGRectMake(5, rect.size.height - 64, 35, 35)];
        
        UITextView *errorText = [[UITextView alloc] initWithFrame:CGRectMake(45, rect.size.height - 72, 145, 64)];
        errorText.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        errorText.text = [self.item.fields objectForKey:@"error"];
        errorText.editable = NO;
        [errorText setFont:[UIFont boldSystemFontOfSize:12]];
        errorText.layer.cornerRadius = 5;
        errorText.layer.borderWidth = 1;
        errorText.layer.borderColor = [[UIColor grayColor] CGColor];
        errorText.clipsToBounds = YES;
        errorText.textColor = [UIColor redColor];
        errorText.textAlignment = UITextAlignmentLeft;
        
        [headerView addSubview:errorText];
        [headerView addSubview:erroricon];
        
        [errorText release];
        [erroricon release];
    }  
    
    // image for contacts in the header
    if ([self.item.entity isEqualToString:@"Contact"]) {
        CGRect rect = headerView.frame;
        rect.size.height += 120;
        headerView.frame = rect;
        contactPicture = [[UIImageView alloc]init];
        contactPicture.frame = CGRectMake(5, rect.size.height - 100, 90, 90);
        
        contactPicture.layer.cornerRadius = 8;
        contactPicture.layer.borderWidth = 0.5;
        contactPicture.layer.borderColor = [[UIColor grayColor] CGColor];
        contactPicture.clipsToBounds = YES;
        
        contactNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, rect.size.height - 85, 80, 20)];
        contactNameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        contactNameLabel.lineBreakMode = UILineBreakModeTailTruncation;
        contactNameLabel.font = [UIFont boldSystemFontOfSize:16];
        contactNameLabel.backgroundColor = [UIColor clearColor];
        
        accountNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, rect.size.height - 55, 80, 20)];
        accountNameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        accountNameLabel.lineBreakMode = UILineBreakModeTailTruncation;  
        accountNameLabel.textColor = [UIColor grayColor];
        accountNameLabel.backgroundColor = [UIColor clearColor];
        
        [headerView addSubview:contactNameLabel];
        [headerView addSubview:accountNameLabel];
        
        [contactNameLabel release];
        [accountNameLabel release];
        
        [contactPicture setImage:[UIImage imageNamed:@"no_picture.png"]];
        [headerView addSubview:contactPicture];
    }
    
    if (([item.entity isEqualToString:@"Contact"]||[item.entity isEqualToString:@"Lead"])&&( [Configuration isYes:@"facebookEnabled"] || [Configuration isYes:@"linkedinEnabled"])) {
        CGRect rect = headerView.frame;
        rect.size.height += 40;
        headerView.frame = rect;
        // facebook button in the header
        if ([Configuration isYes:@"facebookEnabled"]) {
            UIButton *faceBook = [[UIButton alloc] initWithFrame:CGRectMake(5, rect.size.height - 32, 32, 32)];
            [faceBook setBackgroundImage:[UIImage imageNamed:@"facebookicon.png"] forState:UIControlStateNormal];
            faceBook.tag = 0;
            [faceBook addTarget:self action:@selector(faceBookLinkedIn:) forControlEvents:UIControlEventTouchUpInside];
            [headerView addSubview:faceBook];
        }
        // linkedin button in the header
        if ([Configuration isYes:@"linkedinEnabled"]) {
            UIButton *linkedIn = [[UIButton alloc] initWithFrame:CGRectMake(50, rect.size.height - 32, 32, 32)];
            linkedIn.tag = 1;
            [linkedIn setBackgroundImage:[UIImage imageNamed:@"linkedin.png"] forState:UIControlStateNormal];
            [linkedIn addTarget:self action:@selector(faceBookLinkedIn:) forControlEvents:UIControlEventTouchUpInside];
            [headerView addSubview:linkedIn];
        }
    }
        


    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:1];
    
    UIBarButtonItem *btnShowAction = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionClicked)];
    [btnShowAction setStyle:UIBarButtonItemStylePlain];
    NSObject <EntityInfo> *enInfo = [Configuration getInfo:self.item.entity];
    [btnShowAction setEnabled:([self.workAction count] > 0) || [enInfo canDelete]];
    [items addObject:btnShowAction];
    [btnShowAction release];
    
    self.favoriteButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.favoriteButton setBackgroundImage:[UIImage imageNamed:[[self.item.fields objectForKey:@"favorite"] isEqualToString:@"1"] ? @"btn_star_big_on.png" : @"btn_star_big_off.png"] forState:UIControlStateNormal];
    [self.favoriteButton addTarget:self action:@selector(addFavorite:) forControlEvents:UIControlEventTouchUpInside];
    [items addObject:[[UIBarButtonItem alloc] initWithCustomView:self.favoriteButton]];
    
   
    
    //RSK: add pagging
    self.pages = [LayoutPageManager read:subtype];
    
    
    //segmented button
    NSMutableArray *pageLabels = [[NSMutableArray alloc] initWithCapacity:1];
    for (NSString *tmp in pages) {
        [pageLabels addObject:[EvaluateTools translateWithPrefix:tmp prefix:@"HEADER_"]];
    }
    [pageLabels addObject:NSLocalizedString(@"RELATED_ITEMS", @"Related Items")];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:pageLabels];
    [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    for (int i = 0; i < [pageLabels count]; i++) {
        NSString *pageLabel = [pageLabels objectAtIndex:i];
        CGSize lsize = [pageLabel sizeWithFont:[UIFont systemFontOfSize:12]]; 
        [segmentedControl setWidth:lsize.width+20 forSegmentAtIndex:i];    
    }
    [pageLabels release];
    
    [segmentedControl setSelectedSegmentIndex:0];    
    [segmentedControl addTarget:self action:@selector(segmentPageChange:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *barbutton = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    
    [items addObject:barbutton];
    [barbutton release];
  
    
    self.toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 350, 44)];
    toolbar.items = items;
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [items release];
    
    [self.view addSubview:toolbar];
    [segmentedControl release];
    [self.tableView setTableHeaderView:headerView];
    //show displaytext for title
	self.navigationItem.title = [sinfo getDisplayText:self.item];
    NSObject <EntityInfo> *info = [Configuration getInfo:self.item.entity];
    if ([info canUpdate]) self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //image picker
    self.imagePicker = [[UIImagePickerController alloc] init]; 
    self.imagePicker.allowsEditing = YES;
    self.imagePicker.delegate = self;	
    
    //[self mustUpdate];
    return self;
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:NO animated:animated];
    EditingViewController *controller = [[EditingViewController alloc] initWithItem:item updateListener:self isCreate:NO];
    [self.navigationController pushViewController:controller animated:YES];
	[controller release];
    
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if ([self.currentPage intValue] == [self.pages count]) {
        return 2;
    } else {
        return [self.sections count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if ([self.currentPage intValue] == [self.pages count]){         
        if (section > 0) {
            return [self.subListNames count];
        } else {
            return [self.relations count];
        }
    }
    NSArray *tmpData = [self.sectionData objectAtIndex:section];
    return [tmpData count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if ([self.currentPage intValue] == [self.pages count]){ 
        if (section > 0) {
            //sublist section
            return [self.subListNames count] > 0 ? NSLocalizedString(@"Sublists", @"Sublist code"):nil;
        } else {
            return NSLocalizedString(@"RELATED_ITEMS", @"Related Items");
        }
    }
    Section *tmpsection = [self.sections objectAtIndex:section];
    return [EvaluateTools translateWithPrefix:tmpsection.name prefix:@"HEADER_"];
    
}


- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.currentPage intValue] < [self.pages count]) {
        Section *section = [self.sections objectAtIndex:indexPath.section];
        if (section.isGrouping) {
            return 44.0f * 1.5;
        } else {
            NSString *code = [section.fields objectAtIndex:indexPath.row];
            CRMField *field = [FieldsManager read:self.item.entity field:code];
            if([field.type isEqualToString:@"Text (Long)"]) {
                NSString *text = [self.item.fields objectForKey:code]; 
                CGSize constraint = CGSizeMake(self.tableView.frame.size.width-110 , 20000.0f);
                CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:IPHONE_DETAIL_FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
                CGFloat height = MAX(size.height, 44.0f);
                return height ;    
            }
        }
    }

    return 44.0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier1 = @"Cell1";
    static NSString *CellIdentifier2 = @"Cell2";    
    UITableViewCell *cell;
    if ([self.currentPage intValue] < [self.pages count]) {
        cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier1];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier1] autorelease];
        }
    } else {
        cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier2];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier2] autorelease];
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.detailTextLabel.numberOfLines = 2;
    cell.textLabel.numberOfLines = 2;
    
    // empty the cell contents
    while ([cell.contentView.subviews count] > 0) {
        [[cell.contentView.subviews objectAtIndex:0] removeFromSuperview];
    }
    
    if ([self.currentPage intValue] < [self.pages count]) {
        // Configure the cell...
        
        Section *section = [self.sections objectAtIndex:indexPath.section];
        NSString *field = [section.fields objectAtIndex:indexPath.row];
        
        NSString *value = nil;
        NSArray *tempData = [self.sectionData objectAtIndex:indexPath.section];
        if (section.isGrouping) {
            value = [tempData objectAtIndex:0];
            field = section.name;
        } else {
            if ([tempData objectAtIndex:indexPath.row] != [NSNull null]) {
                value = [tempData objectAtIndex:indexPath.row];
            }
        }
        [UITools setupCell:cell subtype:self.subtype code:field value:value grouping:section.isGrouping item:item iphone:YES];
   
    } else {
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
        NSArray *items;
        if (indexPath.section == 0) {
            NSString *otherSubtype = [self.relations objectAtIndex:indexPath.row];
            items = [self.relatedItems objectForKey:otherSubtype];
            NSObject <Subtype> *sinfos = [Configuration getSubtypeInfo:otherSubtype];
            cell.imageView.image = [UIImage imageNamed:[sinfos iconName]];
        } else {
            //sublist section 
            NSString *sublistName = [subListNames objectAtIndex:indexPath.row];
            items = [self.sublistValues objectForKey:sublistName];
            NSObject<Sublist> *slinfo = [sinfo getSublist:sublistName];
            cell.imageView.image = [UIImage imageNamed:slinfo.icon];
        }
        
        NSMutableString *tmp = [[NSMutableString alloc] initWithCapacity:1];
        for (int i = 0; i < [items count]; i++) {
            if (i > 0) {
                [tmp appendString:@", "];
            }
            [tmp appendString:[[items objectAtIndex:i] objectForKey:@"Name"]];
            if (i == 2) {
                [tmp appendString:@"..."];
                break;
            }
        }
        if ([items count] == 1 && [[[items objectAtIndex:0] objectForKey:@"gadget_id"] isEqualToString:@"-1"]) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.detailTextLabel.text = tmp;
        
        
    }
    return cell;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)dealloc {
    [imagePicker release];
	[self.listField release];
    [self.relatedItems release];
    [self.item release];
    [self.relations release];
    [self.tableView release];
    [self.view release];
    [super dealloc];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([self.currentPage intValue] == [self.pages count]) {
        
        if (indexPath.section == 0) {
            
            // if related list have only one item link direct to detail
            NSString *otherSubtype = [self.relations objectAtIndex:indexPath.row];
            NSArray *items = [self.relatedItems objectForKey:otherSubtype];
            if ([items count] == 1) {
                
                NSDictionary *relatedItem = [items objectAtIndex:0];
                if (![[relatedItem objectForKey:@"gadget_id"] isEqualToString:@"-1"]) {
                    NSObject <Subtype> *rsinfo = [Configuration getSubtypeInfo:otherSubtype];
                    Item *otherItem = [EntityManager find:[rsinfo entity] column:@"gadget_id" value:[relatedItem objectForKey:@"gadget_id"]];
                    DetailViewController *detailController = [[DetailViewController alloc] initWithItem:otherItem listener:self];
                    [[self navigationController] pushViewController:detailController animated:YES];
                    [detailController release];
                }
                
            } else {
                RelationSub *relSub = [[items objectAtIndex:0] objectForKey:@"relSub"];
                NSString *refValue = [[items objectAtIndex:0] objectForKey:@"refValue"];
                ListRelationViewController *relatedDetail = [[ListRelationViewController alloc] initWithRelSub:relSub refValue:refValue];
                [[self navigationController] pushViewController:relatedDetail animated:YES];
                [relatedDetail release];
                
            }
            
        } else {
            
            NSString *sublistName = [subListNames objectAtIndex:indexPath.row];
            NSArray *sublistvalue = [self.sublistValues objectForKey:sublistName];
            
             //if sublist list have only one item link direct to detail
            if ([sublistvalue count] == 1) {
                SublistItem *subItem = [SublistManager find:self.item.entity sublist:sublistName criterias:[NSArray arrayWithObject:[ValuesCriteria criteriaWithColumn:@"gadget_id" value:[sublistvalue objectAtIndex:0]]]];
                IphoneSublistDetail *detail = [[IphoneSublistDetail alloc] initWithItem:subItem parent:self.item];
                [[self navigationController] pushViewController:detail animated:YES];
                [detail release];
                
            } else {
                
                // view sublist's list
                SublistRelationVC *sublistList = [[SublistRelationVC alloc] initWithSublist:sublistName parent:self.item related:sublistvalue];
                [[self navigationController] pushViewController:sublistList animated:YES];
                [sublistList release];
            }
            
        }
        
    } else {
        
        NSString *code;
        Section *section = [self.sections objectAtIndex:indexPath.section];
        code = [section.fields objectAtIndex:indexPath.row];
        [UITools handleCellClick:self.navigationController code:code item:self.item updateListener:self];
        
    }
}

- (NSArray *)getsublistName {
    NSMutableArray *tmpName=[[NSMutableArray alloc]initWithCapacity:1];
    for (NSString *key in [self.sublistValues allKeys]) {
        if ([(NSArray *)[sublistValues objectForKey:key] count]>0) {
            [tmpName addObject:key];
        }
    }
    return tmpName;
}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [self mustUpdate];

}

- (void)mustUpdate {
    
    self.item = [EntityManager find:self.item.entity column:@"gadget_id" value:[self.item.fields objectForKey:@"gadget_id"]];
    self.relations = [[NSMutableArray alloc] initWithCapacity:1];
    [self.relatedItems release];
    self.relatedItems = [RelationManager getRelatedItems:self.item];
    for (NSString *otherSubtype in self.relatedItems) {
        NSArray *items = [self.relatedItems objectForKey:otherSubtype];
        if ([items count] > 0) {
            [self.relations addObject:otherSubtype];
        }
    }
    self.sublistValues = [SublistManager getSublists:self.item];
    self.subListNames = [self getsublistName];
    [self updateSections];

    [self.tableView reloadData];
    [self.listener mustUpdate];
    
    // picture and label for contact
    if ([item.entity isEqualToString:@"Contact"]) {
        self.contactNameLabel.text = [self.sinfo getDisplayText:item];
        self.accountNameLabel.text = [self.sinfo getDetailText:item];
        UIImage *img;
        NSData *dataimg = [PictureManager read:[item.fields objectForKey:@"gadget_id"]];
        if (dataimg!=nil) {
            img = [UIImage imageWithData:dataimg];
        } else {
            img = [UIImage imageNamed:@"no_picture.png"];
        }
        [self.contactPicture setImage:img];
    }
    
    
}


- (void)addFavorite:(id)sender {
    if ([[item.fields objectForKey:@"favorite"] isEqualToString:@"0"] || [item.fields objectForKey:@"favorite"]==nil) {
        [item.fields setValue:@"1" forKey:@"favorite"];
        [self.favoriteButton setBackgroundImage:[UIImage imageNamed:@"btn_star_big_on.png"] forState:UIControlStateNormal];
    } else {
        [item.fields setValue:@"0" forKey:@"favorite"];
        [self.favoriteButton setBackgroundImage:[UIImage imageNamed:@"btn_star_big_off.png"] forState:UIControlStateNormal];
    }
    [EntityManager update:item modifiedLocally:NO];
    [listener mustUpdate];
    
}

//Facebook linkedIn action
- (void)faceBookLinkedIn:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSString *type = btn.tag == 0 ? @"Facebook" : @"LinkedIn";
    FaceBookLinkedInView *faceBook = [[FaceBookLinkedInView alloc] initwithItem:self.item subtype:self.sinfo type:type];
    [self.navigationController pushViewController:faceBook animated:YES];
    [faceBook release];
}


- (NSArray *)fillSectionData:(int)section {
    
    NSMutableArray *tmpData = [[NSMutableArray alloc] initWithCapacity:1];
    
    Section *tmpSection = [self.sections objectAtIndex:section];
    if (tmpSection.isGrouping) {
        NSMutableString *tmpString = [[[NSMutableString alloc] initWithCapacity:1] autorelease];
        for (NSString *field in tmpSection.fields) {
            NSString *value = [self.item.fields objectForKey:field];
            if (value != nil) {
                if ([tmpString length] > 0) [tmpString appendString:@", "];
                [tmpString appendString:value];
            }
        }
        [tmpData addObject:tmpString];
    } else {
        for (NSString *field in tmpSection.fields) {
            NSString *value = [self.item.fields objectForKey:field];
            if (value == nil) {
                [tmpData addObject:[NSNull null]];
            } else {
                [tmpData addObject:value];
            }            
        }
    }
    return tmpData;
}

- (void)segmentPageChange:(id)sender{
    
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    self.currentPage = [NSNumber numberWithInt:[segmentedControl selectedSegmentIndex]];
    [self updateSections];
    
}

- (void)updateSections {
    int sectionCount;
    [self.sections release];
    if ([self.currentPage intValue] < [self.pages count]) {
        self.sections = [LayoutSectionManager read:self.subtype page:[self.currentPage intValue]];
        sectionCount = [self.sections count];
    } else {
        self.sections = nil;
        sectionCount = [self.relations count];
    }
    NSMutableArray *tmpData = [[NSMutableArray alloc] initWithCapacity:1];
    for (int i = 0; i <sectionCount; i++) {
        [tmpData addObject:[self fillSectionData:i]];
    }
    self.sectionData = tmpData;
    
    [tableView reloadData];
    
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// use "buttonIndex" to decide your action
	//
    if (buttonIndex == 0 && isdelete) {
        [EntityManager remove:self.item];
        [self.listener mustUpdate];
        [self.navigationController popToRootViewControllerAnimated:YES];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (actionSheet.tag) {
        case 1:
            [self actionHandle:buttonIndex];
            break;
        case 2:
            [self createRelatedItemHandle:buttonIndex];
            break;
    }
}

- (void)checkAction{
    NSMutableArray *tmpAction = [[NSMutableArray alloc] initWithCapacity:0];
    for (Action *act in [self.sinfo actions]) {
        if (act.clone || act.update) {
            NSObject <EntityInfo> *info = [Configuration getInfo:item.entity]; 
            if (![info canCreate]) continue;
        } else {
            NSObject <EntityInfo> *info = [Configuration getInfo:act.entity]; 
            if (![info canCreate]) continue;
        }
        [tmpAction addObject:act];
    }
    if ([subtype isEqualToString:@"ServiceRequest"] || [subtype isEqualToString:@"Task"]) {
        [tmpAction addObject:[[Action alloc] initWithName:@"%TAKEPICTURE%"]];
    }
    self.workAction = tmpAction;
    [tmpAction release];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
    
    NSArray *sublist = [self.sublistValues objectForKey:@"Attachment"];
    NSString *imageName = [NSString stringWithFormat:@"Picture %i",[sublist count]+1];
    NSData *capturedIMGData = UIImageJPEGRepresentation(img, 1.0);
    NSString *base64IMG = [Base64 encode:capturedIMGData];
    SublistItem *newAttachment = [[SublistItem alloc] init:self.item.entity sublist:@"Attachment" fields:[[NSMutableDictionary alloc]initWithCapacity:1]];
    [newAttachment.fields setObject:base64IMG forKey:@"Attachment"];
    [newAttachment.fields setObject:[item.fields objectForKey:@"Id"] forKey:[self.subtype isEqualToString:@"ServiceRequest"]? @"SRId":@"ActivityId"];
    [newAttachment.fields setObject:[item.fields objectForKey:@"Id"] forKey:@"parent_oid"];
    [newAttachment.fields setObject:imageName forKey:@"FileNameOrURL"];
    [newAttachment.fields setObject:imageName forKey:@"DisplayFileName"];
    [newAttachment.fields setObject:@"jpg" forKey:@"FileExtension"];
    [SublistManager insert:newAttachment locally:YES];
    [picker dismissModalViewControllerAnimated:YES];
    
}

- (void)takePicture {
    isdelete = NO;
    //check if idevice support with camera ?
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"CRM4Mobile" message:NSLocalizedString(@"CAMERA_NOT_AVAILABLE", nil) delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera; 
    [self presentModalViewController:imagePicker animated:YES];  
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([self.currentPage intValue] == [self.pages count] && section == 0) {
        return 44;
    } else {
        return 0;
    }
}

- (NSArray *)getCreatable {
    
    NSMutableArray *creatable = [[NSMutableArray alloc] initWithCapacity:1];
    NSArray *relSubs = [RelationManager getRelations:self.subtype entity:self.item.entity];
    for (RelationSub *relSub in relSubs) {
        if ([RelationManager isCreatable:relSub.otherSubtype from:self.subtype entity:self.item.entity]) {
            BOOL found = NO;
            for (NSString *tmp in creatable) {
                if ([tmp isEqualToString:relSub.otherSubtype]) {
                    found = YES;
                    break;
                }
            }
            if (!found) {
                [creatable addObject:relSub.otherSubtype];
            }
        }
    }
    [relSubs release];
    return creatable;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if ([self.currentPage intValue] == [self.pages count] && section == 0 && [[self getCreatable] count]>0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [button setFrame:CGRectMake(112, 8, 80, 32)];
        [button setTitle:NSLocalizedString(@"CREATE", nil) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(createRelatedItem:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        return view;
    } else {
        return nil;
    }
}

- (void)actionClicked {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    actionSheet.tag = 1;
    
    for (Action *act in self.workAction) {
        [actionSheet addButtonWithTitle:[EvaluateTools translateWithPrefix:act.name prefix:@"ACTION_"]];
    }
    NSObject <EntityInfo> *info=[Configuration getInfo:item.entity];
    if ([info canDelete]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"DELETE", @"delete")];
        [actionSheet setDestructiveButtonIndex:[self.workAction count]];
    }
    [actionSheet addButtonWithTitle:NSLocalizedString(@"CANCEL", @"cancel")];
    [actionSheet setCancelButtonIndex:[info canDelete]?[self.workAction count]+1:[self.workAction count]];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view.superview]; 
    [actionSheet release];
    
}

- (void)actionHandle:(int)index {

    if (index < [self.workAction count]) {
        Action *act = [self.workAction objectAtIndex:index];
        if ([act.name isEqualToString:@"%TAKEPICTURE%"]) {
            [self takePicture];
        } else {
            if (act.update) {
                for (NSString *field in [act.fields keyEnumerator]) {
                    NSString *formula = [act.fields objectForKey:field];
                    NSString *value = [EvaluateTools evaluate:formula item:item];
                    [item.fields setObject:value forKey:field];
                }
                [EntityManager update:item modifiedLocally:YES];
                [self mustUpdate];
            } else {
                Item *newItem = [act buildItem:self.item];
                NSObject <Subtype> *subInfo = [Configuration getSubtypeInfo:[Configuration getSubtype:newItem]];
                [subInfo fillItem:newItem];
                EditingViewController *addViewController = [[EditingViewController alloc] initWithItem:newItem updateListener:self isCreate:YES];
                [self.navigationController pushViewController:addViewController animated:YES];
                [addViewController release];
                [newItem release];
            }
        }
	}
    
    NSObject <EntityInfo> *info = [Configuration getInfo:item.entity];
    if (index == [self.workAction count] && [info canDelete]) {
        // open a alert with an OK and cancel button
        if (imagePicker != nil) [imagePicker release];
        isdelete = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DELETE_CONFIRM", "Config delete") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"DELETE", nil) otherButtonTitles:NSLocalizedString(@"CANCEL", nil), nil];
        [alert show];
        [alert release];
    }


}

//create related item 
- (void)createRelatedItem:(id)sender {
    NSArray *creatable = [self getCreatable];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    actionSheet.tag = 2;
    for (NSString *otherSubtype in creatable) {
        NSObject <Subtype> *rsinfo = [Configuration getSubtypeInfo:otherSubtype];
        [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"NEW", @"new"), [rsinfo localizedName]]];
    }
    [actionSheet addButtonWithTitle:NSLocalizedString(@"CANCEL", @"Cancel")];
    [actionSheet setCancelButtonIndex:[creatable count]];
    [actionSheet showInView:self.view.superview]; 
    [actionSheet release];
    
}

- (void)createRelatedItemHandle:(int)index{
    
    NSArray *creatable = [self getCreatable];
    
    if (index < [creatable count]) {

        NSString *otherSubtype = [creatable objectAtIndex:index];
        NSObject <Subtype> *rsinfo = [Configuration getSubtypeInfo:otherSubtype];
        Item *newObject = [[Item alloc] init:[rsinfo entity] fields:[[NSDictionary alloc]init]];
        [rsinfo fillItem:newObject];
        NSArray *allRelations = [Relation getEntityRelations:rsinfo.entity];
        for (Relation *relation in allRelations) {
            if ([relation.srcEntity isEqualToString:rsinfo.entity] && [relation.destEntity isEqualToString:self.item.entity]) {
                [newObject.fields setValue:[self.item.fields objectForKey:relation.destKey] forKey:relation.srcKey];
            }
        }
        EditingViewController *addViewController = [[EditingViewController alloc] initWithItem:newObject updateListener:self.listener isCreate:YES];
        // remove all the existing views
        [self.navigationController pushViewController:addViewController animated:YES];
        [addViewController release];
        [newObject release];
        
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}

@end


