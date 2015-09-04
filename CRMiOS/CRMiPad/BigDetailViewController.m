//
//  DetailViewController.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/10/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "BigDetailViewController.h"

@implementation BigDetailViewController

@synthesize allFields;
@synthesize detail;
@synthesize relatedItems;
@synthesize relations;
@synthesize sublistItems;
@synthesize sublists;
@synthesize pages;
@synthesize sections;
@synthesize sectionData;
@synthesize segmentedControl;
@synthesize toolbar;
@synthesize subtype;
@synthesize sinfo;
@synthesize popoverController;
@synthesize favoriteButton;
@synthesize currentPage;
@synthesize detailView;
@synthesize parent;
@synthesize errorView;
@synthesize btnShowAction;
@synthesize updateListener;
@synthesize contactNameLabel;
@synthesize accountNameLabel;
@synthesize contactPicture;
@synthesize workAction;
@synthesize longFields;

- (id)initDetail:(NSString *)newSubtype parent:(PadMainViewController *)newParent {
    self = [super init];
    self.parent = newParent;
    self.detail = nil;
    self.subtype = newSubtype;
    self.sinfo = [Configuration getSubtypeInfo:self.subtype];
    self.updateListener = parent;
    self.allFields = [FieldsManager list:[self.sinfo entity]];
    self.relatedItems = nil;
    self.pages = [LayoutPageManager read:self.subtype];
    self.relations = [[NSMutableArray alloc] initWithCapacity:1];
    self.sublists = [[NSMutableArray alloc] initWithCapacity:1];
    self.sublistItems = [[NSMutableArray alloc] initWithCapacity:1];
    self.longFields = [[NSMutableArray alloc] initWithCapacity:1];
    return self;
}

- (void)buildToolbarItems {
    
    NSMutableArray *toolbarItems = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];

    //RSK: add pagging
    NSMutableArray *scItems = [[NSMutableArray alloc] initWithCapacity:1];
    // translate button label
    for (NSString *tmp in self.pages) {
        [scItems addObject:[EvaluateTools translateWithPrefix:tmp prefix:@"HEADER_"]];
    }
    [scItems addObject:NSLocalizedString(@"RELATED_ITEMS", @"Related Items")];
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:scItems];
    [self.segmentedControl setSelectedSegmentIndex:0];
    [segmentedControl addTarget:self action:@selector(tabPagesChange:) forControlEvents:UIControlEventValueChanged];
    [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    //[tabpages release];
    UIBarButtonItem *toolbarButton = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    [toolbarItems addObject:toolbarButton];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [toolbarItems addObject:space];
    
    if ([[self.sinfo entity] isEqualToString:@"Contact"] || [[self.sinfo entity] isEqualToString:@"Lead"]) {
        
        if ([Configuration isYes:@"facebookEnabled"]) {
            //facebook
            UIButton *faceBook = [[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 32, 32)] autorelease];
            [faceBook setBackgroundImage:[UIImage imageNamed:@"facebookicon.png"] forState:UIControlStateNormal];
            faceBook.tag = 0;
            [faceBook addTarget:self action:@selector(faceBookLinkedIn:) forControlEvents:UIControlEventTouchUpInside];
            [toolbarItems addObject:[[UIBarButtonItem alloc]initWithCustomView:faceBook]];
            
        }
        if ([Configuration isYes:@"linkedinEnabled"]) {
            //linkedin
            UIButton *linkedIn = [[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 32, 32)] autorelease];
            linkedIn.tag = 1;
            [linkedIn setBackgroundImage:[UIImage imageNamed:@"linkedin.png"] forState:UIControlStateNormal];
            [linkedIn addTarget:self action:@selector(faceBookLinkedIn:) forControlEvents:UIControlEventTouchUpInside];
            [toolbarItems addObject:[[UIBarButtonItem alloc]initWithCustomView:linkedIn]];
        }
        
    }
    
    
    // PDF button
    if ([Configuration isYes:@"canExportPDF"]) {
        UIButton *pdf = [[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 24, 21)] autorelease];
        [pdf setBackgroundImage:[UIImage imageNamed:@"185-printer.png"] forState:UIControlStateNormal];
        pdf.tag = 20;
        [pdf addTarget:self action:@selector(exportPDF) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *bpdf = [[[UIBarButtonItem alloc]initWithCustomView:pdf]autorelease];
        bpdf.tag = 20;
        [toolbarItems addObject:bpdf];
    }
    
    
    
    // Action button
    self.btnShowAction = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet)];
    [btnShowAction setStyle:UIBarButtonItemStylePlain];
    btnShowAction.tag=1;
    [toolbarItems addObject:btnShowAction];
    
    
    // Favorite button
    self.favoriteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.favoriteButton setBackgroundImage:[UIImage imageNamed:[[self.detail.fields objectForKey:@"favorite"] isEqualToString:@"1"] ?@"btn_star_big_on.png":@"btn_star_big_off.png"] forState:UIControlStateNormal];
    [self.favoriteButton addTarget:self action:@selector(addFavorite:) forControlEvents:UIControlEventTouchUpInside];
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithCustomView:self.favoriteButton]];

    
    [self.toolbar setItems:toolbarItems];

}

