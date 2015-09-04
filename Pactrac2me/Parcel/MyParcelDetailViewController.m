//
//  MyParcelDetailViewController.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 10/5/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "MyParcelDetailViewController.h"
#import "NewParcelViewController.h"
#import "PhotoUtile.h"
#import "ParcelEntityManager.h"
#import "MyPhoto.h"
#import "MyPhotoSource.h"
#import "ParcelItem.h"
#import "Base64.h"
#import "MainViewController.h"
#import "ProviderManager.h"
#import "PDFCreator.h"
#import "NSObject+SBJson.h"

@implementation MyParcelDetailViewController

@synthesize tableView,currentItem,updateListener;

-(id)initWithItem:(Item*)item{
    self = [super init];
    currentItem = item;
    
    self.title = PARCEL_DETAIL;
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editItem)] autorelease];
    
    return self;
}

-(void)editItem{
    
    Item* editItem = [[Item alloc] init:currentItem.entity fields:currentItem.fields];
    editItem.attachments = [[NSMutableDictionary alloc]initWithDictionary:currentItem.attachments];
    NewParcelViewController *edit = [[NewParcelViewController alloc] initWithItem:editItem];
    edit.updateListener = self;
    [self.navigationController pushViewController:edit animated:YES];
    [edit release];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *background = [[[UIView alloc] initWithFrame:self.tableView.frame] autorelease];
    background.backgroundColor = [UIColor colorWithRed:(213./255.) green:(182./255.) blue:(145./255.) alpha:1];
    self.tableView.backgroundView = background;
    
    CGRect frame = self.view.frame;
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    [tableView release];
    
    sections = [ParcelItem allSections];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sections.count;
}

