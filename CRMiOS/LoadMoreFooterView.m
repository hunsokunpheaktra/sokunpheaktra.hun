//
//  LoadMoreFooterView.m
//  CRMFeed
//
//  Created by Sy Pauv Phou on 2/21/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "LoadMoreFooterView.h"

@implementation LoadMoreFooterView
@synthesize delegate=_delegate;

- (id)initWithFrame:(CGRect)frame{

    if((self = [super initWithFrame:frame])) {
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
        self.backgroundColor=[UIColor clearColor];
        
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 1.0f, frame.size.width , 2)];
        separatorView.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];
        separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:separatorView];
        [separatorView release];
        
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        view.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
		view.frame = CGRectMake(25.0f, frame.size.height - 38.0f, 25.0f, 25.0f);
        view.center=CGPointMake((frame.size.width/2)-85, frame.size.height/2);
		[self addSubview:view];
		_activityView = view;
        [_activityView startAnimating];
		[view release];
		
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(_activityView.frame.origin.x + 30.0f, frame.size.height - 30.0f, 200.0f, 25.0f)];
        label.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        label.text=NSLocalizedString(@"LOAD_MORE", nil);
        label.center=CGPointMake((frame.size.width/2)+30, frame.size.height/2);
        label.backgroundColor=[UIColor clearColor];
        label.font=[UIFont boldSystemFontOfSize:12];
        [self addSubview:label];
        [label release];
        
    }
    return self;

}

- (void)showLoadingFooter:(UIScrollView *)scrollView{

    //when tableview scroll down to the bottom of the table reload more
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    float reload_distance = 44.0f;
    if(y > h + reload_distance && !_isLoadingShow) {
        _isLoadingShow=YES;
        if ([_delegate respondsToSelector:@selector(startLoadMoreFeed:)]) {
			[_delegate startLoadMoreFeed:self];
		}
        [self setHidden:NO];
    }
    
}
- (void)hideLoadingFooter:(UIScrollView *)scrollView{
    _isLoadingShow=NO;    
}

-(void)dealloc{

    [_activityView release];
    [super dealloc];

}
@end
