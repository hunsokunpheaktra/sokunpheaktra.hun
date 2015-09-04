//
//  PDFViewController.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 3/20/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "PDFViewController.h"
#import "CoreText/CoreText.h"

#define kDefaultPageHeight 612
#define kDefaultPageWidth  792
#define kMargin 40
#define kColumnMargin 10

@implementation PDFViewController

@synthesize listData, info, section;

- (id)initWithData:(NSArray *)data info:(NSObject<Subtype> *)newInfo {

    self = [super init];
    self.info = newInfo;
    if ([self.info.pdfLayout.sections count] > 0) {
        self.section = [self.info.pdfLayout.sections objectAtIndex:0];
    } else {
        self.section = [[LayoutSectionManager read:self.info.name page:0] objectAtIndex:0];
    }

    [self reloadData:data];
    return self;
}

- (void)reloadData:(NSArray *)datas {
    self.listData = [[NSMutableArray alloc] initWithCapacity:1];
    for (Item *item in datas) {
        Item *it= [EntityManager find:[self.info entity] column:@"gadget_id" value:[item.fields objectForKey:@"gadget_id"]];
        if (item!=nil) {
            [self.listData addObject:it];
        }
    }

}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad { 
    
    self.title = @"PDF";
    self.navigationItem.leftBarButtonItem=[[[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(back)]autorelease];
    
    self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc]initWithTitle:@"Send Report" style:UIBarButtonItemStyleDone target:self action:@selector(sendMail)]autorelease];

    NSString* fileName = [self getPDFFileName];
    [self drawPDF:fileName];
    [self showPDFFile];
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

-(void)showPDFFile {
    NSString* pdfFileName = [self getPDFFileName];
    UIWebView* webView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen]bounds]];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    NSURL *url = [NSURL fileURLWithPath:pdfFileName];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView setScalesPageToFit:YES];
    [webView loadRequest:request];
    [self.view addSubview:webView];
    
}

- (NSString*)getPDFFileName {
    NSString* fileName = @"report.pdf";
    
    NSArray *arrayPaths = 
    NSSearchPathForDirectoriesInDomains(
                                        NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    NSString *path = [arrayPaths objectAtIndex:0];
    NSString* pdfFileName = [path stringByAppendingPathComponent:fileName];
    
    return pdfFileName;
    
}

- (void)back {
    [self dismissModalViewControllerAnimated:YES];
}

-(void)sendMail {

    // email the PDF File.
    
    MFMailComposeViewController* mailComposer = [[MFMailComposeViewController alloc] init] ;
    mailComposer.mailComposeDelegate = self;
    [mailComposer addAttachmentData:[NSData dataWithContentsOfFile:[self getPDFFileName]]
                           mimeType:@"application/pdf" fileName:@"report.pdf"];
    [mailComposer setSubject:@"CRM4Mobile PDF Report"];
    if (mailComposer) [self presentModalViewController:mailComposer animated:YES];
    [mailComposer release];

    
}

-(void)drawPDF:(NSString*)fileName {

    NSDateFormatter *dateFormat = [[[NSDateFormatter alloc]init]autorelease];
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    
    NSString *date = [dateFormat stringFromDate:[NSDate date]];
    // Create the PDF context using the lanscape page size of  792 x 612 .
    // This default is spelled out in the iOS documentation for UIGraphicsBeginPDFContextToFile
    UIGraphicsBeginPDFContextToFile(fileName, CGRectZero, nil);
    
    // get the context reference so we can render to it. 
    // CGContextRef context = UIGraphicsGetCurrentContext();
    

    CGFloat maxWidth = kDefaultPageWidth - kMargin * 2;
    CGFloat maxHeight = kDefaultPageHeight - kMargin * 2;
    
    CGFloat colummWidth = maxWidth / [self.section.fields count];
    
    // the max width of the grade is also half, minus the margin
   // CGFloat gradeMaxWidth = (maxWidth / 2) - kColumnMargin;
    
    
    // only create the fonts once since it is a somewhat expensive operation
    UIFont* objectFont = [UIFont boldSystemFontOfSize:17];
    UIFont* detailFont = [UIFont systemFontOfSize:12];

    CGFloat currentPageY = 0;
    // Mark the beginning of a new page.
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, kDefaultPageWidth, kDefaultPageHeight), nil);
    currentPageY = kMargin;
    
    // draw the object's name at the top of the page. 
    NSString* name = [info localizedPluralName];
    
    CGSize size = [name sizeWithFont:objectFont forWidth:maxWidth lineBreakMode:UILineBreakModeWordWrap];
    [name drawAtPoint:CGPointMake(kMargin, currentPageY) forWidth:maxWidth withFont:objectFont lineBreakMode:UILineBreakModeWordWrap];

    //draw date
   [date drawAtPoint:CGPointMake(kDefaultPageWidth-100, currentPageY) forWidth:maxWidth withFont:detailFont lineBreakMode:UILineBreakModeWordWrap];    

    currentPageY += size.height;
    
    //draw table header
    CGFloat headerheight=[self drawTableHeader:currentPageY colummWidth:colummWidth];
    
    currentPageY+=headerheight;
    
    // draw a one pixel line under the object's name
    [self drawSeparateLine:currentPageY color:[UIColor blueColor]];

    
    // print displaytext of object
    for(Item *item in listData) {
        if (currentPageY > maxHeight ) {
            
            //add footer message
            [self drawReportFooter:maxWidth height:maxHeight];
            // create a new page and reset the current page's Y value
            UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, kDefaultPageWidth, kDefaultPageHeight), nil);
            currentPageY = kMargin;
            
        }

        CGFloat valHeight =[self drawValue:item colummWidth:colummWidth y:currentPageY];
        //draw separate line between each record
        [self drawSeparateLine:currentPageY color:[UIColor lightGrayColor]];
        
        currentPageY += valHeight;
        
    }
     //draw footer
    [self drawReportFooter:maxWidth height:maxHeight];
  
    // end and save the PDF. 
    UIGraphicsEndPDFContext();
    
}

