//
//  SearchDataViewController.h
//  Pactrac2me
//
//  Created by Hun Sokunpheaktra on 3/6/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import "UpdateListener.h"
#import "ZBArSDK.h"

@interface SearchDataViewController : UITableViewController<UISearchBarDelegate,UISearchDisplayDelegate,UINavigationBarDelegate,UIImagePickerControllerDelegate,ZBarReaderDelegate>{
    
    NSMutableArray *listContent;
    UISearchDisplayController *searchDisplayController;
    
}

@property(nonatomic,retain)NSMutableArray *listContent;
@property(nonatomic,retain)UITextField *textField;
@property(nonatomic,retain)NSObject<UpdateListener> *updateListener;
@property(nonatomic,retain)Item *item;

-(id)initWithListener:(NSObject<UpdateListener>*)update item:(Item*)item;

@end
