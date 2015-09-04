//
//  DetailPDFExport.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/2/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "DetailPDFExport.h"

#define kDefaultPageHeight 792
#define kDefaultPageWidth  612
#define kMargin 50
#define kColumnMargin 10

@implementation DetailPDFExport
@synthesize info,sections,item;

- (id)initWithDetail:(Item *)newItem Layout:(NSArray *)detail type:(NSObject<Subtype> *) type;{

    self.info = type;
    self.sections = detail;
    self.item = newItem;
    return [super init];
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    if (self.item == nil) {
        self.title = [NSString stringWithFormat:NSLocalizedString(@"DETAIL", @"Detail"), [info localizedName]];
    } else {
        self.title = [self.info getDisplayText:self.item];
    }

    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(back)] autorelease];
    
    self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"ATTACH_EMAIL", nil) style:UIBarButtonItemStyleDone target:self action:@selector(sendMail)]autorelease];
    
    [self drawPDFLayout];
    [self showPDFFile];
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

-(void)drawPDFLayout{

    NSString *fileName= [self getPDFFileName];
    
    NSDateFormatter *dateFormat=[[[NSDateFormatter alloc]init]autorelease];
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    
    // Create the PDF context using the default page size of 612 x 792.
    // This default is spelled out in the iOS documentation for UIGraphicsBeginPDFContextToFile
    UIGraphicsBeginPDFContextToFile(fileName, CGRectZero, nil);
    
    // get the context reference so we can render to it. 
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat maxWidth = kDefaultPageWidth - kMargin * 2;
    CGFloat maxHeight = kDefaultPageHeight - kMargin * 2;
    
    CGFloat fieldNameMaxWidth = maxWidth / 2;
    
    // the max width of the grade is also half, minus the margin
    CGFloat valueMaxWidth = (maxWidth / 2) - kColumnMargin;
    
    // only create the fonts once since it is a somewhat expensive operation
    UIFont* objectFont = [UIFont boldSystemFontOfSize:15];
    UIFont* displayTextFont = [UIFont systemFontOfSize:12];
    CGFloat currentPageY = 0;
    
    NSString* header = [info getDisplayText:item];
    for (Section *section in sections)
    {

        if (currentPageY==0) {
            // Mark the beginning of a new page.
            UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, kDefaultPageWidth, kDefaultPageHeight), nil);
            currentPageY = kMargin + 50;
            
            //draw display value every top of the page
            CGContextSetFillColorWithColor(context, [[UIColor grayColor] CGColor]);
            [header drawAtPoint:CGPointMake(kMargin, currentPageY-30) forWidth:maxWidth withFont:objectFont lineBreakMode:UILineBreakModeWordWrap];
            
            //draw Company logo
            [self drawCompanyLogo];
            
        }else{
            
            //add some space between header and record
            currentPageY += 5;
        }

        // draw the section's name 
        NSString* name = [EvaluateTools translateWithPrefix:section.name prefix:@"HEADER_"];
        CGSize size = [name sizeWithFont:objectFont forWidth:maxWidth lineBreakMode:UILineBreakModeWordWrap];
        
        //draw section header background
        CGContextSetFillColorWithColor(context,  [[UITools readHexColorCode:[Configuration getProperty:@"headerColor"]] CGColor]);
        CGContextFillRect(context, CGRectMake(kMargin, currentPageY, maxWidth, size.height ));
        CGContextSaveGState(context);
        
        //draw section header with white color
        CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
        [name drawAtPoint:CGPointMake(kMargin + 5, currentPageY) forWidth:maxWidth withFont:objectFont lineBreakMode:UILineBreakModeWordWrap];
        
        size.height+=5;
        currentPageY += size.height;
        
        NSArray* fields = section.fields;
        for(NSString *field in fields)
        {
            CRMField *crmfield = [FieldsManager read:item.entity field:field];
            NSString* fieldName = crmfield.displayName;
            NSString* value = [UITools formatPDFDisplayValue:crmfield value:self.item];
        
            // before we render any text to the PDF, we need to measure it, so we'll know where to render the next line.
            size = [value sizeWithFont:displayTextFont constrainedToSize:CGSizeMake(fieldNameMaxWidth, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
            
            // if the current text would render beyond the bounds of the page, 
            // start a new page and render it there instead
            if (size.height + currentPageY > maxHeight + 30) {
                
                //add footer message
                [self drawReportFooter:maxWidth height:maxHeight];
                
                // create a new page and reset the current page's Y value
                UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, kDefaultPageWidth, kDefaultPageHeight), nil);
                currentPageY = kMargin;
                
                //draw display value every top of the page
                CGContextSetFillColorWithColor(context, [[UIColor grayColor] CGColor]);
                [header drawAtPoint:CGPointMake(kMargin, currentPageY - 40) forWidth:maxWidth withFont:objectFont lineBreakMode:UILineBreakModeWordWrap];
                
            }
            
            // render the text
             CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
            [fieldName drawInRect:CGRectMake(kMargin + 15, currentPageY, fieldNameMaxWidth, maxHeight) withFont:displayTextFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
            
            // print the value to the right of the field name
             CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
            [value drawInRect:CGRectMake(kMargin + fieldNameMaxWidth + kColumnMargin, currentPageY, valueMaxWidth+5, maxHeight) withFont:displayTextFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];

             currentPageY += size.height;            
           
        }
        
    }
    
    //add footer message
    [self drawReportFooter:maxWidth height:maxHeight];
    
    // end and save the PDF. 
    UIGraphicsEndPDFContext();

}