- (void)loadView {

    
    [self.navigationController.navigationBar setTintColor:[UITools readHexColorCode:[Configuration getProperty:@"headerColor"]]];
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit)];
    [self.navigationItem setRightBarButtonItem:editButton];    

    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 200)];
    mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
   
    // -----add toolbar ------
    self.toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 400, 44)];
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [mainView addSubview:self.toolbar];
    [self buildToolbarItems];
    
    //---end add toolbar ----
    
    //----end error view ------
    
    
    self.detailView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 400, 156) style:UITableViewStyleGrouped];
    self.detailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.detailView.delegate = self;
    self.detailView.dataSource = self;
    
    //----add error view ----
        
    self.errorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    self.errorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIImageView *erroricon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"log-warning.png"]];
    [erroricon setFrame:CGRectMake(16, 16, 44, 44)];
    [self.errorView addSubview:erroricon];
    UITextView *errorLogView = [[UITextView alloc]initWithFrame:CGRectMake(64, 16, 128, 64)];
    errorLogView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [errorLogView setFont:[UIFont boldSystemFontOfSize:14]];
    [errorLogView setBackgroundColor:[UIColor clearColor]];
    errorLogView.textColor = [UIColor redColor];
    errorLogView.textAlignment = UITextAlignmentLeft;
    [errorLogView setEditable:NO];
    [self.errorView addSubview:errorLogView];
    

    // image for contacts
    if ([[self.sinfo entity] isEqualToString:@"Contact"]) {
        
        header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 120)];
        
        self.contactPicture = [[UIImageView alloc]init];
        [self.contactPicture setFrame:CGRectMake(32, 18, 95, 95)];
        
        self.contactPicture.layer.cornerRadius = 8;
        self.contactPicture.layer.borderWidth = 0.5;
        self.contactPicture.layer.borderColor = [[UIColor grayColor] CGColor];
        self.contactPicture.clipsToBounds = YES;
        
        self.contactNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(152, 35, 216, 20)];
        self.contactNameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.contactNameLabel.lineBreakMode = UILineBreakModeTailTruncation;
        self.contactNameLabel.font = [UIFont boldSystemFontOfSize:16];
        self.contactNameLabel.backgroundColor = [UIColor clearColor];
        
        self.accountNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(152, 60, 216, 20)];
        self.accountNameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.accountNameLabel.lineBreakMode = UILineBreakModeTailTruncation;  
        self.accountNameLabel.textColor = [UIColor grayColor];
        self.accountNameLabel.backgroundColor = [UIColor clearColor];
        
        [header addSubview:self.contactNameLabel];
        [header addSubview:self.accountNameLabel];
        
        [self.contactPicture setImage:[UIImage imageNamed:@"no_picture.png"]];

        [header addSubview:self.contactPicture];
    }
    
    [mainView addSubview:self.detailView];
    
    self.detailView.sectionHeaderHeight = DETAIL_HEADER_HEIGHT;
    
    [self mustUpdate];
    [self setView:mainView];
}

- (NSString *)formatItemName:(NSDictionary *)item subtype:(NSString *)otherSubtype {
    NSString *name = [item objectForKey:@"Name"];
    NSString *suffix = [item objectForKey:@"Type"];
    if (suffix != nil) {
        NSString *singleField = [RelationManager singleField:otherSubtype from:sinfo.name entity:sinfo.entity];
        if (singleField == nil) {
            return [NSString stringWithFormat:@"%@ (%@)", name, suffix];
        }
    }
    return name;
}

