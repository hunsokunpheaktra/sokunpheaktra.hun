
var mapEntityInfo = new Map();

function EntityInfoManager(){
    
}

EntityInfoManager.initInfo = function(entity){
    
    if(mapEntityInfo.get(entity) == null){
        SyncCallPlugin.nativeFunction([entity,"getEntityInfo"],null,null,"getEntityInfo"); 
    }
};

function getEntityInfo(entity,result){
    mapEntityInfo.put(entity,result);
}

EntityInfoManager.getEntityInfo = function(entity){
    return mapEntityInfo.get(entity);
};

EntityInfoManager.findEntityInfo = function(keyPrefix){

    for (var x = 0; x< mapEntityInfo.size();x++) {
        var keyMap = mapEntityInfo.keySet()[x];
        var infoItem = mapEntityInfo.get(keyMap);
        
        if (infoItem['keyPrefix'] == keyPrefix)
            return infoItem;
        
    }
    
    return -1;
    
};

