- (void)drawCompanyLogo{
    
    CGFloat maxWidth = kDefaultPageWidth - kMargin * 2;
    NSData *dimage=[Configuration companyLogo];
    UIImage *myImage = [UIImage imageWithData:dimage];
    CGRect imageRect = CGRectMake(maxWidth - 100, 35, 150, 40);
    [myImage drawInRect:imageRect];

}

- (void)drawReportFooter:(CGFloat)maxWidth height:(CGFloat)maxHeight{
    
    UIFont* footerFont = [UIFont systemFontOfSize:9]; 
    // Get the graphics context.
    CGContextRef    context = UIGraphicsGetCurrentContext();
    
    NSString *footer = [Configuration getProperty:@"reportFooter"];
    CGSize size = [footer sizeWithFont:footerFont constrainedToSize:CGSizeMake(maxWidth, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
    //153/153/153
    CGContextSetFillColorWithColor(context, [[UITools readHexColorCode:@"666666"] CGColor]);
    [footer drawInRect:CGRectMake(kMargin, maxHeight+60, maxWidth, size.height) withFont:footerFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];

}


- (void)sendMail{
    
    // email the PDF File. 
    MFMailComposeViewController* mailComposer = [[MFMailComposeViewController alloc] init] ;
    mailComposer.mailComposeDelegate = self;
    [mailComposer addAttachmentData:[NSData dataWithContentsOfFile:[self getPDFFileName]]
                           mimeType:@"application/pdf" fileName:@"detail.pdf"];
    
    [self presentModalViewController:mailComposer animated:YES];     
    [mailComposer release];

}


- (NSString*)getPDFFileName {
    
    NSString* fileName = @"detail.pdf";
    
    NSArray *arrayPaths = 
        NSSearchPathForDirectoriesInDomains(
                                        NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    NSString *path = [arrayPaths objectAtIndex:0];
    NSString* pdfFileName = [path stringByAppendingPathComponent:fileName];
    
    return pdfFileName;

}

-(void)showPDFFile
{
    NSString* pdfFileName = [self getPDFFileName];
    UIWebView* webView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen]bounds]];
    webView.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    NSURL *url = [NSURL fileURLWithPath:pdfFileName];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView setScalesPageToFit:YES];
    [webView loadRequest:request];
    [self.view addSubview:webView];
    
}

-(void)back{

    [self dismissModalViewControllerAnimated:YES];

}

#pragma mark - MFMailComposerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error 
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