- (CGFloat)drawValue:(Item *)item colummWidth:(CGFloat)cWidth y:(CGFloat)y{
    CGFloat height = 0;
    UIFont* font = [UIFont systemFontOfSize:9];
    CGFloat maxHeight = kDefaultPageHeight - kMargin * 2;
    int x = kMargin;
    for (NSString *field in self.section.fields) {
        NSString *value = [item.fields objectForKey:field];
        
        CRMField *crmfield = [FieldsManager read:item.entity field:field];
        value = [UITools formatPDFDisplayValue:crmfield value:item];
        CGSize size= [value sizeWithFont:font constrainedToSize:CGSizeMake(cWidth, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
        
        if (size.height>height) {
            height=size.height;
        }
        // render the text
        [value drawInRect:CGRectMake(x, y, cWidth, maxHeight) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
        x += cWidth + 3;
    }
    return height;
    
    return 0;
}

- (CGFloat)drawTableHeader:(CGFloat)y colummWidth:(CGFloat)cWidth{
    
    CGFloat height = 0;
    UIFont* tableHeaderFont=[UIFont boldSystemFontOfSize:12];
    CGFloat maxHeight = kDefaultPageHeight - kMargin * 2;
    int x=kMargin;
    for (NSString *field in self.section.fields) {
        CRMField *crmfield = [FieldsManager read:info.entity field:field];
        CGSize size= [[crmfield displayName] sizeWithFont:tableHeaderFont constrainedToSize:CGSizeMake(cWidth, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
        
        if (size.height>height) {
            height=size.height;
        }
       
        // render the text
        [[crmfield displayName] drawInRect:CGRectMake(x, y, cWidth, maxHeight) withFont:tableHeaderFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
        x+=cWidth + 3;
        
    }
    return height;
}

- (void)drawSeparateLine:(CGFloat)y color:(UIColor *)color;{
    
    // get the context reference so we can render to it. 
    CGContextRef context = UIGraphicsGetCurrentContext();
    // draw a one pixel line to separate each record
    CGContextSetStrokeColorWithColor(context, [color CGColor]);
    CGContextMoveToPoint(context, kMargin, y);
    CGContextAddLineToPoint(context, kDefaultPageWidth - kMargin, y);
    CGContextStrokePath(context);
    
}

- (void)drawReportFooter:(CGFloat)maxWidth height:(CGFloat)maxHeight{
    
    UIFont* footerFont = [UIFont systemFontOfSize:9]; 
    // Get the graphics context.
    CGContextRef    context = UIGraphicsGetCurrentContext();
    
    NSString *footer = [Configuration getProperty:@"reportFooter"];
    CGSize size = [footer sizeWithFont:footerFont constrainedToSize:CGSizeMake(maxWidth, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
    
    CGContextSetFillColorWithColor(context, [[UITools readHexColorCode:@"666666"] CGColor]);
    [footer drawInRect:CGRectMake(kMargin, maxHeight+60, maxWidth, size.height) withFont:footerFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
    
}

#pragma mark - MFMailComposerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error 
{
    [self dismissModalViewControllerAnimated:YES];
}


@end