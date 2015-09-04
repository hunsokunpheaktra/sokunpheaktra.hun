
var mapDetailLayout = new Map();
var mapEditLayout = new Map();
var mapEditLayoutInfo = new Map();
var mapTempEditLayout = new Map();

var mainItem,localListData,localIndex,localType;

document.write("<script type='text/javascript' src='./js/gui/uitool.js'></script>");

function LayoutManager(){
    
}

LayoutManager.initLayout = function(entity,recordTypeId,type,recordIndex,item){
    
    mainItem = item;
    localType = type;
    var callbackMethod = type == "detail" ? "getDetailLayout" : "getEditLayout";
    var mapLayout = type == "detail" ? mapDetailLayout : mapEditLayout;
    
    if(LayoutManager.getLayout(entity+recordTypeId,type) == null) {
        SyncCallPlugin.nativeFunction([entity,recordTypeId,callbackMethod,type,recordIndex],null,null,"getLayout");
    }else {
        UITool.setupView(entity,recordTypeId,mainItem,type,recordIndex);
    }
    
};

function getDetailLayout(listLayout,index,recordTypeId){
    
    var entityName = listLayout[0]['entity'];
    var tKey = entityName+recordTypeId;
    var mapHeading = new Map ();
    var mapField = new Map();
    
    for (var x = 0; x< listLayout.length; x++) {
        var valueNames;
        if (mapField.get(listLayout[x]['heading']+'.'+listLayout[x]['label']) == null) {
            valueNames = [listLayout[x]['value']];
        }else {
            valueNames = mapField.get(listLayout[x]['heading']+'.'+listLayout[x]['label']);
            valueNames.push(listLayout[x]['value']);
        }
        var tmKey = listLayout[x]['heading']+ '.' +listLayout[x]['label']
        mapField.put (tmKey,valueNames);
        
    } 
    
    for (var x = 0; x< mapField.size(); x++) {
        var keyHead = mapField.keySet()[x];
        var headLabel = keyHead.split('.');
        if (mapHeading.get(headLabel[0]) == null) {
            var newMap = new Map();
            newMap.put (headLabel[1], mapField.get(keyHead));
            mapHeading.put (headLabel[0], newMap);
        }else {
            mapHeading.get (headLabel[0]).put(headLabel[1],mapField.get(keyHead));
        }
        
    }
    
    mapDetailLayout.put(tKey,mapHeading);
    UITool.setupView(entityName,recordTypeId,mainItem,localType,index);
    viewRelatedList(entityName,mainItem['Id']);
    
    $("#loading").hide();
    $("#block-ui").hide();
    
}              

function getEditLayout(listLayout,index,recordTypeId){
    
    var entityName = listLayout[0]['entity'];
    var tKey = entityName+recordTypeId;
    var mapInfo = new Map();
    var mapHeading = new Map ();
    var mapField = new Map();
    var isContinue = true;
    
    mapTempEditLayout.put(tKey,listLayout);
    
    for (var x = 0; x< listLayout.length; x++) {
        var valueNames;
        if (mapField.get(listLayout[x]['heading']+'.'+listLayout[x]['label']) == null) {
            valueNames = [listLayout[x]['value']];
        }else {
            valueNames = mapField.get(listLayout[x]['heading']+'.'+listLayout[x]['label']);
            valueNames.push(listLayout[x]['value']);
        }
        var tmKey = listLayout[x]['heading']+ '.' +listLayout[x]['label']
        mapField.put (tmKey,valueNames);
        mapInfo.put(listLayout[x]['value'],listLayout[x]);
        
        // retrieve piclist data
        var fieldName = listLayout[x]['value'];
        var fInfo = FieldInfoManager.getFieldInformation(entityName,fieldName,'name');
        
        if (fInfo != undefined && fInfo['type']!= undefined && (fInfo['type'] == 'picklist' || fInfo['type'] == 'combobox')) {
            if (FieldInfoManager.getPickListValues(entityName,fieldName,recordTypeId) == null) {
                isContinue = false;
                FieldInfoManager.addPickListValues(entityName+fieldName+recordTypeId,-1);
                FieldInfoManager.retreivePicklist(entityName,fieldName,fInfo['type'],recordTypeId);
            }    
        }
    } 
    
    mapEditLayoutInfo.put(tKey,mapInfo);
    
    for (var x = 0; x< mapField.size(); x++) {
        var keyHead = mapField.keySet()[x];
        var headLabel = keyHead.split('.');
        
        if (mapHeading.get(headLabel[0]) == null) {
            var newMap = new Map();
            newMap.put (headLabel[1], mapField.get(keyHead));
            mapHeading.put (headLabel[0], newMap);
        }else {
            mapHeading.get (headLabel[0]).put(headLabel[1],mapField.get(keyHead));
        }
        
    }
    
    mapEditLayout.put(tKey,mapHeading);
    localIndex = index;
    
    if (isContinue){
        UITool.setupView(entityName,recordTypeId,mainItem,localType,index); 
    }
    
}

