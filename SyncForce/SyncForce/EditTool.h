//
//  EditTool.h
//  SyncForce
//
//  Created by Gaeasys on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "EntityInfo.h"


@interface EditTool : NSObject {
						
	UIControl	* control;
    int         index;
}

@property(nonatomic, retain) UIControl *control;
@property int index;

- (id)setupAddEditCell:(UITableViewCell *)cell entityInfo:(NSObject<EntityInfo> *)fieldsInfo valueItem:(Item *)item listFieldInfo:(NSArray*)listFieldInfo fieldName:(NSString*)fieldName rect:(CGRect)rect tag:(int)tag delegate:(id)delegate parentField:(NSString*)parentField parentId:(NSString*)parentId;

@end