- (NSMutableArray *)fillSectionData:(int)section {
    
    NSMutableArray *tmpData = [[NSMutableArray alloc] initWithCapacity:1];
    if ([self.currentPage intValue] == [self.pages count]) {
        // Related items tab
        if (section < [self.relations count]) {
            // Relation
            NSString *otherSubtype = [self.relations objectAtIndex:section];
            for (NSDictionary *relatedItem in [self.relatedItems objectForKey:otherSubtype]) {
                [tmpData addObject:[self formatItemName:relatedItem subtype:otherSubtype]];
            }
        } else {
            // Sublist relations
            for (NSDictionary *sublistItem in [self.sublistItems objectAtIndex:section - [self.relations count]]) {
                [tmpData addObject:[sublistItem objectForKey:@"Name"]];
            }
        }

    } else {
        Section *tmpSection = [self.sections objectAtIndex:section];
        NSMutableString *tmpString = [[NSMutableString alloc] initWithCapacity:1];
        for (NSString *field in tmpSection.fields) {
            NSString *value = [self.detail.fields objectForKey:field];
            if (tmpSection.isGrouping) {
                if (value != nil) {
                    if ([tmpString length] > 0) [tmpString appendString:@", "];
                    [tmpString appendString:value];
                }
            } else {
                if (value == nil) {
                    [tmpData addObject:[NSNull null]];
                } else {
                    [tmpData addObject:value];
                }
            }
        }
        if (tmpSection.isGrouping)
            [tmpData addObject:tmpString];
    }
    return tmpData;
}


- (void)dealloc
{
    [btnShowAction release];
    [self.relatedItems release];
    [self.relations release];
    [super dealloc];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (detail == nil) return 0;
    // Return the number of sections.
    return [self.sectionData count];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSArray *tmpData = [self.sectionData objectAtIndex:section];
    return [tmpData count];
}