LayoutManager.initRelatedListLayout = function(entity,type,listItem){
    
    localListData = listItem;
    var isReady = true;
    
    for(var i=0;i<localListData.length;i++){
        var tmpItem = localListData[i];
        if (mapEditLayout.get(entity+tmpItem['RecordTypeId']) == null || mapEditLayout.get(entity+tmpItem['RecordTypeId']).length == 0) {
            isReady = false;
            break;
        }   
    }
    
    if (isReady) {
        editAllDisplay (entity);
    }else {   
        for(var i=0;i<listItem.length;i++){
            var item = listItem[i];
            var recordTypeId = "012000000000000AAA";
            if (item['RecordTypeId'] != null && item['RecordTypeId'].length >0) 
                recordTypeId = item['RecordTypeId'];
            
            if (mapEditLayout.get(entity+recordTypeId) == null) {
                mapEditLayout.put(entity+recordTypeId,[]);
                SyncCallPlugin.nativeFunction([entity,recordTypeId,"getRelatedListEditLayout",type,i],null,null,"getLayout");
            }
        }
    }    
    
};

function getRelatedListEditLayout(listLayout,index,recordTypeId){
    
    var entityName = listLayout[0]['entity'];
    var tKey = entityName+recordTypeId;
    var mapInfo = new Map();
    var mapHeading = new Map ();
    var mapField = new Map();
    
    for (var x = 0; x< listLayout.length; x++) {
        var valueNames;
        if (mapField.get(listLayout[x]['heading']+'.'+listLayout[x]['label']) == null) {
            valueNames = [listLayout[x]['value']];
        }else {
            valueNames = mapField.get(listLayout[x]['heading']+'.'+listLayout[x]['label']);
            valueNames.push(listLayout[x]['value']);
        }
        var tmKey = listLayout[x]['heading']+ '.' +listLayout[x]['label']
        mapField.put (tmKey,valueNames);
        mapInfo.put(listLayout[x]['value'],listLayout[x]);
    } 
    
    mapEditLayoutInfo.put(tKey,mapInfo);
    
    for (var x = 0; x< mapField.size(); x++) {
        var keyHead = mapField.keySet()[x];
        var headLabel = keyHead.split('.');
        if (mapHeading.get(headLabel[0]) == null) {
            var newMap = new Map();
            newMap.put (headLabel[1], mapField.get(keyHead));
            mapHeading.put (headLabel[0], newMap);
        }else {
            mapHeading.get (headLabel[0]).put(headLabel[1],mapField.get(keyHead));
        }
        
    }
    
    mapEditLayout.put(tKey,mapHeading);
    
    var isReady = true;
    for(var i=0;i<localListData.length;i++){
        var tmpItem = localListData[i];
        var key = entityName + tmpItem['RecordTypeId'];
        
        if (mapEditLayout.get(key) == null || mapEditLayout.get(key).length == 0) {
            isReady = false;
            break;
        }   
    }
    if (isReady){ 
        editAllDisplay (entityName);
    }
    
}

function editAllDisplay(entityName) {
    
    $("#relatedlistContent").children().remove();
    for (var x = 0; x< localListData.length; x++) {
        var item = localListData[x];
        
        var recordTypeId = "012000000000000AAA";
        if (item['RecordTypeId'] != null && item['RecordTypeId'].length >0) recordTypeId = item['RecordTypeId'];
        
        var value = EntityManager.getTitle(entityName,item);
        if(value == undefined){
            value = "";
        }
        
        var liHead = $("<li class='ui-li-accordion-head' />");
        var a = $("<a data-role='button' />").html(value);
        liHead.append(a);
        
        $("#editDisplay").children().remove();
        UITool.setupView(entityName,recordTypeId,item,"edit",x);
        
        var liContent = $("<li />");
        var divContent = $("<div class='ui-li-accordion' />");
        
        var editContentUl = $("<ul />");
        editContentUl.addClass ("ui-listview");
        editContentUl.attr ("data-role","listview");
        
        var editContent = $("#editDisplay").html();
        editContentUl.append(editContent);
        editContentUl.css ({"margin":"0px 0px"});
        
        divContent.append(editContentUl);
        liContent.append(divContent);
        
        $("#relatedlistContent").append(liHead);
        $("#relatedlistContent").append(liContent);
        
    }
    
    $("#relatedlistContent").listview("refresh");
    
}

LayoutManager.getMainItem = function () {
    return mainItem;
}

LayoutManager.getIndex = function () {
    return localIndex;
}

LayoutManager.getPicklistName = function (entityName,recordTypeId) {
    
    var list = mapTempEditLayout.get(entityName+recordTypeId);
    var picklistNames = [];
    
    for (var x = 0; x < list.length ; x++) {
        var item = list[x];
        var fInfo = FieldInfoManager.getFieldInformation(entityName,item['value'],'name');
        
        if (fInfo!= undefined && fInfo['type']!= undefined && (fInfo['type'] == 'picklist' || fInfo['type'] == 'combobox')) {
            
            picklistNames.push (item);
            
        }
    }
    
    return picklistNames;
}

LayoutManager.getAllRelatedListEditItem = function(){
    return localListData;
}

LayoutManager.getLayout = function(key,type){
    var mapLayout = type == "detail" ? mapDetailLayout : mapEditLayout;
    return mapLayout.get(key);
}

LayoutManager.getLayoutInfo = function(key){
    return mapEditLayoutInfo.get(key);
}





