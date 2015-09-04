//
//  ErrorDetailView.m
//  CRMiOS
//
//  Created by Sy Pauv on 7/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "ErrorDetailView.h"


@implementation ErrorDetailView
@synthesize  item;
@synthesize errorLogView;
@synthesize fixError;

- (id)initWithLog:(LogItem *)newlog{
    self.item=newlog;
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

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = item.type;
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc]init];
    [formatter2 setDateFormat:@"HH:mm:ss"];
    CGRect rect = [[UIScreen mainScreen]bounds];
    self.errorLogView = [[UITextView alloc]initWithFrame:rect];
    self.errorLogView.text = [NSString stringWithFormat:@"Time : %@\n%@", [formatter2 stringFromDate:item.date], item.message];
    [self.errorLogView setFont:[UIFont systemFontOfSize:16]];
    self.errorLogView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.errorLogView setEditable:NO];
   
    if (self.item.errorId != nil && self.item.entity != nil) {
        
        UIBarButtonItem *fixerror = [[UIBarButtonItem alloc]initWithTitle:@"Fix Error" style:UIBarButtonItemStyleBordered target:self action:@selector(goToFixError)];
        self.navigationItem.rightBarButtonItem = fixerror;
        [fixerror release];
    }    
    
    self.view = self.errorLogView;
    

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
- (void)goToFixError{


    Item *errorItem = [EntityManager find:item.entity column:@"gadget_id" value:item.errorId];
    if(errorItem==nil){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Record Not Found!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        [alert release];
        return;
    }
    DetailViewController *detail=[[DetailViewController alloc] initWithItem:errorItem listener:nil];
    [self.navigationController pushViewController:detail animated:YES];
    [detail release];

}

@end
