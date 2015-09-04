//
//  CustomDataGridPaging.m
//  Datagrid
//
//  Created by Gaeasys on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomDataGridPaging.h"


@implementation CustomDataGridPaging

@synthesize bntTarget,bntNext,bntPrev;
@synthesize record;

-(id)initWithPopulate:(id)target frame:(CGRect)rect{
    
    self =  [super init];
    self.view.frame = rect;
    bntTarget = target;
    return self;
}

- (void)dealloc{
    [super dealloc];
}




#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

- (void)viewDidLoad{
    
    [self.view setBackgroundColor:[UIColor colorWithRed:0.1 green:0.3 blue:0.5 alpha:0.5]];
    
    myToolbar = [[UIToolbar alloc] initWithFrame:self.view.frame];
    myToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    bntPrev = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:bntTarget action:@selector(prevClick:)] autorelease];
    bntPrev.style = UIBarButtonItemStyleBordered;
    
    record = [[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:bntTarget action:nil] autorelease];
    record.width = 100;
    
    bntNext = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:bntTarget action:@selector(nextClick:)] autorelease];
    bntNext.style = UIBarButtonItemStyleBordered;
    
    myToolbar.items = [NSArray arrayWithObjects:bntPrev,record,bntNext, nil];
    self.view = myToolbar;
    [myToolbar release];
    
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


@end
