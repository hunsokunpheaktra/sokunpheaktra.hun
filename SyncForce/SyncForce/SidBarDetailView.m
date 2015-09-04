//
//  SidBarDetailView.m
//  SyncForce
//
//  Created by Gaeasys on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SidBarDetailView.h"
#import "ObjectDetailViewController.h"
#import "JTRevealSidebarView.h"
#import "JTNavigationView.h"
#import "JTTableViewDatasource.h"
#import "JTTableViewCellModal.h"
#import "JTTableViewCellFactory.h"
#import "RelatedListsInfoManager.h"
#import "EntityManager.h"
#import "NumberHelper.h"
#import "DatetimeHelper.h"
#import "FieldInfoManager.h"

typedef enum {
    JTTableRowTypeBack,
    JTTableRowTypePushContentView,
} JTTableRowTypes;

@interface SidBarDetailView (UITableView) <JTTableViewDatasourceDelegate>
@end



@implementation SidBarDetailView

@synthesize sideBarTableView;
@synthesize start_number, end_number;

- (id)initWithRevealView:(JTRevealSidebarView*)revealView entityName:(NSString*)entity parent:(id)pView{
    self = [super init];
    if (self) {
        
        _revealView = revealView;
        parentView = pView;
        listKeyFiled = ((ObjectDetailViewController*)parentView).keyInfo.listFieldFilter;
        mapFieldType = ((ObjectDetailViewController*)parentView).keyInfo.mapNameType;
        
        if ((((ObjectDetailViewController*)parentView).parentId) && (((ObjectDetailViewController*)parentView).childType)) {
    
            NSMutableDictionary *criterias = [[[NSMutableDictionary alloc] init] autorelease];
            [criterias setValue:[[[ValuesCriteria alloc] initWithString:(((ObjectDetailViewController*)parentView).parentType)] autorelease] forKey:@"entity"];
            [criterias setValue:[[[ValuesCriteria alloc] initWithString:(((ObjectDetailViewController*)parentView).childType)] autorelease] forKey:@"sobject"];
            Item* tmp = [RelatedListsInfoManager find:criterias];
        
            [criterias removeAllObjects]; 
            [criterias setValue:[[[ValuesCriteria alloc] initWithString:(((ObjectDetailViewController*)parentView).parentId)] autorelease] forKey:[tmp.fields objectForKey:@"field"]];
    
            rows = [[EntityManager list:(((ObjectDetailViewController*)parentView).childType) criterias:criterias] retain];
            
        }
        else rows = [[EntityManager list:entity criterias:nil] retain];

        _datasource = [[JTTableViewDatasource alloc] init];
        _datasource.sourceInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"root", @"url", nil];
        _datasource.delegate   = self;
        
       // start_number = ((ObjectDetailViewController*)parentView).start_number;
       // rowSelect = ((ObjectDetailViewController*)parentView).selectedRowNumber;
        
        listView = [rows copy];
        cellArray = [[NSMutableArray alloc] init];
        isPair = YES;

    }
    return self;
}


#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)viewDidLoad
{
    

    for (int x = 0; x < [listView count]; x++) {
        Item* tmp = [listView objectAtIndex:x];
        rowSelect = x;
        if ([((ObjectDetailViewController*)parentView).objectId isEqualToString:[tmp.fields objectForKey:@"Id"]]) {
            break;
        }
    }
    
    
    UISearchBar* searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0,270, 50)] autorelease];
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchBar.showsCancelButton = NO;
    searchBar.delegate = self;
    
    UIView *mainscreen = [[UIView alloc] initWithFrame:_revealView.sidebarView.bounds];
    self.view = mainscreen;

    
   // UIView* v = [[UIView alloc] init];
   // [v setBackgroundColor:[UIColor colorWithRed:(228.0/255.0) green:(245.0/255.0) blue:(251.0/255.0) alpha:1]];
    
    CGRect rect = _revealView.sidebarView.bounds;
    rect.origin.y = 50;
    rect.size.height = rect.size.height - 50;
    sideBarTableView = [[[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain] autorelease];
    sideBarTableView.delegate = _datasource;
    sideBarTableView.dataSource = _datasource;
  //  [sideBarTableView setBackgroundView:v];
    
    sideBarTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:searchBar];
    [self.view addSubview:sideBarTableView];
    
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