-(CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *section = [sections objectAtIndex:indexPath.section];
    NSDictionary *fieldItem = [section objectAtIndex:indexPath.row];
    NSString *fieldName = [fieldItem objectForKey:@"fieldName"];
    NSString *value = [self.currentItem.fields objectForKey:fieldName];
    
    if([fieldName rangeOfString:@"pictureContent"].location != NSNotFound) return 50;
    
    if([fieldName isEqualToString:@"sendProofOfDelivery"]){
        return 60;
    }
    if([fieldName isEqualToString:@"forwarderLink"]){
        return 70;
    }
    if([fieldName isEqualToString:@"note"]){
        return 80;
    }
    if([fieldName isEqualToString:@"status"]){
        if(value.length > 40) return 70;
    }
    
    return indexPath.section==0?100:45;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) return 1;
    
    NSArray *sec = [sections objectAtIndex:section];
    return sec.count;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    for(UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSArray *section = [sections objectAtIndex:indexPath.section];
    NSDictionary *fieldItem = [section objectAtIndex:indexPath.row];
    NSString *fieldName = [fieldItem objectForKey:@"fieldName"];
    NSString *fieldLabel = [fieldItem objectForKey:@"fieldLabel"];
    NSString *value = [currentItem.fields objectForKey:fieldName];
    value = value == nil ? @"" : value;
    
    CGRect frame = [tv rectForRowAtIndexPath:indexPath];
    
    if(indexPath.section == 0){
        
        UIView *background = [[UIView alloc] initWithFrame:cell.frame];
        background.backgroundColor = [UIColor clearColor];
        cell.backgroundView = background;
        [background release];
        
        Item *att=[currentItem.attachments objectForKey:@"invoiceImage"];
        NSString *b64img=att==nil?@"":[att.fields objectForKey:@"body"];
        UIImage *image = [UIImage imageWithData:[Base64 decode:b64img]];

        UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        imageButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
        if(image){
            [imageButton setImage:image forState:UIControlStateNormal];
        }else{
            [imageButton setImage:[UIImage imageNamed:@"camera-library@2x.png"] forState:UIControlStateNormal];
        }
        [imageButton addTarget:self action:@selector(previewImage:) forControlEvents:UIControlEventTouchUpInside];
        imageButton.frame = CGRectMake(5, 0, 120, 100);
        imageButton.backgroundColor = [UIColor colorWithRed:(248./255.) green:(246./255.) blue:(246./255.) alpha:1];
        [cell.contentView addSubview:imageButton];
        
        UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(140, 5, frame.size.width-160, 30)];
        description.backgroundColor = [UIColor clearColor];
        description.text = value;
        description.font = [UIFont boldSystemFontOfSize:18];
        [cell.contentView addSubview:description];
        [description release];
        
        UILabel *trackingNo = [[UILabel alloc] initWithFrame:CGRectMake(140, 40, frame.size.width-160, 30)];
        trackingNo.backgroundColor = [UIColor clearColor];
        trackingNo.text = [currentItem.fields objectForKey:@"trackingNo"];
        trackingNo.font = [UIFont boldSystemFontOfSize:18];
        [cell.contentView addSubview:trackingNo];
        [trackingNo release];
        
        UILabel *forwarder = [[UILabel alloc] initWithFrame:CGRectMake(140, 80, frame.size.width-160, 30)];
        forwarder.backgroundColor = [UIColor clearColor];
        forwarder.text = [currentItem.fields objectForKey:@"forwarder"];
        forwarder.font = [UIFont boldSystemFontOfSize:18];
        [cell.contentView addSubview:forwarder];
        [forwarder release];
        
    }else{
        
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 5, 115, frame.size.height)];
        textView.editable = NO;
        textView.scrollEnabled = NO;
        textView.backgroundColor = [UIColor clearColor];
        textView.text = fieldLabel;
        textView.textAlignment = UITextAlignmentRight;
        textView.font = [UIFont boldSystemFontOfSize:13];
        [cell.contentView addSubview:textView];
        [textView release];
        
        if([fieldName rangeOfString:@"pictureContent"].location != NSNotFound){
            
            Item *att=[currentItem.attachments objectForKey:@"pictureContent1"];
            NSString *b64img=att==nil?@"":[att.fields objectForKey:@"body"];
            
            UIImage *image = [UIImage imageWithData:[Base64 decode:b64img]];

            UIButton *pictureContent = [UIButton buttonWithType:UIButtonTypeCustom];
            pictureContent.imageView.contentMode = UIViewContentModeScaleAspectFill;
            [pictureContent setImage:image forState:UIControlStateNormal];
            pictureContent.frame = CGRectMake(123, 4, 40, 40);
            [pictureContent addTarget:self action:@selector(previewImage:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:pictureContent];
            
            float x = image ? 168 : 123;
            
            Item *att1=[currentItem.attachments objectForKey:@"pictureContent2"];
            NSString *b64img1=att1==nil?@"":[att1.fields objectForKey:@"body"];
            
            image = [UIImage imageWithData:[Base64 decode:b64img1]];
            pictureContent = [UIButton buttonWithType:UIButtonTypeCustom];
            pictureContent.imageView.contentMode = UIViewContentModeScaleAspectFill;
            [pictureContent setImage:image forState:UIControlStateNormal];
            pictureContent.frame = CGRectMake(x, 4, 40, 40);
            [pictureContent addTarget:self action:@selector(previewImage:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:pictureContent];
            
        }else if([fieldName isEqualToString:@"sendProofOfDelivery"]){
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else if([fieldName isEqualToString:@"forwarderLink"]){
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            NSString *forwarder = [currentItem.fields objectForKey:@"forwarder"];
            NSString *urlLink = [ProviderManager getPoviderURL:forwarder];
            urlLink = urlLink != nil ? urlLink : @"";
            
            if(![urlLink isEqualToString:@""]){
                urlLink = [NSString stringWithFormat:urlLink,[currentItem.fields objectForKey:@"trackingNo"]];
            }
            
            float minus = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 210 : 140;
            
            UITextView *linker = [[UITextView alloc] initWithFrame:CGRectMake(113, 5, frame.size.width-minus, frame.size.height-12)];
            linker.dataDetectorTypes = UIDataDetectorTypeLink;
            linker.backgroundColor = [UIColor clearColor];
            linker.scrollEnabled = NO;
            linker.editable = NO;
            linker.text = urlLink;
            linker.font = [UIFont systemFontOfSize:13];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showForwarderPage)];
            tap.numberOfTapsRequired = 1;
            tap.numberOfTouchesRequired = 1;
            [linker addGestureRecognizer:tap];
            [tap release];
            
            [cell.contentView addSubview:linker];
            [linker release];
            
        }else{
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(114, 5, frame.size.width-150, frame.size.height-10)];
            textView.editable = NO;
            textView.scrollEnabled = NO;
            textView.backgroundColor = [UIColor clearColor];
            textView.text = value;
            textView.font = [UIFont systemFontOfSize:13];
            [cell.contentView addSubview:textView];
            [textView release];
            
        }
        
    }
    
    return cell;
}

-(void)showForwarderPage{
    
    NSString *forwarder = [currentItem.fields objectForKey:@"forwarder"];
    if(forwarder != nil && ![forwarder isEqualToString:@""] && ![forwarder isEqualToString:@"No Forwarder Found"]){
        NSString *urlForProvider = [ProviderManager getPoviderURL:forwarder];
        NSString *openURL = [NSString stringWithFormat:urlForProvider,[currentItem.fields objectForKey:@"trackingNo"]];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:openURL]];
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't Open Page" message:@"No Provider Found For this TrackingNo" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
    }
    
}

