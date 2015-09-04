//
//  ImageView.h
//  Datagrid
//
//  Created by Gaeasys Admin on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieViewController.h"

@interface ImageView : UIImageView {
    IBOutlet MovieViewController *viewController;
}

@property (nonatomic,retain) IBOutlet MovieViewController *viewController;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

@end