#pragma mark Helper

- (void)simulateDidSucceedFetchingDatasource:(JTTableViewDatasource *)datasource {
    NSString *url = [datasource.sourceInfo objectForKey:@"url"];
    NSMutableArray* arr = [[[NSMutableArray alloc] init] autorelease];
    
   // int end = (end_number>[rows count])?[rows count]:end_number;    
    //NSLog(@"=== %d", [[listView retain] count]);

    for (Item* item in listView) { // for (int x = start_number;x< end;x++) {
        
        NSString* rowTitle = @"";
        
        if([((ObjectDetailViewController*)parentView).detail.entity isEqualToString:@"Case"] ||
           [((ObjectDetailViewController*)parentView).detail.entity isEqualToString:@"Task"] ||
           [((ObjectDetailViewController*)parentView).detail.entity isEqualToString:@"Event"]
            ) {
            
            rowTitle = [item.fields objectForKey:@"Subject"]; 
        } 
        else if ([((ObjectDetailViewController*)parentView).detail.entity isEqualToString:@"Contract"]) 
             rowTitle = @"ContractNumber";
        else rowTitle = [item.fields objectForKey:@"Name"];
            
            
        NSString* rowData = @"";

       for (int x = 0; x < 2; x++) {                
                
                NSString* fieldType = [mapFieldType valueForKey:[[[listKeyFiled objectAtIndex:x] fields] objectForKey:@"fieldName"]];
                NSString* tmprowData = [self getFormatValue:[item.fields objectForKey:[[[[listKeyFiled retain] objectAtIndex:x] fields] objectForKey:@"fieldName"]] type:fieldType fieldName:[[[listKeyFiled objectAtIndex:x] fields] objectForKey:@"fieldName"]];
                tmprowData = tmprowData != nil ? tmprowData : @"";
                NSString* separator = @" - ";
                rowData = [NSString stringWithFormat:@"%@%@%@", rowData,separator,tmprowData];
        }
        
        rowData = [rowData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];    
        if ([rowData hasSuffix:@"-"]) rowData = [rowData substringToIndex:[rowData length]-1];
        if ([rowData hasPrefix:@"-"]) rowData = [rowData substringFromIndex:1];
        
        
        if ([cellArray count] < [rows count]) [cellArray addObject:[[NSDictionary alloc] initWithObjectsAndKeys:rowTitle,@"Title",rowData,@"Detail", nil]];
        
        [arr addObject:[JTTableViewCellModalSimpleType modalWithTitle:rowTitle data:rowData type:JTTableRowTypePushContentView]];
    }
  
    if ([url isEqualToString:@"root"]) {
        [datasource configureSingleSectionWithArray:arr];
        
    } else if ([url isEqualToString:@"push"]) {
        [datasource configureSingleSectionWithArray:
        [NSArray arrayWithObject:
         [JTTableViewCellModalSimpleType modalWithTitle:@"Back " data:@"" type:JTTableRowTypeBack]
          ]
         ];
    } else {
        NSAssert(NO, @"not handled!", nil);
    }
    
 
    NSIndexPath* indexSaved =[NSIndexPath indexPathForRow:rowSelect inSection:0];
    [sideBarTableView selectRowAtIndexPath:indexSaved animated:NO scrollPosition:UITableViewScrollPositionNone];
 
   

}

- (void)loadDatasourceSection:(JTTableViewDatasource *)datasource {
    [self performSelector:@selector(simulateDidSucceedFetchingDatasource:) withObject:datasource afterDelay:1];
}

