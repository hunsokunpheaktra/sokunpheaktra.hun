//
//  ContactExportView.h
//  CRMiOS
//
//  Created by Sy Pauv on 9/16/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterManager.h"
#import "LikeCriteria.h"
#import "EntityManager.h"
#import "MergeContacts.h"

@interface ContactExportView : UIViewController<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate> {
    
    UIPopoverController *popoverController;
    UITableView *mytable;
    NSArray *listData;
    NSString *nameFilter;
    NSMutableDictionary *selectedContact;
    
}
@property (nonatomic, retain) NSMutableDictionary *selectedContact;
@property (nonatomic, retain) NSString *nameFilter;
@property (nonatomic, retain)  NSArray *listData;
@property (nonatomic, retain)  UIPopoverController *popoverController;
@property (nonatomic, retain)  UITableView *mytable;

- (void)filterData;
- (void)showpopup:(UIButton *)button parent:(UIView *)parent;
- (void)doExportAll:(id)sender;

@end
