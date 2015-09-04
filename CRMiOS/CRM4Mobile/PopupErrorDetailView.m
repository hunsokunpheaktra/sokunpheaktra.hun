//
//  PopupErrorDetailView.m
//  CRMiOS
//
//  Created by Sy Pauv on 7/18/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "PopupErrorDetailView.h"


@implementation PopupErrorDetailView
@synthesize item;
@synthesize errorLogView;
@synthesize popoverController;

- (id)initWithLog:(LogItem *)newlog{
    self.item=newlog;
    return [super init];
}


#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
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

- (void) show:(CGRect)rect parentView:(UIView *)parentView {
    if([self.popoverController isPopoverVisible])
    {
        //close the popover view if toolbar button was touched
        //again and popover is already visible
        
        [self.popoverController dismissPopoverAnimated:YES];
        [self release];
        return;
    }
    
    //build our custom popover view
    UINavigationController *popoverContent = [[UINavigationController alloc]
                                              initWithRootViewController:self];
    
    //resize the popover view shown
    //in the current view to the view's size
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc]init];
    [formatter2 setDateFormat:@"HH:mm:ss"];
 
    self.title = NSLocalizedString(([NSString stringWithFormat:@"LOG_%@", self.item.type]), nil);
    self.contentSizeForViewInPopover = CGSizeMake(450, [item.type isEqualToString:@"ERROR"] || [item.type isEqualToString:@"WARNING"]?200:100);
    UIView *mainView = [[UIView alloc] init];
    self.errorLogView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0,450, 200)];
    self.errorLogView.text= [NSString stringWithFormat:@"\nTime  : %@ \n%@", [formatter2 stringFromDate:item.date], item.message];
    [self.errorLogView setFont:[UIFont boldSystemFontOfSize:16]];
    self.errorLogView.textColor = [item.type isEqualToString:@"ERROR"] || [item.type isEqualToString:@"WARNING"]? [UIColor redColor]:[UIColor blueColor];
    [self.errorLogView setEditable:NO];
    [mainView addSubview:self.errorLogView];
    
    if (self.item.errorId != nil && self.item.entity != nil) {
        
        UIButton *goFix = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [goFix setTitle:@"Fix Error" forState:UIControlStateNormal];
        [goFix setFrame:CGRectMake(330, 5, 100, 35)];
         goFix.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [goFix addTarget:self action:@selector(goToFixError) forControlEvents:UIControlEventTouchDown];
        [errorLogView addSubview:goFix];
        
    }     
    
    [self setView:mainView];
    //create a popover controller
    self.popoverController = [[UIPopoverController alloc]
                              initWithContentViewController:popoverContent];
    
    //present the popover view non-modal with a
    //refrence to the toolbar button which was pressed
    [self.popoverController presentPopoverFromRect:rect inView:parentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    [popoverContent release];
    
}

- (void)goToFixError{

    Item *newitem = [EntityManager find:item.entity column:@"gadget_id" value:item.errorId];
    [PadTabTools navigateTab:newitem];    
    [self.popoverController dismissPopoverAnimated:YES];

}


@end