-(NSString *) getFormatValue:(NSString*)origin type:(NSString*)type fieldName:(NSString*)fName{
    
    NSString* rowData = origin;
   
    if (![type isEqualToString:@"boolean"]) {
        if ([type isEqualToString:@"currency"])
            rowData = [NumberHelper formatCurrencyValue:[rowData doubleValue]] ;
        else if ([type isEqualToString:@"double"] || [type isEqualToString:@"int"] )
            rowData = [NumberHelper formatNumberDisplay:[rowData doubleValue]];
        else if ([type isEqualToString:@"percent"])
            rowData = [NumberHelper formatPercentValue:[rowData doubleValue]];
        else if ([type isEqualToString:@"date"] ||
                 [type isEqualToString:@"datetime"] )
            rowData =  [DatetimeHelper display:rowData];
        else if ([type isEqualToString:@"reference"]) {
      
          // rowData = [[((CustomDataGrid*)((ObjectDetailViewController*)parentView).parentClass).listener getValueBy:fName recordId:rowData] objectForKey:@"Result"];
           rowData = @"";  
        }    
    } else rowData = @"";
    
    return rowData;
}

@end



@implementation SidBarDetailView (UITableView)

- (BOOL)datasourceShouldLoad:(JTTableViewDatasource *)datasource {
    if ([datasource.sourceInfo objectForKey:@"url"]) {
        [self loadDatasourceSection:datasource];
        return YES;
    } else {
        return NO;
    }
}

- (UITableViewCell *)datasource:(JTTableViewDatasource *)datasource tableView:(UITableView *)tableView cellForObject:(NSObject *)object {
    
    if ([object conformsToProtocol:@protocol(JTTableViewCellModalLoadingIndicator)]) {
        static NSString *cellIdentifier = @"loadingCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [JTTableViewCellFactory loaderCellWithIdentifier:cellIdentifier];
        }
        return cell;
    } else if ([object conformsToProtocol:@protocol(JTTableViewCellModal)]) {

        static NSString *cellIdentifier = @"titleCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
        }
        
        for (UIView *view in cell.contentView.subviews) [view removeFromSuperview];

        
        if (isPair) {
         [cell.contentView setBackgroundColor:[UIColor colorWithRed:(247/255.0) green:(249/255.0) blue:(250/255.0) alpha:1]];
            isPair = NO;
        }    
        else {
         [cell.contentView setBackgroundColor:[UIColor colorWithRed:(233.0/255.0) green:(240.0/255.0) blue:(242.0/255.0) alpha:1]];
            isPair = YES;
        }
            
        cell.textLabel.textColor = [UIColor darkGrayColor];
        [cell.textLabel setBackgroundColor:[UIColor clearColor]];
        cell.textLabel.text = [(id <JTTableViewCellModal>)object title];
        cell.detailTextLabel.textColor = [UIColor darkTextColor];
        [cell.detailTextLabel setBackgroundColor:[UIColor clearColor]];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
        cell.detailTextLabel.text = [(id <JTTableViewCellModal>)object data]; 
        cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        [cell.detailTextLabel setNumberOfLines:2];

        return cell;
        
    } else if ([object conformsToProtocol:@protocol(JTTableViewCellModalCustom)]) {
        id <JTTableViewCellModalCustom> custom = (id)object;
        JTTableViewDatasource *datasource = (JTTableViewDatasource *)[[custom info] objectForKey:@"datasource"];
        if (datasource) {
            static NSString *cellIdentifier = @"datasourceCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = [[custom info] objectForKey:@"title"];
                     
            return cell;
        }
    }
    return nil;
}

