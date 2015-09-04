
var mapRecordTypeMapping = new Map();
var recordMappingList = [];

function RecordtypeMappingManager(){
    
}

RecordtypeMappingManager.initRecordType = function(entity,item){
    if(mapRecordTypeMapping.get(entity) == null){
        SyncCallPlugin.nativeFunction([entity,"getRecordTypeMapping"],null,null,"getRecordTypeWithEntity"); 
    }else{
        drawRecordTypeChoosing(mapRecordTypeMapping.get(entity),currentItem,entity);
    }
    
};

function getRecordTypeMapping(entity,listResult){
    
    mapRecordTypeMapping.put(entity,listResult);
    drawRecordTypeChoosing(listResult,currentItem,entity);
    
}

function drawRecordTypeChoosing(listData,item,entity){
    
    if(listData.length == 0){
        currentItem['RecordTypeId'] = "012000000000000AAA";
        $("#relatedListView").css({"display":"none"});
        var backListItem = backList.pop();
        openScreen("Add",-1, entity);
        if(backListItem['pageName'] == "relatedList"){
            backList.pop();
            backList.push(backListItem);
        }else{
            backList.push(backListItem);
        }
        document.getElementById('btnEditAll').style.display = "none";
        document.getElementById('btnSave').setAttribute("onClick","saveHandler(true,'"+entity+"','012000000000000AAA');"); 
        return;
    }
    
    $("#relatedListDisplay").children().remove();
    
    for(var i=0;i<listData.length;i++){
        
        var item = listData[i];
        var defaultRecordType = item['defaultRecordTypeMapping'];
        var recordTypeId = item['recordTypeId'];
        var valueName = item['name'];
        var radioButton;
        var li = $("<li />");
        li.addClass("ui-btn ui-btn-icon-right ui-li ui-btn-up-c");
        
        var divli = $("<div />");
        divli.addClass("ui-btn-inner ui-li");
        
        var divtext = $("<div />");
        divtext.addClass("ui-btn-text");
        
        var radioButton = $("<span id='radio"+i+"' />");
        
        if(defaultRecordType == "true"){
            radioButton.addClass("ui-icon ui-icon-radio-on ui-icon-shadow");
        }else{
            radioButton.addClass("ui-icon ui-icon-radio-off ui-icon-shadow");
        }
        
        var radioId = "recordTypeRadio" + i;
        var inputHidden = $('<input type="hidden" id="'+radioId+'" value="'+recordTypeId+'" >');
        radioButton.append(inputHidden);
        
        var a = $("<a />").html(valueName);
        
        a.addClass("ui-link-inherit");
        a.css({"font-size":"15px"});
        a.attr("onClick","radioValueClick('"+radioId+"','"+entity+"')");
        
        divtext.append(a);
        divli.append(divtext);
        divli.append(radioButton);
        li.append(divli);
        
        $("#relatedListDisplay").append(li);
        
    }
    
    if(isIphoneDevice){
        
        var orientation = jQuery.event.special.orientationchange.orientation();
        
        if(orientation != "portrait"){
            document.getElementById('landing').style.marginTop = "-300px";
        }else{
            if(listData.length > 10){
                document.getElementById('landing').style.marginTop = "-500px";
            }else{
                document.getElementById('landing').style.marginTop = "-400px";
            }
        }
        
    }else{
        
        if(listData.length > 10){
            document.getElementById('landing').style.marginTop = "-940px";
        }else{
            document.getElementById('landing').style.marginTop = "-700px";
        }
        
    }
    
    document.getElementById('header').innerHTML = "Choose RecordType :";
    
    $("#landing").trigger('create');
    
    $("#block-ui").show();
    $("#landing").show();
    
}

function radioValueClick(inputId,entity){
    
    $("#block-ui").hide();
    $("#landing").hide();
    document.getElementById('relatedListView').style.display = "none";
    
    var value = document.getElementById(inputId).value;
    
    currentItem['RecordTypeId'] = value;
    var backListItem = backList.pop();
    openScreen("Add",-1, entity);
    if(backListItem['pageName'] == "relatedList"){
        backList.pop();
        backList.push(backListItem);
    }else{
        backList.push(backListItem);
    }
    document.getElementById('btnEditAll').style.display = "none";
    document.getElementById('btnSave').setAttribute("onClick","saveHandler(true,'"+entity+"','"+value+"');"); 
    
}

RecordtypeMappingManager.getRecordType = function(entity){
    return mapRecordTypeMapping.get(entity);
};
