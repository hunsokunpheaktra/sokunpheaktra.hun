//
//  AddViewController.h
//  CRM
//
//  Created by MACBOOK on 4/8/11.
//  Copyright 2011 GAEASYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddViewController : UIViewController {
	IBOutlet UINavigationItem *navigate;
}
@property(nonatomic,retain) IBOutlet UINavigationItem *navigate;

-(IBAction)done:(id)sender;

@end
