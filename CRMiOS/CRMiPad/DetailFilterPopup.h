//
//  DetailFilterPopup.h
//  CRMiOS
//
//  Created by Sy Pauv on 5/25/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Configuration.h"
#import "PropertyManager.h"
#import "PadPreferences.h"
#import "PadSyncFiltersView.h"

@class PadSyncFiltersView;

@interface DetailFilterPopup : UITableViewController {
    
    NSString *entity;
    UIPopoverController *popoverController;
    NSArray *ownerFilters;
    NSArray *dateFilters;
    NSString *isOwner;
    UIButton *button;
    PadSyncFiltersView *parent;

}

@property (nonatomic, retain) NSString *isOwner;
@property (nonatomic, retain) NSArray *ownerFilters;
@property (nonatomic, retain) NSArray *dateFilters;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) NSString *entity;
@property (nonatomic, retain) UIButton *button;
@property (nonatomic, retain) PadSyncFiltersView *parent;

- (id)initWithEntity:(NSString *)newentity filterType:(NSString *)strisOwner parent:(PadSyncFiltersView *)parent;
- (void) show:(UIButton *)button parentView:(UIView *)parentView;

@end