-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    
    UIView *hdrView = [[UIView alloc] initWithFrame:CGRectMake(0,0, tableView.frame.size.width, DETAIL_HEADER_HEIGHT)];
    hdrView.backgroundColor = [UIColor clearColor];
    
    UILabel *label;
    label = [[UILabel alloc] initWithFrame:CGRectMake(92, 0, DETAIL_HEADER_ROW_WIDTH, DETAIL_HEADER_HEIGHT)];
    label.font = [UIFont boldSystemFontOfSize:DETAIL_HEADER_FONT_SIZE];
    label.textAlignment = UITextAlignmentLeft;
    label.highlightedTextColor = [UIColor whiteColor];
    label.textColor = [UIColor darkGrayColor];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0, 1);
    label.backgroundColor = [UIColor clearColor];
    
    UIButton *button = nil;
    
    if ([currentPage intValue] == [pages count]) {
        if (section < [self.relations count]) {
            NSString *otherSubtype = [self.relations objectAtIndex:section];
            NSArray *items = [relatedItems objectForKey:otherSubtype];
            NSObject <Subtype> *otherInfo = [Configuration getSubtypeInfo:otherSubtype];
            NSString *singleField = [RelationManager singleField:otherSubtype from:sinfo.name entity:sinfo.entity];
            if (singleField != nil) {
                CRMField *hdrField = [FieldsManager read:sinfo.entity field:singleField];
                label.text = [EvaluateTools removeIdSuffix:hdrField.displayName];
            } else {
                label.text = [NSString stringWithFormat:@"%@ (%d)", [otherInfo localizedPluralName], [items count]];
            }
            // Add plus button to add related subtypes
            if ([RelationManager isCreatable:otherSubtype from:sinfo.name entity:sinfo.entity]) {
                UIButton *addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
                [addButton setFrame:CGRectMake(hdrView.frame.size.width - 80, 8, addButton.frame.size.width, addButton.frame.size.height)];
                addButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                addButton.tag = section;
                [addButton addTarget:self action:@selector(addRelated:) forControlEvents:UIControlEventTouchUpInside];
                [hdrView addSubview:addButton];
            } 
        } else {
            NSString *sublist = [self.sublists objectAtIndex:section - [relations count]];
            NSString *sublistDispCode = [NSString stringWithFormat:@"%@_PLURAL", sublist];
            label.text = NSLocalizedString(sublistDispCode, @"Sublist code");
            // add button
            UIButton *addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
            [addButton setFrame:CGRectMake(hdrView.frame.size.width - 80, 8, addButton.frame.size.width, addButton.frame.size.height)];
            addButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            addButton.tag = section - [relations count];
            [addButton addTarget:self action:@selector(addSublist:) forControlEvents:UIControlEventTouchUpInside];
            [hdrView addSubview:addButton];
        }
    } else {
        Section *tmpSection = [self.sections objectAtIndex:section];
        if (tmpSection.name != nil) {
            label.text = [EvaluateTools translateWithPrefix:tmpSection.name prefix:@"HEADER_"];
        }
    }
    
    
    button = [[UIButton alloc]initWithFrame:CGRectMake(46, 0, 48, 48)];
    button.tag = section;
    NSArray *list = [self.sectionData objectAtIndex:section];
    [button setBackgroundImage:[UIImage imageNamed:[list count] > 0 ? @"toggle-down.png" : @"toggle-right.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickToCollape:) forControlEvents:UIControlEventTouchUpInside];
    [hdrView addSubview:button];     
    [hdrView addSubview:label];

    return hdrView;
}

- (void)addSublist:(id)sender {

    NSString *sublist = [self.sublists objectAtIndex:((UIButton *) sender).tag];
    SublistItem *newObject = [[SublistItem alloc] init:self.detail.entity sublist:sublist fields:[[NSDictionary alloc]init]];
    [newObject.fields setObject:[self.detail.fields objectForKey:@"Id"] forKey:@"parent_oid"];
    SublistEditVC *sublistVC = [[SublistEditVC alloc] initWithDetail:newObject parentItem:self.detail updateListener:self isCreate:YES];
    // remove all the existing views
    [self.parent.itemViewController.navigationController pushViewController:sublistVC animated:YES];
    [sublistVC release];
    
    [newObject release];
}

- (void)addRelated:(id)sender {
    NSString *otherSubtype = [relations objectAtIndex:((UIButton *)sender).tag];
    NSObject <Subtype> *rsinfo = [Configuration getSubtypeInfo:otherSubtype];
    Item *newObject = [[Item alloc] init:[rsinfo entity] fields:[[NSDictionary alloc]init]];

    [rsinfo fillItem:newObject];
    for (Relation *relation in [Relation getEntityRelations:self.detail.entity]) {
        if ([relation.srcEntity isEqualToString:rsinfo.entity]) {
            if ([relation.srcKey isEqualToString:@"CustomText33"]) continue; // Bug 4948
            [newObject.fields setValue:[self.detail.fields objectForKey:relation.destKey] forKey:relation.srcKey];
            for (int i = 0; i < [relation.srcFields count]; i++) {
                NSString *srcField = [relation.srcFields objectAtIndex:i];
                NSString *destField = [relation.destFields objectAtIndex:i];
                [newObject.fields setValue:[self.detail.fields objectForKey:destField] forKey:srcField];
            }
        }
    }
    // CR #5545 : if it is an appointment or a task, set the account to the primary contact's account
    if ([newObject.entity isEqualToString:@"Activity"]) {
        if ([[newObject.fields objectForKey:@"PrimaryContactId"] length] > 0) {
            Item *contact = [EntityManager find:@"Contact" column:@"Id" value:[newObject.fields objectForKey:@"PrimaryContactId"]];
            if (contact != nil && [[contact.fields objectForKey:@"AccountId"] length] > 0) {
                [newObject.fields setObject:[contact.fields objectForKey:@"AccountId"] forKey:@"AccountId"];
            }
        }
    }
    
    EditViewController *addViewController = [[EditViewController alloc] initWithDetail:newObject updateListener:self.parent isCreate:YES action:nil];
    // remove all the existing views
    [self.parent.itemViewController.navigationController popToRootViewControllerAnimated:NO];
    [self.parent.itemViewController.navigationController pushViewController:addViewController animated:YES];
    [addViewController release];
    
    [newObject release];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.currentPage intValue] < [self.pages count]) {
        
        // Configure the cell...
        Section *section = [self.sections objectAtIndex:indexPath.section];
        NSString *code = [section.fields objectAtIndex:indexPath.row];
        CRMField *field = [FieldsManager read:[sinfo entity] field:code];
        if ([field.type isEqualToString:@"Text (Long)"]) {
            NSString *text = [self.detail.fields objectForKey:code]; 
            CGSize constraint = CGSizeMake(tableView.frame.size.width - 240, DETAIL_MAX_CELL_HEIGHT);
            CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:DETAIL_FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            CGFloat height = MAX(size.height, 45.0f);
            if (height == DETAIL_MAX_CELL_HEIGHT) {
                [longFields addObject:code];
            }
            return height + 8;
        }
    } 
    
    return 45;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier1 = @"CellDetail1";
    static NSString *CellIdentifier2 = @"CellDetail2";
	
    UITableViewCell *cell;
    if ([self.currentPage intValue] < [self.pages count]) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        if (cell == nil) {
            cell = [[[CustomCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier1] autorelease];
            [cell layoutSubviews];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier2] autorelease];
        }
    }

    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([self.currentPage intValue] < [self.pages count]) {
        
        // Configure the cell...
        Section *section = [self.sections objectAtIndex:indexPath.section];
        NSString *field = [section.fields objectAtIndex:indexPath.row];
        NSString *value;
        if (section.isGrouping) {
            NSArray *tempData = [self.sectionData objectAtIndex:indexPath.section];
            value = [tempData objectAtIndex:0];
            field = section.name;
        } else {
            value = [self.detail.fields objectForKey:field];
        }
        [UITools setupCell:cell subtype:self.subtype code:field value:value grouping:section.isGrouping item:detail iphone:NO];
        if ([self.longFields containsObject:field]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSArray *items;
        if (indexPath.section < [relations count]) {
            NSString *otherSubtype = [relations objectAtIndex:indexPath.section];
            NSObject <Subtype> *rsinfo = [Configuration getSubtypeInfo:otherSubtype];
            items = [self.relatedItems objectForKey:otherSubtype];
            cell.detailTextLabel.text = nil;
            cell.imageView.image = nil;
            NSDictionary *item = [items objectAtIndex:indexPath.row];
            if ([[item objectForKey:@"gadget_id"] isEqualToString:@"-1"]) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            } 
            // show check mark for compeleted task
            if ([otherSubtype isEqualToString:@"Task"]) {
                Item *task = [EntityManager find:[rsinfo entity] column:@"gadget_id" value:[item objectForKey:@"gadget_id"]];
                cell.imageView.image = [[task.fields objectForKey:@"Status"] isEqualToString:@"Completed"]?[UIImage imageNamed:@"checkmark.png"]:nil;
            }
            cell.textLabel.text = [self formatItemName:[items objectAtIndex:indexPath.row] subtype:otherSubtype];
        } else {
            items = [self.sublistItems objectAtIndex:indexPath.section - [relations count]];
            NSDictionary *item = [items objectAtIndex:indexPath.row];
            NSString *sublist = [self.sublists objectAtIndex:indexPath.section - [self.relations count]];
            if ([sublist isEqualToString:@"Attachment"]) {
                SublistItem *subItem = [SublistManager find:self.detail.entity sublist:@"Attachment" criterias:[NSArray arrayWithObject:[ValuesCriteria criteriaWithColumn:@"gadget_id" value:[item objectForKey:@"gadget_id"]]]];
                NSString *fileName = [UITools getAttachmentIcon:subItem];
                cell.imageView.image = [UIImage imageNamed:fileName];
            }
            cell.textLabel.text = [item objectForKey:@"Name"];
        }
        
        

        cell.selectionStyle = UITableViewCellSelectionStyleBlue;

    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if ([self.currentPage intValue] < [self.pages count]) {
        Section *section = [self.sections objectAtIndex:indexPath.section];
        NSString *code = [section.fields objectAtIndex:indexPath.row];
        if (section.isGrouping) {
            for (NSString *tmp in section.fields) {
                if ([tmp rangeOfString:@"Address"].length > 0) {
                    code = tmp;
                    break;
                }
            }
        }
        [UITools handleCellClick:self code:code item:self.detail updateListener:self];
        if ([longFields containsObject:code]) {
            CRMField *field = [FieldsManager read:self.detail.entity field:code];
            LongTextViewController *longTextVC = [[LongTextViewController alloc] initWithText:[detail.fields objectForKey:code] title:field.displayName];
            [self.navigationController pushViewController:longTextVC animated:YES];
            [longTextVC release];
        }
    } else {
        if (indexPath.section < [self.relations count]) {
            NSString *otherSubtype = [relations objectAtIndex:indexPath.section];
            NSObject <Subtype> *rsinfo = [Configuration getSubtypeInfo:otherSubtype];
            NSArray *items = [self.relatedItems objectForKey:otherSubtype];
            NSDictionary *relatedItem = [items objectAtIndex:indexPath.row];
            if (![[relatedItem objectForKey:@"gadget_id"] isEqualToString:@"-1"]) {
                Item *otherDetail = [EntityManager find:[rsinfo entity] column:@"gadget_id" value:[relatedItem objectForKey:@"gadget_id"]];
                BigDetailViewController *otherVC = [[BigDetailViewController alloc] initDetail:otherSubtype parent:self.parent];
                [otherVC setCurrentDetail:otherDetail];
                [self.navigationController pushViewController:otherVC animated:YES];
                [otherVC release];
            }
        } else {          
            NSString *sublist = [self.sublists objectAtIndex:indexPath.section - [self.relations count]];
            NSArray *subItems = [self.sublistItems objectAtIndex:indexPath.section - [self.relations count]];
            NSDictionary *subDict = [subItems objectAtIndex:indexPath.row];
            NSArray *criterias = [NSArray arrayWithObjects:[ValuesCriteria criteriaWithColumn:@"parent_oid" value:[detail.fields valueForKey:@"Id"]], [ValuesCriteria criteriaWithColumn:@"gadget_id" value:[subDict objectForKey:@"gadget_id"]], nil];
            SublistItem *subItem = [SublistManager find:self.detail.entity sublist:sublist criterias:criterias];
            SublistDetailPopup *sublistpopup = [[SublistDetailPopup alloc] initWithItem:subItem parentItem:self.detail listener:self navController:self.parent.itemViewController.navigationController];
            [sublistpopup show:[tableView cellForRowAtIndexPath:indexPath].frame parentView:tableView];
            [sublistpopup release];
        }
        
    }
    
}


