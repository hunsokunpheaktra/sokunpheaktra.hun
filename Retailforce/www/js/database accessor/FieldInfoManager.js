
var mapInfo = new Map();
var mapEntityPicklist = new Map();
var mapPickListData = new Map();

var imported = document.createElement('script');
imported.src = './js/data accessor/LayoutManager.js';
document.getElementsByTagName('head')[0].appendChild(imported);

var imported = document.createElement('script');
imported.src = './js/gui/uitool.js';
document.getElementsByTagName('head')[0].appendChild(imported);

function FieldInfoManager(){
    
}

FieldInfoManager.initInfo = function(entity){
    
   if (mapInfo.get(entity) == null) {
       
        FieldInfoManager.addNewInfo(entity,[]);
        CascadingPickist.initCascadingPicklist(entity);
        SyncCallPlugin.nativeFunction([entity,"getFieldInfo"],null,null,"getFieldInfo");
       
    }     
};

function getFieldInfo(listField){

    var entityName = listField[0]['entity'];
    mapInfo.put(entityName,listField);
    
    for( var x =0; x<listField.length; x++) {
       if (listField[x]['type'] == 'reference') {
           var tmRefName = listField[x]['referenceTo'].split(',');
           for(var t = 0;t < tmRefName.length;t++) {
               if(EntityManager.getData(tmRefName[t]) == null) {
                   
                    EntityManager.addListData(tmRefName[t],[]);
                    EntityInfoManager.initInfo(tmRefName[t]);
                    callPickListAndReference(entityName,listField[x]['name'],listField[x]['type'],tmRefName[t],'');
                    
                }
           }
        } 
    
    }
   
    EntityInfoManager.initInfo(entityName);
    
};

function callPickListAndReference(entityName,fieldName,type,reference,recordTypeId) {

    if (type == "reference"){
        SyncCallPlugin.nativeFunction([entityName,reference,"getPickListAndReference"],null,null,"getReference");
    }
}

function getPickListAndReference(listData,entityName,reference,type){
    
    if (type == "picklist" || type == "combobox") {
        var fieldName = listData[0]['picklistName'];
        var recordTypeId = listData[0]['recordTypeId'];
        mapPickListData.put (entityName+fieldName+recordTypeId,listData);
        
        var isReady = true;        
        var picklistNames = LayoutManager.getPicklistName (listData[0]['entity'],listData[0]['recordTypeId']);
        
        for (var x = 0; x< picklistNames.length; x++) {
            var fieldName = picklistNames[x]['value'];
            var fInfo = FieldInfoManager.getFieldInformation(entityName,fieldName,'name');
         
            if (fInfo != undefined && fInfo['type']!= undefined && fInfo['type'] == 'picklist') {
                if (mapPickListData.get(entityName+fieldName+recordTypeId) == -1) {
                    isReady = false;
                }    
            }    
        }
    
        if (isReady){
            var mainItem = LayoutManager.getMainItem();
            var index = LayoutManager.getIndex();
            
            UITool.setupView(entityName,recordTypeId,mainItem,localType,index); 
        }   
        
    }else {
        
        if(reference.length > 0) EntityManager.addListData(reference,listData);
    }
    
}

FieldInfoManager.retreivePicklist = function (entityName,fieldName,type,recordTypeId) {
    SyncCallPlugin.nativeFunction([entityName,fieldName,"getPickListAndReference",recordTypeId],null,null,"getPickList");
} 

FieldInfoManager.addNewInfo = function(entity,listInfo){
    mapInfo.put(entity,listInfo);
}

FieldInfoManager.getInfo = function(entity){
    return mapInfo.get(entity);
}

FieldInfoManager.getPickListValues = function(entityName,fieldName, recordTypeId){
    return mapPickListData.get(entityName + fieldName + recordTypeId);
};

FieldInfoManager.addPickListValues = function(key,listData){
    mapPickListData.put (key,listData);
}    

FieldInfoManager.getFieldLabel = function(entity,fieldName){
    var listFieldInfo = mapInfo.get(entity);
    for(var i=0;i<listFieldInfo.length;i++){
        var item = listFieldInfo[i];
        if(item['name'] == fieldName){
            return item['label'];
        }
    }
    return "";
};

FieldInfoManager.getReferenceListValues = function(refName){
    var names = refName.split(',');
    
    for (var n = 0; n < names.length; n++) {
        if (EntityManager.getData(names[n]).length > 0) {
            return EntityManager.getData(names[n]);
        }
    }
    
    return -1;
};

FieldInfoManager.getFieldInformation = function(parentName,childName,fieldName){
    var infos = FieldInfoManager.getInfo(parentName);
    
    for (var x=0; x< infos.length; x++) {
        if (infos[x][fieldName] == childName) {
            return infos[x];
        }
    }

};

FieldInfoManager.getReferenceName = function(refName,refId){
    var names = refName.split(',');
    var tmpMap = new Map();
    
    for (var x=0;x<names.length;x++){
        var listData = EntityManager.getData(names[x]);
       
        if (listData != null && listData.length > 0) {
            for(var y = 0;y <listData.length;y++) {
                if(listData[y]['Id'] == refId) {
                    tmpMap.put('item',listData[y]);
                    tmpMap.put('info',[names[x],y]);
                    
                    return tmpMap;
                }
            }
        }    
    }   
    
    return -1;
};

FieldInfoManager.getListDependPicklist = function(entityName,controllerName){
    
    var listTm = mapInfo.get(entityName);
    var lisDepend = [];
    
    for (var x=0; x < listTm.length; x++) {
        if (listTm[x]['controllerName'] == controllerName) {
            lisDepend.push(listTm[x]['name']);
        }
    }
    
    return lisDepend;

};

