- (void)datasource:(JTTableViewDatasource *)datasource tableView:(UITableView *)tableView didSelectObject:(NSObject *)object {
    
    //  UIInterfaceOrientation mainOrientation = [[UIApplication sharedApplication] statusBarOrientation];


//    Item* tmItem = [rows objectAtIndex:([[tableView indexPathForSelectedRow] row]) + start_number];
//    rowSelect = [[tableView indexPathForSelectedRow] row] + start_number;

    Item* tmItem = [listView objectAtIndex:([[tableView indexPathForSelectedRow] row])];
    //rowSelect = [[tableView indexPathForSelectedRow] row];

    
    if ([object conformsToProtocol:@protocol(JTTableViewCellModalCustom)]) {
        id <JTTableViewCellModalCustom> custom = (id)object;
        JTTableViewDatasource *datasource = (JTTableViewDatasource *)[[custom info] objectForKey:@"datasource"];
        if (datasource) {
            UITableView *tableView = [[[UITableView alloc] initWithFrame:_revealView.sidebarView.bounds] autorelease];
            tableView.delegate   = datasource;
            tableView.dataSource = datasource;
            tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [_revealView.sidebarView pushView:tableView animated:YES];
        }
    } else if ([object conformsToProtocol:@protocol(JTTableViewCellModalSimpleType)]) {        
        switch ([(JTTableViewCellModalSimpleType *)object type]) {
            case JTTableRowTypeBack:
                [_revealView.sidebarView popViewAnimated:YES];
                UITableView *tableView = sideBarTableView; //(UITableView *)[_revealView.sidebarView topView];
                [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
                break;
            case JTTableRowTypePushContentView:
            {
                
                CGRect rect = [[[(ObjectDetailViewController*)parentView keyInfo] tableKey] frame];
                [(ObjectDetailViewController*)parentView init:tmItem mode:@"Edit" objectId:[tmItem.fields objectForKey:@"Id"]];
                [[(ObjectDetailViewController*)parentView keyInfo] initWitFrame:rect data:tmItem parent:parentView];
                [[[(ObjectDetailViewController*)parentView keyInfo] tableKey] reloadData]; 
                [[(ObjectDetailViewController*)parentView tableDetail] reloadData];
                [(ObjectDetailViewController*)parentView reloadRelatedList];
                
                UIView *v = [[[UIView alloc] init] autorelease];
                v.title = ((ObjectDetailViewController*)parentView).title;
                [_revealView.contentView setRootView:v];
    
            
            }
            default:
                break;
        }
    }
    
    
    for (int x = 0; x < [rows count]; x++) {
        Item* tmp = [rows objectAtIndex:x];
        rowSelect = x;
        if ([((ObjectDetailViewController*)parentView).objectId isEqualToString:[tmp.fields objectForKey:@"Id"]]) {
            break;
        }
    }
    
    
}


- (void)datasource:(JTTableViewDatasource *)datasource sectionsDidChanged:(NSArray *)oldSections {
    [(UITableView *)sideBarTableView reloadData];
}


#pragma mark UISearchBarDelegate 

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

     
    NSMutableArray *searchResult = [[[NSMutableArray alloc] init] autorelease];

    if ([searchText length]>0) {
        
        for (int x = 0; x < [cellArray count] ; x++) {
            NSDictionary* cell = [cellArray objectAtIndex:x];
            NSString* textLabel = [cell objectForKey:@"Title"];
            
            if ([textLabel rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [searchResult addObject:[rows objectAtIndex:x]];               
            }else{
                
                NSString* textDetailLabel = [cell objectForKey:@"Detail"];
                NSArray*tmp = [textDetailLabel componentsSeparatedByString:@"-"];
                
                for (NSString* str in tmp) {
                    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if([str length]>0 && ![str isEqualToString:@""]) {
                        if ([str rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                            [searchResult addObject:[rows objectAtIndex:x]];
                            break;
                        }
                    }   
                }

            }
            
        }
        
        
    }else searchResult = [rows copy];
    
    [listView release];
    listView = [searchResult copy];          
    
    for (int x = 0; x < [listView count]; x++) {
        Item* tmp = [listView objectAtIndex:x];
        if ([((ObjectDetailViewController*)parentView).objectId isEqualToString:[tmp.fields objectForKey:@"Id"]]) {
            rowSelect = x;
            break;
        } rowSelect = -1;
    }
    
    [self loadDatasourceSection:_datasource];

}



-(void)prevClick:(id) sender {
    if(start_number-10 >= 0) {    
        end_number = start_number;
        start_number = end_number - 10;
        [self loadDatasourceSection:_datasource];
    }    
}

-(void)nextClick:(id) sender {
    if(start_number + 10 <= [rows count]) {   
        start_number = end_number;
        end_number = start_number + 10;
        [self loadDatasourceSection:_datasource];
    }   
}


@end
