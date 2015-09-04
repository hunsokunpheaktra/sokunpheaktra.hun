
var mapCascadingPicklist = new Map();

function CascadingPickist(){
    
}

CascadingPickist.initCascadingPicklist = function(entity){

    SyncCallPlugin.nativeFunction([entity,"cascadingPicklistReturn"],null,null,"mapCascadingPicklist");
         
};

function cascadingPicklistReturn (listConVal,listResult,key) {
      
    for (var x = 0; x < listConVal.length; x++) {
        if (mapCascadingPicklist.get(key) == null) {
            var mapPicklistVal = new Map();
            mapCascadingPicklist.put(key,mapPicklistVal);
        }

        mapCascadingPicklist.get(key).put(listConVal[x],listResult[listConVal[x]]);
    
    }
        
}

CascadingPickist.getMapCascad = function (key) { // key = entityName+fieldName+controllerName
    return mapCascadingPicklist.get(key);
    
}















