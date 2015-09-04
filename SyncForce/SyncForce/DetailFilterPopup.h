//
//  DetailFilterPopup.h
//  SyncForce
//
//  Created by Gaeasys on 12/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Preference;

@interface DetailFilterPopup : UITableViewController{
    
    UIPopoverController *popoverController;
    NSArray *dateFilters;
    UIButton *button;
    NSString *valueSelected;
    NSIndexPath *selectPath;
    NSInteger row;
    
    Preference* parentScreen;
}

@property (nonatomic, readwrite) NSInteger row;
@property (nonatomic, retain) NSArray *dateFilters;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) UIButton *button;
@property (nonatomic, retain) NSString *valueSelected;
@property (nonatomic, retain) NSIndexPath *selectPath;
@property (nonatomic, retain) Preference* parentScreen;

- (id)initWithData:(NSArray *)datas;
- (void) show:(UIButton *)button parentView:(UIView *)parentView;
-(void)showPopup:(UIView*)content parentView:(UIView *)parentView selectedValue:(NSString*)selectedValue parent:(Preference*)parent;
//-(void)showDetail:(UIView*)content parentView:(UIView *)parentView selectedValue:(NSString*)selectedValue parent:(Preference*)parent;

@end
