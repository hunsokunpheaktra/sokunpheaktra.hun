
var mapDatas = new Map();
var isRefresh;

function EntityManager(){
    
}

EntityManager.initData = function(entity){
    
    SyncCallPlugin.nativeFunction([entity,"initDataCallBack"],null,null,"initData"); 
    
};

function initDataCallBack(entity,result){
    
    mapDatas.put(entity,result);
    
    if(entity == "Survey__c"){
        update_list(entity,result);
    }
    
};

EntityManager.getData = function(entity){
    return mapDatas.get(entity);
};
    
EntityManager.addListData = function(entity,listDatas){
    mapDatas.put(entity,listDatas);
};

EntityManager.refreshData = function(entity,isFromSave){
    isRefresh = isFromSave;
    SyncCallPlugin.nativeFunction([entity,"refreshDataCallBack"],null,null,"initData"); 
    
};

function refreshDataCallBack(entity,result){
    
    mapDatas.put(entity,result);
    
    if(isRefresh){
        goBack();
    }else{
        update_list(entity,result);
    }
    
};

EntityManager.updateData = function(entity,item){
    SyncCallPlugin.nativeFunction([entity,item],null,null,"update");
};

EntityManager.insertData = function(entity,item){
    SyncCallPlugin.nativeFunction([entity,item],null,null,"insert");
};

EntityManager.getTitle = function(entity,item){
    if(entity == "Event" || entity == "Case" || entity == "Task"){ 
        return item.Subject;
    }else if (entity == "Contract"){
        return item.ContractNumber;
    }else{
        return item.Name;
    }
    
};












