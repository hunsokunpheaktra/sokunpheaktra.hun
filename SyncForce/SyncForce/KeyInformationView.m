//
//  KeyInformationView.m
//  SyncForce
//
//  Created by Gaeasys on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KeyInformationView.h"
#import "ValuesCriteria.h"
#import "NumberHelper.h"
#import "DatetimeHelper.h"
#import "FieldInfoManager.h"
#import "EntityManager.h"
#import "KeyFieldInfoManager.h"
#import "ObjectDetailViewController.h"

@implementation KeyInformationView

@synthesize tableKey, listFieldFilter,mapNameType;

-(id)initWitFrame : (CGRect)rect data:(Item *)item parent:(id)parent{
    self = [super init];
    frame = rect;
    detailitem = item;
    parentClass = parent;
    if (!entityInfo){
        entityInfo = [InfoFactory getInfo:detailitem.entity];
        mapNameType = [[NSMutableDictionary alloc] init];
    }
    NSMutableDictionary *criteria = [[NSMutableDictionary alloc] init];
    [criteria setValue:[[[ValuesCriteria alloc] initWithString:detailitem.entity] autorelease] forKey:@"objectName"];
    
    if(listFieldFilter)[listFieldFilter release];
    listFieldFilter = [KeyFieldInfoManager list:criteria];
    [criteria release];
    
    return self;
}


- (void)dealloc
{
    [super dealloc];
}



#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    
    UIView *mainscreen = [[UIView alloc] initWithFrame: frame]; 
    tableKey = [[[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain] autorelease];
    tableKey.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableKey.allowsSelection = NO;
    [tableKey setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableKey setSeparatorColor:[UIColor clearColor]];
    tableKey.scrollEnabled = NO;
    tableKey.delegate = self;
    tableKey.dataSource = self;
    
    [mainscreen addSubview:tableKey];
    
    self.view = mainscreen;
    
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


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
        
    cell.contentView.backgroundColor = [UIColor grayColor];
    for (UIView *view in cell.contentView.subviews) [view removeFromSuperview];
    
    float start_x = 0;
    float width = (tableView.frame.size.width/4) -1 ;
    for (int x = 0; x < [listFieldFilter count]; x++) {
        
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(start_x,0, width, 76)];
        [button setBackgroundColor:[UIColor colorWithRed:(247.0/255.0) green:(247.0/255.0) blue:(247.0/255.0) alpha:1]];
        
        UIButton* field = [UIButton buttonWithType:UIButtonTypeCustom]; //initWithFrame:CGRectMake(10, 5, width - 5,30)];
        [field setEnabled:NO];
        [field setFrame:CGRectMake(10, 5, width - 10,33)];
        [field setTitle:[[[listFieldFilter objectAtIndex:x] fields] objectForKey:@"fieldLabel"] forState:UIControlStateNormal];
        [field setBackgroundColor:[UIColor clearColor]];
        field.titleLabel.font = [UIFont systemFontOfSize:14];
        field.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [field.titleLabel setTextColor:[UIColor colorWithRed:(23.0/255.0) green:(155.0/255.0) blue:(192.0/255.0) alpha:1]];
        
        [button addSubview:field];
        
        UIButton* value = [UIButton buttonWithType:UIButtonTypeCustom]; //initWithFrame:CGRectMake(10, 35, width - 5,30)];
        [value setEnabled:NO];
        [value setFrame:CGRectMake(10, 35, width - 15,33)];
        [value setBackgroundColor:[UIColor clearColor]];
        value.titleLabel.font = [UIFont systemFontOfSize:15];
        
        NSString *fieldType;
        if([mapNameType.allValues count] == [listFieldFilter count]){
            fieldType = [mapNameType valueForKey:[[[listFieldFilter objectAtIndex:x] fields] objectForKey:@"fieldName"]];
        }else{
            fieldType =[[[entityInfo getFieldInfoByName:[[[listFieldFilter objectAtIndex:x] fields] objectForKey:@"fieldName"]] fields] objectForKey:@"type"]; 
            [mapNameType setValue:fieldType forKey:[[[listFieldFilter objectAtIndex:x] fields] objectForKey:@"fieldName"]];
        }
        
        
        if (![fieldType  isEqualToString:@"boolean"]){
            
            NSString *val =[detailitem.fields objectForKey:[[[listFieldFilter objectAtIndex:x] fields] objectForKey:@"fieldName"]];
            
            if ([fieldType  isEqualToString:@"currency"]) {
                val = [NumberHelper formatCurrencyValue:[val doubleValue]];
            }else if ([fieldType  isEqualToString:@"double"] || [fieldType  isEqualToString:@"int"]) {
                val = [NumberHelper formatNumberDisplay:[val doubleValue]];
            }else if([fieldType  isEqualToString:@"percent"]) {
                val = [NumberHelper formatPercentValue:[val doubleValue]];
            }else if([fieldType  isEqualToString:@"datetime"] || [fieldType  isEqualToString:@"date"]) {
                val = [DatetimeHelper display:val];
            
            }else if([fieldType  isEqualToString:@"reference"]){
            
                NSString* tmp = [[[listFieldFilter objectAtIndex:x] fields] objectForKey:@"fieldName"];
                
                if(((ObjectDetailViewController*)parentClass).parentClass) 
                    val = [[((CustomDataGrid*)((ObjectDetailViewController*)parentClass).parentClass).listener getValueBy:tmp recordId:val] objectForKey:@"Result"]; 
                else
                    val = [[(ObjectDetailViewController*)parentClass getValueBy:tmp recordId:val] objectForKey:@"Result"]; 
                
            }
            
            
            [value setTitle:val forState:UIControlStateNormal];
            value.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [value.titleLabel setTextColor:[UIColor darkTextColor]];
            
            [button addSubview:value];
        
        }else {
        
            UIImageView *checkBox = [[UIImageView alloc] initWithFrame:CGRectMake((width/2)-10, 40, 20,20)];
            checkBox.contentMode = UIViewContentModeScaleAspectFit;
            checkBox.image = [UIImage imageNamed:[[detailitem.fields objectForKey:[[[listFieldFilter objectAtIndex:x] fields] objectForKey:@"fieldName"]] isEqualToString:@"true"]?@"check_yes.png":@"check_no.png"];

            [button addSubview:checkBox];
            [checkBox release];

        }
        
    
        [cell.contentView addSubview:button];
        
        start_x = start_x + width + 1;
        if (x == 2) width = width +1;
        
    }

    
    return cell;    
}


@end
