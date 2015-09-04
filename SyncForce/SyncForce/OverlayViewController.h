//
//  OverlayViewController.h
//  Datagrid
//
//  Created by Gaeasys Admin on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface OverlayViewController : UIViewController {
@private
	IBOutlet UILabel *moviePlaybackStateText;
	IBOutlet UILabel *movieLoadStateText;
}

@property (nonatomic, retain) IBOutlet UILabel *moviePlaybackStateText;
@property (nonatomic, retain) IBOutlet UILabel *movieLoadStateText;

- (void)setPlaybackStateDisplayString:(NSString *)playBackText;
- (void)setLoadStateDisplayString:(NSString *)loadStateText;

@end