-(void)previewImage:(UIButton*)button{
    
    if ([button imageForState:UIControlStateNormal] == nil) return;
    if ([button imageForState:UIControlStateNormal] == [UIImage imageNamed:@"camera-library@2x.png"]) return;
    UIImage *image = [button imageForState:UIControlStateNormal];
    
    NSString *path = NSTemporaryDirectory();
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:path error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.png'"];
    NSArray *onlyPngs = [dirContents filteredArrayUsingPredicate:fltr];
    
    if(onlyPngs.count > 0){
        for(NSString *fileName in onlyPngs){
            
            if([fileName hasPrefix:@"preview"] && [fileName hasSuffix:@".png"]){
                
                NSString *oldPath = [path stringByAppendingPathComponent:fileName];
                [fm removeItemAtPath:oldPath error:nil];
                
                fileName = [fileName substringFromIndex:[fileName rangeOfString:@"preview"].location+7];
                fileName = [fileName substringToIndex:[fileName rangeOfString:@".png"].location];
                int i = [fileName intValue];
                i += 1;
                self.imageFilePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"preview%d.png",i]];
            }
            
        }
    }else{
        self.imageFilePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"preview0.png"]];
    }
    
    [UIImagePNGRepresentation(image) writeToFile:self.imageFilePath atomically:YES];
    
    QLPreviewController *preview = [[QLPreviewController alloc] init];
    preview.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    preview.dataSource = self;
    [self presentModalViewController:preview animated:YES];
    [preview release];
    
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}

-(void)didUpdate:(NSString *)fName value:(NSString *)value{
    
}
-(void)mustUpdate:(Item *)item{
    currentItem = item;
    [self.tableView reloadData];
    //[updateListener mustUpdate:item];
}

#pragma mark - UIActionSheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        //email
        [self performSelector:@selector(sendProofOfDelivery:)];
        
    }else if (buttonIndex == 1) {
        //print
        PDFCreator *pdf = [[PDFCreator alloc] initWithItem:self.currentItem parentController:self];
        [pdf generatePDF];
        //[pdf release];
    }
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *section = [sections objectAtIndex:indexPath.section];
    NSDictionary *fieldItem = [section objectAtIndex:indexPath.row];
    NSString *fieldName = [fieldItem objectForKey:@"fieldName"];
    
    if([fieldName isEqualToString:@"forwarderLink"]){
        [self showForwarderPage];
    }
    
    if([fieldName isEqualToString:@"sendProofOfDelivery"]){
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
        
        actionSheet.delegate = self;
        
        actionSheet.title = SEND_DELIVERY_PROOF;
        [actionSheet addButtonWithTitle:EMAIL];
        [actionSheet addButtonWithTitle:PRINT];
        // [actionSheet addButtonWithTitle:NSLocalizedString(@"SEND_LINK_TO", @"Send Link To")];
        // [actionSheet addButtonWithTitle:NSLocalizedString(@"EXPORT_CLOUD", @"Export Cloud")];
        [actionSheet addButtonWithTitle:MSG_CANCEL];
        
        actionSheet.cancelButtonIndex = 2;
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            [actionSheet addButtonWithTitle:MSG_CANCEL];
        }
        
        [actionSheet showFromTabBar:[MainViewController getInstance].tabBar];
        [actionSheet release];
        
    }
    
}


-(void) sendProofOfDelivery : (id) sender
{
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil){
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
            [self displayComposerSheet];
        }
        else
        {
            [self launchMailAppOnDevice];
        }
    }else{
        [self launchMailAppOnDevice];
    }
    
}


#pragma mark - MFMailComposeViewControllerDelegate delegate

