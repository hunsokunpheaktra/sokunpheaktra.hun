//
//  CascadingPicklist.m
//  SyncForce
//
//  Created by Gaeasys Admin on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CascadingPicklist.h"
#import "PicklistInfoManager.h"
#import "ValuesCriteria.h"
#import "Bitset.h"
#import "NSData (MBBase64).h"

@implementation CascadingPicklist
@synthesize controller,children,validValue;

- (id)init:(NSString *)pcontroler{
    self.controller = pcontroler;
    return self;
}

- (void)checkValidFor:(NSString *)entity{
//    NSMutableDictionary *criteriacontroller = [[NSMutableDictionary alloc] initWithCapacity:1];
//    [criteriacontroller setValue:[ValuesCriteria criteriaWithString:entity] forKey:@"entity"];
//    [criteriacontroller setValue:[[ValuesCriteria alloc] initWithString:self.controller] forKey:@"fieldname"];
//    NSArray *controlerPicklistvalues = [PicklistInfoManager list:criteriacontroller]; 
//    for(NSString *child in self.children){
//        NSMutableDictionary *criteriachild = [[NSMutableDictionary alloc] initWithCapacity:1];
//        [criteriachild setValue:[ValuesCriteria criteriaWithString:entity] forKey:@"entity"];
//        [criteriachild setValue:[[ValuesCriteria alloc] initWithString:child] forKey:@"fieldname"];
//        for(Item *childdata in [PicklistInfoManager list:criteriachild]){
//            NSString *fieldname = [childdata.fields valueForKey:@"fieldname"];
//            NSString *value = [childdata.fields valueForKey:@"value"];
//            NSString *label = [childdata.fields valueForKey:@"fieldlabel"];
//            NSString *validFor = [childdata.fields valueForKey:@"validFor"];
//        }
//    }
}

@end


//    public class CascadingPicklist {
//	
//	public void checkValidFor(SQLiteDatabase database, Context context , String entity){
//		PicklistManager picklistManager = new PicklistManager(database, context);
//		Map<String, Criteria> criteriacontroller = new HashMap<String, Criteria>();
//		criteriacontroller.put("Name", new EqualsCriteria(controller));
//		//criteriacontroller.put("RecordTypeId", new EqualsCriteria(recordTypeId));
//		criteriacontroller.put("ObjectName", new EqualsCriteria(entity));
//		List<Map<String, String>> controlerPicklistvalues = picklistManager.getList(criteriacontroller);
//		
//		for(String child : children){
//			Map<String, Criteria> criteriachild = new HashMap<String, Criteria>();
//			criteriachild = new HashMap<String, Criteria>();
//			criteriachild.put("Name", new EqualsCriteria(child));
//			criteriachild.put("ObjectName", new EqualsCriteria(entity));
//			
//			for(Map<String, String> childdata : picklistManager.getList(criteriachild)){
//				String fieldname = childdata.get("Name");
//				String valueId = childdata.get("ValueId");
//				String value = childdata.get("Value");
//				Bitset validFor = new Bitset(Base64.decode(childdata.get("validFor"),0));
//				for(int k = 0 ; k < validFor.size(); k++ ){
//					if(validFor.testBit(k)){
//						String controllerValueId = controlerPicklistvalues.get(k).get("ValueId");
//						if(!validValues.containsKey(controllerValueId)){
//							validValues.put(controllerValueId, new HashMap<String,List<PicklistItem>>() );
//						}
//						Map<String,List<PicklistItem>> mtmp = validValues.get(controllerValueId);
//						if(!mtmp.containsKey(fieldname)){
//							mtmp.put(fieldname, new ArrayList<PicklistItem>());
//						}
//						mtmp.get(fieldname).add(new PicklistItem(valueId,value));
//					}
//				}
//			}
//		}
//	}
//	