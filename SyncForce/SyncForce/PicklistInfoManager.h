//
//  PicklistInfoManager.h
//  SyncForce
//
//  Created by Gaeasys Admin on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"
#define PICKLISTINFO_ENTITY @"PicklistInfo"


@interface PicklistInfoManager : NSObject
{
    
}

+ (void)initTable;
+ (void)insert:(Item *)item;
+ (Item *)find:(NSDictionary *)criterias;
+ (NSArray *)list:(NSDictionary *)criterias;



//    //Maping dependent picklist with KEY = ENTITY
//    public class ConfigCascadingPicklist {
//        
//        public static Map<String,List<CascadingPicklist>> mCascadingPicklistItem;
//        public static Map<String,List<CascadingPicklist>> getMCascadingPicklistItem( SQLiteDatabase database, Context context ){
//            if(mCascadingPicklistItem == null|| mCascadingPicklistItem.isEmpty()){
//                mCascadingPicklistItem = new HashMap<String,List<CascadingPicklist>>(0);
//                FieldsManager fieldsManager = new FieldsManager(database, context);
//                Map<String, Criteria> criteria = new HashMap<String, Criteria>();
//                criteria.put("dependentPicklist", new EqualsCriteria("1"));
//                criteria.put("DataType", new EqualsCriteria("picklist"));
//                
//                //controller and children
//                Map<String,List<String>> mdependentfield = new HashMap<String,List<String>>();
//                
//                for(Map<String,String> item : fieldsManager.getList(criteria)){
//                    String entity =  item.get("ObjectName");
//                    String controller = item.get("controllerName");
//                    
//                    String child = item.get("ElementName");
//                    
//                    // map Entities
//                    if(!mCascadingPicklistItem.containsKey(entity)){
//                        mCascadingPicklistItem.put(entity,new ArrayList<CascadingPicklist>());
//                    }
//                    
//                    
//                    mCascadingPicklistItem.get(entity).add(new CascadingPicklist(controller));
//                    //map controllers
//                    String keyController = entity + controller;
//                    if(!mdependentfield.containsKey(keyController)){
//                        mdependentfield.put(keyController,new ArrayList<String>());
//                    }
//                    //				if(entity == "Assortment_Compliance__c"){
//                    //					System.out.print(controller + " Get Map :: >>>>>>>>>>>>>>>>>>>>  " + child);
//                    //				}
//                    mdependentfield.get(keyController).add(child);
//                }
//                
//                //set children to Cascading Picklist Item
//                for(String entity : mCascadingPicklistItem.keySet()){
//                    
//                    
//                    for(CascadingPicklist cascadingItem : mCascadingPicklistItem.get(entity)){
//                        String keyController = entity + cascadingItem.getController();
//                        cascadingItem.setChildren(mdependentfield.get(keyController));
//                        cascadingItem.checkValidFor(database, context, entity);
//                    }
//                }
//            }
//            
//            return mCascadingPicklistItem;
//        }
//    }


@end