- (void) displayComposerSheet{
    
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    mailer.mailComposeDelegate = self;
    [mailer setSubject:[NSString stringWithFormat:@"PACTRAC2ME app - %@ --PROOF OF DELIVERY--",[self.currentItem.fields valueForKey:@"forwarder"]]];
    
    NSMutableString *emailBody = [NSMutableString stringWithString:@"<html><body>"];
    [emailBody appendString:[NSString stringWithFormat:@"Shipment: <b> %@ - </b>",[self.currentItem.fields valueForKey:@"forwarder"]]];
    
    NSString *urlForProvider = [ProviderManager getPoviderURL:[self.currentItem.fields objectForKey:@"forwarder"]];
    NSString *openURL = @"";
    if(urlForProvider){
        openURL = [NSString stringWithFormat:urlForProvider,[currentItem.fields objectForKey:@"trackingNo"]];
    }
        
    [emailBody appendString:[NSString stringWithFormat:@"<a href='%@'> %@ </a>",openURL ,[self.currentItem.fields valueForKey:@"trackingNo"]]];
    [emailBody appendString:@"<p>Delivery status from forwarder.</p>"];
    [emailBody appendFormat:@"<b style='padding:5px;border:1px solid black;background-color:#dadada;font-size:14px;'>%@</b>",[self.currentItem.fields objectForKey:@"status"]];
    
    [emailBody appendString:[NSString stringWithFormat:@"<p>Receiver : <b> %@</b></p>",[self.currentItem.fields valueForKey:@"receiver"]]];
    [emailBody appendString:[NSString stringWithFormat:@"<p>Shipping date : <b> %@</b></p>",[self.currentItem.fields valueForKey:@"shippingDate"]]];
    
    Item *att=[currentItem.attachments objectForKey:@"invoiceImage"];
    NSString *b64img=att==nil?@"":[att.fields objectForKey:@"body"];
    UIImage *image = [UIImage imageWithData:[Base64 decode:b64img]];
    
    if(image){
        [mailer addAttachmentData:[PhotoUtile resizeImage:image] mimeType:@"image/png" fileName:@"Invoice_Image"];
    }
    
    att=[currentItem.attachments objectForKey:@"pictureContent1"];
    b64img=att==nil?@"":[att.fields objectForKey:@"body"];
    image = [UIImage imageWithData:[Base64 decode:b64img]];
    if(image){
        [mailer addAttachmentData:[PhotoUtile resizeImage:image] mimeType:@"image/png" fileName:@"PictureContent1_Image"];
    }
    
    if ([currentItem.attachments objectForKey:@"pictureContent2"]  != nil) {
        
        att=[currentItem.attachments objectForKey:@"pictureContent2"];
        b64img=att==nil?@"":[att.fields objectForKey:@"body"];
        image = [UIImage imageWithData:[Base64 decode:b64img]];
        
        if(image){
            [mailer addAttachmentData:[PhotoUtile resizeImage:image] mimeType:@"image/png" fileName:@"PictureConten2_Image"];
        }
    }
    
//    NSMutableString* stringHref = [[NSMutableString alloc] init];
//    
//    for (NSString* field in [self.currentItem.fields allKeys]) {
//        [stringHref appendString:field];
//        [stringHref appendString:@"/"];
//        [stringHref appendString:[self.currentItem.fields valueForKey:field]];
//    }
//    
//    for (NSString* field in [self.currentItem.attachments allKeys]) {
//        [stringHref appendString:@"/"];
//        [stringHref appendString:field];
//        [stringHref appendString:@"/"];
//        [stringHref appendString:[self.currentItem.attachments valueForKey:field]];
//    }
    
    NSMutableDictionary *fields = [NSMutableDictionary dictionaryWithDictionary:self.currentItem.fields];
    [fields removeObjectForKey:@"id"];
    [fields removeObjectForKey:@"local_id"];
    
    NSMutableDictionary *attachments = [NSMutableDictionary dictionary];
    for(NSString *key in self.currentItem.attachments.allKeys){
        
        Item *item = [self.currentItem.attachments objectForKey:key];
        NSMutableDictionary *attFields = [NSMutableDictionary dictionaryWithDictionary:item.fields];
        [attFields removeObjectForKey:@"Id"];
        [attFields removeObjectForKey:@"local_id"];
        [attFields removeObjectForKey:@"ParentId"];
        
        [attachments setObject:attFields forKey:key];
        
    }
    
    for(NSDictionary *fieldItem in [ParcelItem allDataInfo]){
        
        NSString *fieldLabel = [fieldItem objectForKey:@"fieldLabel"];
        NSString *fieldName = [fieldItem objectForKey:@"fieldName"];
        NSString *value = [fields objectForKey:fieldName];
        
        [emailBody appendFormat:@"<p>%@ : <b> %@</b></p>",fieldLabel,value];
        
    }
    
    [fields setObject:attachments forKey:@"attachments"];
    
    [emailBody appendString:[NSString stringWithFormat:@"<a href='parcel://addParcel/%@'> Add this shipment to PACTRAC2ME </a>",fields.JSONRepresentation]];
    [emailBody appendString:@"<br><p>This report is</p>"];
    [emailBody appendString:@"<p>created by <a href='parcel://myParcels'>PACTRAC2ME</a> for iOS</p>"];
    
    [emailBody appendString:@"</body></html>"];
    

    [mailer setMessageBody:emailBody isHTML:YES];
    [self presentViewController:mailer animated:YES completion:^void(){}];

}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            
            break;
        case MFMailComposeResultSaved:
            
            break;
        case MFMailComposeResultSent:
            
            break;
        case MFMailComposeResultFailed:
            
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:^void(){}];
    
}


-(void)launchMailAppOnDevice
{
    
    NSString *mailBody = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@",@"",@"",@""];
    mailBody = [mailBody stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailBody]];
    
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    BasicPreviewItem *previewItem = [[BasicPreviewItem alloc] init];
    previewItem.previewItemTitle = @"Preview Image";
    previewItem.previewItemURL = [NSURL fileURLWithPath:self.imageFilePath];
    
    return previewItem;
}

@end
