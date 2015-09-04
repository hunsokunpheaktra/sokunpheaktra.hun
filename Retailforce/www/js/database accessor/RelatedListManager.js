
var mapRelatedListData = new Map();
var mapRelatedListColumnInfo = new Map();
var maprelatedListInfo = new Map();
var mapChildRelationShipInfo = new Map();

function RelatedListManager(){
    
}

RelatedListManager.initRelatedListColumnInfo = function(entity){
    
    if (mapRelatedListColumnInfo.get(entity) == null) {
        SyncCallPlugin.nativeFunction( [entity,"mapRelatedColumnInfo"] ,null,null,
                                  "getRelatedListColumnInfo"
        );
    }
    
};

function mapRelatedColumnInfo(listData,listRlatedInfo,entityName) {
    
    mapRelatedListColumnInfo.put(entityName,listData);
    maprelatedListInfo.put(entityName,listRlatedInfo);
    
    for (var x=0;x<listData.length;x++) {
        
        var findObjectRelated = (listData[x]['field']).split('.');
        
        if (findObjectRelated[0] != listData[x]['sobject'] && EntityManager.getData(findObjectRelated[0]) == null){
            
            EntityManager.addListData(findObjectRelated[0],[]);
            EntityManager.initData(findObjectRelated[0]);
            
        }
        
        var fieldInfo = FieldInfoManager.getInfo(listData[x]['sobject']);
        
        if(fieldInfo == null){            
            FieldInfoManager.initInfo(listData[x]['sobject']);
            
        }
        
    }
    
}

RelatedListManager.initRelationShipInfo = function(parentEntity,childName){
    
    if(mapChildRelationShipInfo.get(parentEntity + childName) == null){
        SyncCallPlugin.nativeFunction( [parentEntity,childName,"getChildRelationShipInfo"] ,null,null,
                                      "getChildRelationShipInfo"
                                      );
    }
    
};

function getChildRelationShipInfo(parentEntity,childName,relatationInfo){
    
    var key = parentEntity + childName;    
    mapChildRelationShipInfo.put(key,relatationInfo);
    
}

RelatedListManager.getRelationShipInfo = function(parentEntity,childName){
    return mapChildRelationShipInfo.get(parentEntity + childName);
};

RelatedListManager.initRelatedListData = function(parentId,parentEntity,childEntity){
  
    if(RelatedListManager.getRelatedListData(parentEntity+childEntity+parentId) == null){
        SyncCallPlugin.nativeFunction([parentId,parentEntity,childEntity,"mapRelatedListWithParendId"],null,null,
                                    "getRelatedListData"
        );
    }   

};

function mapRelatedListWithParendId(listData,childName,parentName,parentId) {
    var key = parentName+childName+parentId;
    mapRelatedListData.put(key,listData);
    displayRelatedList(parentName);

}

RelatedListManager.putRelatedListData = function(key,listData){
    mapRelatedListData.put(key,listData);
}

RelatedListManager.getRelatedListData = function(key){
    return mapRelatedListData.get(key);
};

RelatedListManager.getRelatedListColumnInfo = function(entityName){
    
    var listCol = mapRelatedListColumnInfo.get(entityName);
    var mapCol = new Map ();
    for (var x = 0; x < listCol.length ;x++) {
        
        if (mapCol.keySet().length == 0|| mapCol.keySet().indexOf(listCol[x]['sobject']) == -1) {
            mapCol.put(listCol[x]['sobject'],[listCol[x]]);
        }else mapCol.get(listCol[x]['sobject']).push(listCol[x]); 

    }
    return mapCol;

};

RelatedListManager.getLabelOfRelatedObjectName = function(entityName,childName){
    
    var tmList = maprelatedListInfo.get(entityName)
    
    for (var x = 0; x < tmList.length; x++) {
        if (tmList[x]['sobject'] == childName) {
            return tmList[x]['label'];
        }   
    }
};