- (void)edit {
    
    EditViewController *editController = [[EditViewController alloc] initWithDetail:self.detail updateListener:self.parent isCreate:NO action:nil];

    [[self navigationController] pushViewController:editController animated:YES];
    // Clean up resources
    [editController release];
    
}

- (void)clickToCollape:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    NSMutableArray *indexes = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *list = [self.sectionData objectAtIndex:button.tag];
    
    if ([list count] > 0) {
        [button setBackgroundImage:[UIImage imageNamed:@"toggle-right.png"] forState:UIControlStateNormal];
        for (int i = 0; i < [list count]; i++) {
            [indexes addObject:[NSIndexPath indexPathForRow:i inSection:button.tag]];
        }
        
        [list removeAllObjects]; // must delete before animating
        [self.detailView deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];     
    } else {
        // must add before animating
        [list addObjectsFromArray:[self fillSectionData:button.tag]];
        for (int i = 0; i < [list count]; i++) {
            [indexes addObject:[NSIndexPath indexPathForRow:i inSection:button.tag]];
        }
        [self.detailView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];
        if ([list count] > 0) {
            [button setBackgroundImage:[UIImage imageNamed:@"toggle-down.png"] forState:UIControlStateNormal];
        }
        
    }
    
}



- (void)addFavorite:(id)sender {

    UIButton *button = (UIButton *)sender;
    
    if ([[detail.fields objectForKey:@"favorite"] isEqualToString:@"0"] || [detail.fields objectForKey:@"favorite"]==nil) {
        [button setBackgroundImage:[UIImage imageNamed:@"btn_star_big_on.png"] forState:UIControlStateNormal];
        [detail.fields setValue:@"1" forKey:@"favorite"];
        
    } else {
        [button setBackgroundImage:[UIImage imageNamed:@"btn_star_big_off.png"] forState:UIControlStateNormal];
        [detail.fields setValue:@"0" forKey:@"favorite"];
        
    }
    [EntityManager update:detail modifiedLocally:NO];
    [parent refresh];
}

