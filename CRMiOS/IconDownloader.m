//
//  IconDownloader.m
//  CRMiOS
//
//  Created by Sy Pauv on 5/21/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import "IconDownloader.h"

#define kAppIconSize 50

@implementation IconDownloader

@synthesize indexPathInTableView;
@synthesize delegate;
@synthesize activeDownload;
@synthesize imageConnection,item;

#pragma mark

- (void)dealloc
{
    [indexPathInTableView release];
    [activeDownload release];
    [imageConnection cancel];
    [imageConnection release];
    [super dealloc];
}

- (void)startDownload
{
    self.activeDownload = [NSMutableData data];
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSLog(@"urn : %@",[self.item objectForKey:@"url"]);
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:
                              [NSURL URLWithString:[[[item objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"]]] delegate:self];
    self.imageConnection = conn;
    [conn release];
}

- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}

#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    // Release the connection now that it's finished
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Set appIcon and clear temporary data/image
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
    
    if (image.size.width != kAppIconSize || image.size.height != kAppIconSize)
	{
        CGSize itemSize = CGSizeMake(kAppIconSize, kAppIconSize);
		UIGraphicsBeginImageContext(itemSize);
		CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
		[image drawInRect:imageRect];
		[self.item setObject:UIGraphicsGetImageFromCurrentImageContext() forKey:@"image"];
		UIGraphicsEndImageContext();
    }
    else
    {
        [self.item setObject:image forKey:@"image"];
    }
    self.activeDownload = nil;
    [image release];
    // Release the connection now that it's finished
    self.imageConnection = nil;
    // call our delegate and tell it that our icon is ready for display
    [delegate appImageDidLoad:self.indexPathInTableView];
}

@end
