//
//  ScanViewController.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 6/23/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "ScanViewController.h"


@implementation ScanViewController


@synthesize textScan;

- (id)init
{
    self = [super init];
    return self;
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


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    UIView *mainView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    UIButton *buttonScan = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [buttonScan setFrame:CGRectMake(mainView.frame.size.width / 2 - 100, 10, 200, 40)];
    [buttonScan setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [buttonScan setTitle:@"Scan Barcode" forState:UIControlStateNormal];
    [buttonScan addTarget:self action:@selector(scanClick:) forControlEvents:UIControlEventTouchDown];
    [mainView addSubview:buttonScan];
    
    textScan = [[UITextView alloc] initWithFrame:CGRectMake(mainView.frame.size.width / 2 - 100, 60, 200, 40)];
    [textScan setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [textScan setTextAlignment:UITextAlignmentCenter];
    [textScan setFont:[UIFont systemFontOfSize:15]];
    [mainView addSubview:textScan];
    
    [self setView:mainView];
}

- (void)scanClick:(id)sender {
//    // ADD: present a barcode reader that scans from the camera feed
//    ZBarReaderViewController *reader = [ZBarReaderViewController new];
//    reader.readerDelegate = self;
//    
//    ZBarImageScanner *scanner = reader.scanner;
//    // TODO: (optional) additional reader configuration here
//    
//    // EXAMPLE: disable rarely used I2/5 to improve performance
//    [scanner setSymbology: ZBAR_I25
//                   config: ZBAR_CFG_ENABLE
//                       to: 0];
//    
//    // present and release the controller
//    [self presentModalViewController: reader
//                            animated: YES];
//    [reader release];
}


- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
//    // ADD: get the decode results
//    id<NSFastEnumeration> results =
//    [info objectForKey: ZBarReaderControllerResults];
//    ZBarSymbol *symbol = nil;
//    for(symbol in results)
//        // EXAMPLE: just grab the first barcode
//        break;
//    
//    // EXAMPLE: do something useful with the barcode data
//    [textScan setText:symbol.data];
//
//    
//    // ADD: dismiss the controller (NB dismiss from the *reader*!)
//    [reader dismissModalViewControllerAnimated: YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}


@end
