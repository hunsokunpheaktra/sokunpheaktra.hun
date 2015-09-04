//
//  EditView.m
//  SyncForce
//
//  Created by Gaeasys Admin on 10/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditView.h"
#import "Entity.h"
#import "EntityManager.h"
#import "Datagrid.h"
#import "AppDelegate.h"

@implementation EditView
@synthesize fieldinfos,mode,entity,currentItem,tagMapper,objectId,scroll,titletext;


-(id)initWithMode:(NSString *)pmode entity:pentity{
    self.mode = pmode;
    self.entity = pentity;
    [super init];
    return self;
}


- (void)dealloc
{
    [objectId release];
    [tagMapper release];
    [currentItem release];
    [entity release];
    [mode release];
    [fieldinfos release];
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
    
    self.scroll=[[UIScrollView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.view=scroll;
    self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    NSMutableDictionary *dicData = [[NSMutableDictionary alloc] init];
    if([self.mode isEqualToString:[Datagrid getAddImg]]){
        self.fieldinfos = [Entity getFieldsCreateable:self.entity];
        for(Item *item in [self fieldinfos]){
            [dicData setValue:@"" forKey:[item.fields valueForKey:@"name"]];
        }
        [dicData setValue:self.objectId forKey:@"AccountId"];
    }else{
        self.fieldinfos = [Entity getFieldsUpdateable:self.entity];
        Item *tmp = [EntityManager find:self.entity column:@"Id" value:self.objectId];
        for(Item *item in [self fieldinfos]){
            NSString *fieldName = [item.fields valueForKey:@"name"];
            [dicData setValue:[tmp.fields valueForKey:fieldName] forKey:fieldName];
        }
        [dicData setValue:self.objectId forKey:@"Id"];
    }
    self.currentItem = [[Item alloc] init:self.entity fields:dicData];
    
    UIView *mainscreen = [[UIView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    mainscreen.backgroundColor = self.view.backgroundColor;
    
    
    int x = 50, y = 90 , h = 40, w = 220;
    int i = 0;
    
    UILabel *titlelabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10 , mainscreen.frame.size.width, 60)];
    [titlelabel setFont:[UIFont boldSystemFontOfSize:22]];
    titlelabel.backgroundColor = [UIColor clearColor];
    titlelabel.textAlignment = UITextAlignmentCenter;
    titlelabel.text = self.titletext;
    titlelabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [mainscreen addSubview:titlelabel];
    
    
    self.tagMapper = [[NSMutableDictionary alloc] init];
    for(Item *item in [self fieldinfos]){
        NSString *fieldName = [item.fields valueForKey:@"name"];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(x, y, w, h)];
        [label setFont:[UIFont boldSystemFontOfSize:16]];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = UITextAlignmentLeft;
        label.text = [item.fields valueForKey:@"label"];
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [mainscreen addSubview:label];
        
        UITextField *textdata = [[UITextField alloc] initWithFrame:CGRectMake(x + w, y, w * 2, h)];
        [textdata setBorderStyle:UITextBorderStyleRoundedRect];
        textdata.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textdata.delegate = self;
        textdata.returnKeyType = UIReturnKeyNext;
        textdata.text = [[self.currentItem fields] objectForKey:fieldName ];
        textdata.tag = i;
        [mainscreen addSubview:textdata];
        
        [tagMapper setValue:fieldName forKey:[[NSString alloc] initWithFormat:@"%d",i]];
        y = y + h;
        i++;
        
    }
    
    
    UIButton *btnSave = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnSave setTitle:NSLocalizedString(@"SAVE", Nil) forState:UIControlStateNormal];
    btnSave.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [btnSave setFrame:CGRectMake(x + w, y + 10, 160, 40)];
    [btnSave addTarget:self action:@selector(saveClick:) forControlEvents:UIControlEventTouchDown];
    [mainscreen addSubview:btnSave];
    
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnCancel setTitle:NSLocalizedString(@"CANCEL", Nil) forState:UIControlStateNormal];
    btnCancel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [btnCancel setFrame:CGRectMake(x + w + 160 + 10, y + 10, 160, 40)];
    [btnCancel addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchDown];
    [mainscreen addSubview:btnCancel];
    mainscreen.autoresizingMask= UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [scroll addSubview:mainscreen];
    [scroll setContentSize:CGSizeMake(mainscreen.frame.size.width, mainscreen.frame.size.height)];
    
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSString *value = textField.text;
    NSString *fieldname = [self.tagMapper valueForKey:[NSString stringWithFormat:@"%d",textField.tag]];
    [[self.currentItem fields] setObject:value forKey:fieldname];
}

- (void)saveClick:(id)sender {
    NSString* info;
    if([mode isEqualToString:[Datagrid getAddImg]]){
        info = [[NSString alloc] initWithFormat:NSLocalizedString(@"RECORD_SAVE", Nil),self.entity];
        NSString *localid = [NSString stringWithFormat:@"%d",[EntityManager getCount:self.currentItem.entity] + 1];
        [self.currentItem.fields setValue:localid forKey:@"Id"];
        [self.currentItem.fields setValue:@"2" forKey:@"modified"];
        [self.currentItem.fields setValue:@"0" forKey:@"error"];
        [self.currentItem.fields setValue:@"0" forKey:@"deleted"];
        [EntityManager insert:self.currentItem modifiedLocally:NO];


    }else if([mode isEqualToString:[Datagrid getEditImg]]){
        info = [[NSString alloc] initWithFormat:NSLocalizedString(@"RECORD_SAVE", Nil),self.entity];
        [self.currentItem.fields setValue:@"0" forKey:@"error"];
        [EntityManager update:self.currentItem modifiedLocally:YES];
        
    }
    
    
    UIAlertView* alert=[[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@",self.entity] message:  info delegate:self cancelButtonTitle:NSLocalizedString(@"OK", Nil) otherButtonTitles:nil];
    [alert show];
    [alert release];
    
}

- (void)cancelClick:(id)sender{
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [delegate.theNavController dismissModalViewControllerAnimated:YES];
}

@end