- (void)faceBookLinkedIn:(id)sender {
    UIButton *btn =( UIButton *)sender;
    NSString *type = btn.tag==0 ? @"Facebook" : @"LinkedIn";
    
    FaceBookLinkedInView *faceBook = [[FaceBookLinkedInView alloc]initwithItem:self.detail subtype:self.sinfo type:type];
    [self.navigationController pushViewController:faceBook animated:YES];
    [faceBook release];    
}

- (void)tabPagesChange:(id)sender {
    [self mustUpdate];    
}



// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController:(MGSplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {

    self.popoverController = nil;
}


- (void)mustUpdate {
    
   
    self.detail = [EntityManager find:[self.sinfo entity] column:@"gadget_id" value:[self.detail.fields objectForKey:@"gadget_id"]];
    
    if ([self.detail.fields objectForKey:@"error"] != nil) {
        [self.detailView setTableHeaderView:self.errorView];
        ((UITextView *) [self.errorView.subviews objectAtIndex:1]).text = [self.detail.fields objectForKey:@"error"];
    } else if([detail.entity isEqualToString:@"Contact"]){
        [self.detailView setTableHeaderView:header];
    } else {
        [self.detailView setTableHeaderView:nil];
    }
    
    //update increase importaint once visit record detail
    if (self.detail!=nil) {
        [EntityManager increaseImportance:detail];
    }


    self.currentPage = [NSNumber numberWithInt:self.segmentedControl.selectedSegmentIndex];
    
    int sectionCount;
    NSMutableArray *tmpData = [[NSMutableArray alloc] initWithCapacity:1];
    [self.sections release];
    if ([self.currentPage intValue] < [self.pages count]) {
        self.sections = [LayoutSectionManager read:self.subtype page:[self.currentPage intValue]];
        sectionCount = [self.sections count];
    } else {
        [self.relations removeAllObjects];
        [self.relatedItems release];
        self.relatedItems = [RelationManager getRelatedItems:self.detail];
        for (NSString *otherSubtype in self.relatedItems) {
            NSArray *items = [relatedItems objectForKey:otherSubtype];
            if ([items count] > 0 || [RelationManager isCreatable:otherSubtype from:self.sinfo.name entity:self.sinfo.entity]) {
                [self.relations addObject:otherSubtype];
            }
        }
        [self.sublists removeAllObjects];
        [self.sublistItems removeAllObjects];
        NSDictionary *tmpSublists = [SublistManager getSublists:self.detail];
        for (NSString *sublist in tmpSublists) {
            [self.sublists addObject:sublist];
            [self.sublistItems addObject:[tmpSublists objectForKey:sublist]];
        }
        self.sections = nil;
        sectionCount = [self.relations count] + [self.sublists count];
    }
    for (int i = 0; i <sectionCount; i++) {
        [tmpData addObject:[self fillSectionData:i]];
        
    }
    [self.sectionData release];
    self.sectionData = tmpData;

    if (self.detail == nil) {
        self.title = [NSString stringWithFormat:NSLocalizedString(@"DETAIL", @"Detail"), [sinfo localizedName]];
    } else {
        self.title = [self.sinfo getDisplayText:self.detail];
    }
    [self.navigationItem.rightBarButtonItem setEnabled:self.detail != nil];

    // add button
    if (self.detail != nil) {
        NSObject <EntityInfo> *info = [Configuration getInfo:[self.sinfo entity]];
        [self.navigationItem.rightBarButtonItem setEnabled:[info canUpdate]];
    } else {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
    [self checkAction];
    // Toolbar
    [self.toolbar setHidden:detail == nil];
    CGRect detailFrame = self.detailView.frame;
    if (detail == nil && detailFrame.origin.y == 44) {
        detailFrame.origin.y = 0;
        detailFrame.size.height += 44;
        [self.detailView setFrame:detailFrame];
    }
    if (detail != nil && detailFrame.origin.y == 0) {
        detailFrame.origin.y = 44;
        detailFrame.size.height -= 44;
        [self.detailView setFrame:detailFrame];
    }
    
        
    for (UIBarButtonItem *item in self.toolbar.items) {
        if (item.customView == nil || ![item.customView isKindOfClass:[UISegmentedControl class]]) {
            [item setEnabled:self.detail != nil];
            if(item == btnShowAction && self.detail != nil){
                NSObject <EntityInfo> *enInfo = [Configuration getInfo:self.detail.entity];
                [item setEnabled:([self.workAction count] > 0) || [enInfo canDelete]];
            }
            
        }
        if (item.tag == 20 && self.detail!=nil) {
            [item setEnabled:[self.currentPage intValue] < [self.pages count]];
        }
    }
    
    // picture and label for contact
    if ([detail.entity isEqualToString:@"Contact"]) {
        self.contactNameLabel.text = [self.sinfo getDisplayText:detail];
        self.accountNameLabel.text = [self.sinfo getDetailText:detail];
        UIImage *img;
        NSData *dataimg = [PictureManager read:[detail.fields objectForKey:@"gadget_id"]];
        if (dataimg!=nil) {
            img = [UIImage imageWithData:dataimg];
        } else {
            img = [UIImage imageNamed:@"no_picture.png"];
        }
        [self.contactPicture setImage:img];
    }
    
    // favorite button
    [self.favoriteButton setBackgroundImage:[UIImage imageNamed:[[self.detail.fields objectForKey:@"favorite"] isEqualToString:@"1"] ?@"btn_star_big_on.png":@"btn_star_big_off.png"] forState:UIControlStateNormal];
    
    [self.longFields removeAllObjects];
    
    //reload view
    [self.detailView reloadData];    
}


- (void)setCurrentDetail:(Item *)newDetail {
    self.detail = newDetail;
    if (self.detail != nil) {
        NSString *newSubtype = [Configuration getSubtype:self.detail];
        if (![newSubtype isEqualToString:self.subtype]) {
            self.subtype = newSubtype;
            self.sinfo = [Configuration getSubtypeInfo:self.subtype];
            self.pages = [LayoutPageManager read:self.subtype];
            [self buildToolbarItems];
        }
    }
    [[self navigationController] popToRootViewControllerAnimated:YES];

    [self mustUpdate];
}

- (void)viewWillAppear:(BOOL)animated{

    [self mustUpdate];

}

- (void)showActionSheet {
    
    if ([actionSheet isVisible]) {
        [actionSheet dismissWithClickedButtonIndex:0 animated:NO];
        return;
    }
    
    if (actionSheet) [actionSheet release];

    actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];

    for (Action *act in self.workAction) {
        [actionSheet addButtonWithTitle:[EvaluateTools translateWithPrefix:act.name prefix:@"ACTION_"]];
    }
    
    NSObject <EntityInfo> *info = [Configuration getInfo:detail.entity]; 
    if ([info canDelete]) {
    
        [actionSheet addButtonWithTitle:NSLocalizedString(@"DELETE", @"delete")];
        [actionSheet setDestructiveButtonIndex:[self.workAction count]];
        
    }
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"CANCEL", @"cancel")];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"CANCEL", @"cancel")];
    [actionSheet setCancelButtonIndex:[info canDelete]?[self.workAction count]+1:[self.workAction count]];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showFromBarButtonItem:btnShowAction animated:YES];
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// use "buttonIndex" to decide your action
	//
    if (alertView.tag == 1 && buttonIndex == 0) {
        [EntityManager remove:self.detail];
        [self.updateListener mustUpdate];
        [self.navigationController popToRootViewControllerAnimated:YES];
	} 
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
	if (buttonIndex < [self.workAction count]) {
        
        Action *action = [self.workAction objectAtIndex:buttonIndex];
        
        if ([action.name isEqualToString:@"Take Picture"]) {
            
            TakePictureController *takephoto = [[TakePictureController alloc] init];
            [takephoto showCameraParent:self.view];
            
        } else {
            if (action.update) {
        
                for (NSString *field in [action.fields keyEnumerator]) {
                    NSString *formula = [action.fields objectForKey:field];
                    NSString *value = [EvaluateTools evaluate:formula item:detail];
                    [detail.fields setObject:value forKey:field];
                }
                [EntityManager update:detail modifiedLocally:YES];
                [self mustUpdate];
                
            } else {
                
                Item *newItem = [action buildItem:self.detail];
                NSString *subType = [Configuration getSubtype:newItem];
                NSObject <Subtype> *subinfo = [Configuration getSubtypeInfo:subType];
                [subinfo fillItem:newItem];
                EditViewController *addViewController = [[EditViewController alloc] initWithDetail:newItem updateListener:self.parent isCreate:YES action:action.name];
                [[self navigationController] pushViewController:addViewController animated:YES];
                [newItem release];
            }
        }
	} 
    NSObject <EntityInfo> *info = [Configuration getInfo:detail.entity]; 
    if (buttonIndex == [self.workAction count] && [info canDelete]) {
        // open a alert with an OK and cancel button
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DELETE_CONFIRM", "Config delete") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"DELETE", nil) otherButtonTitles:NSLocalizedString(@"CANCEL", nil), nil];
        alert.tag = 1;
        [alert show];
        [alert release];
    }
	
}


- (void)checkAction {
    
    NSMutableArray *tmpAction = [[NSMutableArray alloc]initWithCapacity:0];
    for (Action *act in [self.sinfo actions]) {
        if (act.clone || act.update) {
            NSObject <EntityInfo> *info = [Configuration getInfo:detail.entity]; 
            if (![info canCreate]) {
                continue;
            }
        }  else {
            NSObject <EntityInfo> *info = [Configuration getInfo:act.entity]; 
            if (![info canCreate]) continue;
        }
        [tmpAction addObject:act];
    }
    
    
    self.workAction = tmpAction;
    [tmpAction release];
}

- (void)exportPDF {

    if ([self.currentPage intValue] < [self.pages count]) {
    
        DetailPDFExport *pdf = [[DetailPDFExport alloc]initWithDetail:self.detail Layout:sections type:self.sinfo];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pdf];
        [self.parent.navigationController presentModalViewController:nav animated:YES];
        [nav release];
        [pdf release];

    }

}

- (void)didCreate:(NSString *)entity key:(NSString *)key {
    [self mustUpdate];
}

@end
