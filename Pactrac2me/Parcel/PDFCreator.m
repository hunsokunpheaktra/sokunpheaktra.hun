//
//  PDFCreator.m
//  Pactrac2me
//
//  Created by Hun Sokunpheaktra on 2/15/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "PDFCreator.h"
#import "Base64.h"
#import "ProviderManager.h"
#import "NSObject+SBJson.h"
#import "ParcelItem.h"
#import "PhotoUtile.h"

#define kDefaultPageHeight 792
#define kDefaultPageWidth  612
#define kMargin 30
#define kColumnMargin 10

@implementation PDFCreator

-(id)initWithItem:(Item*)item parentController:(UIViewController*)parent{
    self = [super init];
    self.item = item;
    self.parentController = parent;
    return self;
}

-(void)generatePDF{
    
    // get a temprorary filename for this PDF
    NSString *path = NSTemporaryDirectory();
    self.pdfFilePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"Proof of Delivery.pdf"]];
    
//    //underline text    
//    NSDictionary *attributesDict = @{NSUnderlineStyleAttributeName : [NSNumber numberWithInt:NSUnderlineStyleSingle], NSForegroundColorAttributeName : [UIColor blueColor], NSFontAttributeName : [UIFont systemFontOfSize:20]};
    
    // Create the PDF context using the default page size of 612 x 792.
    // This default is spelled out in the iOS documentation for UIGraphicsBeginPDFContextToFile
    UIGraphicsBeginPDFContextToFile(self.pdfFilePath, CGRectZero, nil);
    
    // get the context reference so we can render to it.
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // maximum height and width of the content on the page, byt taking margins into account.
    CGFloat maxWidth = kDefaultPageWidth - (kMargin * 2);
    CGFloat maxHeight = kDefaultPageHeight - (kMargin * 2);
    
    CGRect pageFrame = CGRectMake( 0, 0, kDefaultPageWidth, kDefaultPageHeight );
    UIGraphicsBeginPDFPageWithInfo(pageFrame, nil);
    
    //title
    NSString *title = @"PACTRAC2ME App";
    [title drawInRect:CGRectMake(kMargin, 15, maxWidth, 40) withFont:[UIFont boldSystemFontOfSize:30] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
    
    //subtitle
    NSString *subTitle = [NSString stringWithFormat:@"%@ ---PROOF OF DELIVERY---",[self.item.fields objectForKey:@"forwarder"]];
    [subTitle drawInRect:CGRectMake(kMargin, 55, maxWidth, 40) withFont:[UIFont boldSystemFontOfSize:25] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
    
    // draw up line
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextMoveToPoint(context, 30, 100);
    CGContextAddLineToPoint(context, kDefaultPageWidth - 30, 100);
    CGContextSetLineWidth(context, 1.5);
    CGContextStrokePath(context);
    
    //shipment text
    NSString *shipment = [NSString stringWithFormat:@"%@ - ",[self.item.fields objectForKey:@"forwarder"]];
    [@"Shipment : " drawInRect:CGRectMake(30, 120, maxWidth, 40) withFont:[UIFont systemFontOfSize:20] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    [shipment drawInRect:CGRectMake(130, 120, maxWidth, 40) withFont:[UIFont boldSystemFontOfSize:20] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    CGSize size = [shipment sizeWithFont:[UIFont boldSystemFontOfSize:20]];
    
    CGSize textSize = [[self.item.fields objectForKey:@"trackingNo"] sizeWithFont:[UIFont boldSystemFontOfSize:20]];
    
    CGRect textFrame = CGRectMake(130 + size.width + 5, 120, textSize.width, textSize.height);
    CGRect linkFrame = textFrame;
    
    NSString *urlForProvider = [ProviderManager getPoviderURL:[self.item.fields objectForKey:@"forwarder"]];
    urlForProvider = urlForProvider == nil ? @"" : urlForProvider;
    NSString *openURL = [NSString stringWithFormat:urlForProvider,[self.item.fields objectForKey:@"trackingNo"]];
    
    NSString *trackingNo = [self.item.fields objectForKey:@"trackingNo"];
    linkFrame.origin.y = pageFrame.size.height - linkFrame.origin.y - linkFrame.size.height;
    
    if(urlForProvider){
        UIGraphicsSetPDFContextURLForRect([NSURL URLWithString:openURL], linkFrame );
    }
    
    [[UIColor blueColor] set];
    [trackingNo drawInRect:textFrame withFont:[UIFont systemFontOfSize:20]];
    
    CGContextSetStrokeColorWithColor(context, [[UIColor blueColor] CGColor]);
    CGContextSetLineWidth(context, 1);
    CGContextMoveToPoint(context, textFrame.origin.x, (textFrame.origin.y + textSize.height) - 3);
    CGContextAddLineToPoint(context, textFrame.origin.x + textSize.width , (textFrame.origin.y + textSize.height) - 3);
    CGContextStrokePath(context);
    
    [[UIColor blackColor] set];
    
    //status text
    [@"Delivery status from forwarder." drawInRect:CGRectMake(30, 150, maxWidth, 40) withFont:[UIFont systemFontOfSize:20] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    NSString *status = [self.item.fields objectForKey:@"status"];
    textSize = [status sizeWithFont:[UIFont boldSystemFontOfSize:20]];
    
    [[UIColor colorWithRed:(218./255.) green:(218./255.) blue:(218./255.) alpha:1.0] set];
    CGContextFillRect(context, CGRectMake(30, 177, textSize.width+10, textSize.height+10));
    [[UIColor blackColor] set];
    
    [status drawInRect:CGRectMake(35, 182, textSize.width, 40) withFont:[UIFont boldSystemFontOfSize:20]];
    CGContextSetLineWidth(context, 0.5);
    CGContextStrokeRect(context, CGRectMake(30, 177, textSize.width+10, textSize.height+10));
    
    //receiver
    NSString *receiver = [self.item.fields objectForKey:@"receiver"];
    [@"Receiver : " drawInRect:CGRectMake(30, 215, maxWidth, 40) withFont:[UIFont systemFontOfSize:20] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    [receiver drawInRect:CGRectMake(130, 215, maxWidth, 40) withFont:[UIFont boldSystemFontOfSize:20] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    
    //shipping date
    NSString *shippingDate = [self.item.fields objectForKey:@"shippingDate"];
    [@"Shipping Date :" drawInRect:CGRectMake(30, 245, maxWidth, 40) withFont:[UIFont systemFontOfSize:20] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    [shippingDate drawInRect:CGRectMake(180, 245, maxWidth, 40) withFont:[UIFont boldSystemFontOfSize:20] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    
    float currentPageY = 275;
    
    for(NSDictionary *fieldItem in [ParcelItem allDataInfo]){
        
        NSString *fieldLabel = [fieldItem objectForKey:@"fieldLabel"];
        NSString *fieldName = [fieldItem objectForKey:@"fieldName"];
        fieldLabel = [NSString stringWithFormat:@"%@ :",fieldLabel];
        NSString *value = [self.item.fields objectForKey:fieldName];
        
        textSize = [fieldLabel sizeWithFont:[UIFont systemFontOfSize:20]];
        size = [value sizeWithFont:[UIFont boldSystemFontOfSize:20]];
        
        [fieldLabel drawInRect:CGRectMake(30, currentPageY, textSize.width, textSize.height) withFont:[UIFont systemFontOfSize:20]];
        [value drawInRect:CGRectMake(30 + textSize.width + 5 , currentPageY, size.width, size.height) withFont:[UIFont boldSystemFontOfSize:20]];
        
        currentPageY += textSize.height + 10;
        
    }
    
    currentPageY += 10;
    textSize = [@"Add this shipment to PACTRAC2ME" sizeWithFont:[UIFont systemFontOfSize:20]];
    textFrame = CGRectMake(30, currentPageY, textSize.width, textSize.height);
    linkFrame = textFrame;
    
    linkFrame.origin.y = pageFrame.size.height - linkFrame.origin.y - linkFrame.size.height;
    
    //add data to link
    NSMutableDictionary *fields = [NSMutableDictionary dictionaryWithDictionary:self.item.fields];
    [fields removeObjectForKey:@"id"];
    [fields removeObjectForKey:@"local_id"];
    
    NSMutableDictionary *attachments = [NSMutableDictionary dictionary];
    for(NSString *key in self.item.attachments.allKeys){
        
        Item *item = [self.item.attachments objectForKey:key];
        NSMutableDictionary *attFields = [NSMutableDictionary dictionaryWithDictionary:item.fields];
        [attFields removeObjectForKey:@"Id"];
        [attFields removeObjectForKey:@"local_id"];
        
        [attachments setObject:attFields forKey:key];
        
    }
    [fields setObject:attachments forKey:@"attachments"];
    
    NSString *jsonString = [fields.JSONRepresentation stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    UIGraphicsSetPDFContextURLForRect([NSURL URLWithString:[NSString stringWithFormat:@"parcel://addParcel/%@",jsonString]], linkFrame );
    
    [[UIColor blueColor] set];
    CGContextSetStrokeColorWithColor(context, [[UIColor blueColor] CGColor]);
    CGContextSetLineWidth(context, 1);
    CGContextMoveToPoint(context, textFrame.origin.x, (textFrame.origin.y + textSize.height) - 3);
    CGContextAddLineToPoint(context, textFrame.origin.x + textSize.width , (textFrame.origin.y + textSize.height) - 3);
    CGContextStrokePath(context);
    
    [@"Add this shipment to PACTRAC2ME" drawInRect:textFrame withFont:[UIFont systemFontOfSize:20]];
    
    [[UIColor blackColor] set];
    
    currentPageY += 50;
    float width = 0;
    float height = 0;
    
    //add invoice image
    Item *att = [self.item.attachments objectForKey:@"invoiceImage"];
    NSString *b64img=att==nil?@"":[att.fields objectForKey:@"body"];
    UIImage *invoiceImage = [UIImage imageWithData:[Base64 decode:b64img]];
    invoiceImage = [UIImage imageWithData:[PhotoUtile resizeImage:invoiceImage]];
    
    width = invoiceImage.size.width > maxWidth ? maxWidth : invoiceImage.size.width;
    height = invoiceImage.size.height > width ? width : invoiceImage.size.height;
    if(invoiceImage){
        
        if(currentPageY + height > maxHeight){
            UIGraphicsBeginPDFPageWithInfo(pageFrame, nil);
            currentPageY = kMargin;
        }
        
        [@"Invoice Image" drawInRect:CGRectMake(30, currentPageY, maxWidth, 40) withFont:[UIFont systemFontOfSize:20] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
        [invoiceImage drawInRect:CGRectMake(30, currentPageY + 30, width, height)];
        
        currentPageY += height + 60;
    }
    
    //create new page
    if(currentPageY > maxHeight){
        UIGraphicsBeginPDFPageWithInfo(pageFrame, nil);
        currentPageY = kMargin;
    }
    
    //add picture content1
    att = [self.item.attachments objectForKey:@"pictureContent1"];
    b64img=att==nil?@"":[att.fields objectForKey:@"body"];
    UIImage *pictureContent1 = [UIImage imageWithData:[Base64 decode:b64img]];
    pictureContent1 = [UIImage imageWithData:[PhotoUtile resizeImage:pictureContent1]];
    
    width = pictureContent1.size.width > maxWidth ? maxWidth : pictureContent1.size.width;
    height = pictureContent1.size.height > width ? width : pictureContent1.size.height;
    if(pictureContent1){
        
        if(currentPageY + height > maxHeight){
            UIGraphicsBeginPDFPageWithInfo(pageFrame, nil);
            currentPageY = kMargin;
        }
        
        [@"Picture Content" drawInRect:CGRectMake(30, currentPageY, maxWidth, 40) withFont:[UIFont systemFontOfSize:20] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
        [pictureContent1 drawInRect:CGRectMake(30, currentPageY + 30, width, height)];
        
        currentPageY += height + 60;
        
    }
    
    if(currentPageY > maxHeight){
        UIGraphicsBeginPDFPageWithInfo(pageFrame, nil);
        currentPageY = kMargin;
        
    }
    
    //add picture content2
    att = [self.item.attachments objectForKey:@"pictureContent2"];
    b64img=att==nil?@"":[att.fields objectForKey:@"body"];
    UIImage *pictureContent2 = [UIImage imageWithData:[Base64 decode:b64img]];
    pictureContent2 = [UIImage imageWithData:[PhotoUtile resizeImage:pictureContent2]];
    
    width = pictureContent2.size.width > maxWidth ? maxWidth : pictureContent2.size.width;
    height = pictureContent2.size.height > width ? width : pictureContent2.size.height;
    if(pictureContent2){
        
        if(currentPageY + height > maxHeight){
            UIGraphicsBeginPDFPageWithInfo(pageFrame, nil);
            currentPageY = kMargin;
        }
        
        [@"Picture Content" drawInRect:CGRectMake(30, currentPageY, maxWidth, 40) withFont:[UIFont systemFontOfSize:20] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
        [pictureContent2 drawInRect:CGRectMake(30, currentPageY + 30, width, height)];
        
        currentPageY += height + 80;
        
    }
    
    if(currentPageY > maxHeight){
        UIGraphicsBeginPDFPageWithInfo(pageFrame, nil);
        currentPageY = kMargin;
    }
    
    // draw down line
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextMoveToPoint(context, 30, currentPageY);
    CGContextAddLineToPoint(context, kDefaultPageWidth - 30, currentPageY);
    CGContextSetLineWidth(context, 1.5);
    CGContextStrokePath(context);
    
    //footer
    NSString *footer = @"This report is created by ";
    [footer drawInRect:CGRectMake(80, currentPageY+12, maxWidth, 40) withFont:[UIFont systemFontOfSize:20] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    size = [footer sizeWithFont:[UIFont systemFontOfSize:20]];
    
    textSize = [@"PACTRAC2ME" sizeWithFont:[UIFont boldSystemFontOfSize:20]];
    textFrame = CGRectMake(80 + size.width + 5, currentPageY+12, textSize.width, textSize.height);
    linkFrame = textFrame;
    
    linkFrame.origin.y = pageFrame.size.height - linkFrame.origin.y - linkFrame.size.height;
    UIGraphicsSetPDFContextURLForRect([NSURL URLWithString:@"parcel://myParcels"], linkFrame );
    
    [[UIColor blueColor] set];
    CGContextSetStrokeColorWithColor(context, [[UIColor blueColor] CGColor]);
    CGContextSetLineWidth(context, 1);
    CGContextMoveToPoint(context, textFrame.origin.x, (textFrame.origin.y + textSize.height) - 3);
    CGContextAddLineToPoint(context, textFrame.origin.x + textSize.width , (textFrame.origin.y + textSize.height) - 3);
    CGContextStrokePath(context);
    
    [@"PACTRAC2ME" drawInRect:textFrame withFont:[UIFont systemFontOfSize:20]];
    
    [[UIColor blackColor] set];
    
    [@" for iOS" drawInRect:CGRectMake(textFrame.origin.x + textSize.width, currentPageY+12, maxWidth, 40) withFont:[UIFont systemFontOfSize:20] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    
    // end and save the PDF.
    UIGraphicsEndPDFContext();

    // present a preview of this PDF File.
    QLPreviewController *preview = [[QLPreviewController alloc] init];
    preview.dataSource = self;
    [self.parentController presentModalViewController:preview animated:YES];
    [preview release];
    
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return [NSURL fileURLWithPath:self.pdfFilePath];
}

@end
