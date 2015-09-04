//
//  DownloadFileRequest.h
//  Parcel
//
//  Created by Hun Sokunpheaktra on 12/19/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "SalesforceAPIRequest.h"

@interface DownloadFileRequest : SalesforceAPIRequest{
    
}

-(id)initWithImageURL:(NSString*)imgUrl parent:(NSString*)parentID;

@property(nonatomic,retain)NSString *imageURL;
@property(nonatomic,retain)NSString *parentId;

@end
