
function UITool(){
    
}

UITool.setupView = function(entityName,recordTypeId,item,type,recordIndex){
    
    if(type == "detail"){
        createDetailView(entityName,recordTypeId,item,recordIndex);
    }else{
        createEditView(type,entityName,recordTypeId,item,recordIndex);
    }
    
};

function createDetailView(entityName,recordTypeId,item,recordIndex){

    $("#detailDisplay").children().remove();
    var mapHeading = LayoutManager.getLayout(entityName + recordTypeId,"detail");
    
    for (var m =0;m < mapHeading.size() ; m++) {
        var heading  = mapHeading.keySet()[m];
        var liDivider = $("<li />").html(heading);
        
        liDivider.addClass ("ui-li ui-li-divider ui-bar-d");
        
        if(isIphoneDevice){
            liDivider.css({"font-size":"11pt"});
        }
        
        $("#detailDisplay").append (liDivider);
        
        var tmpMapLayout = mapHeading.get(heading);        
        
        for (var x =0 ; x < tmpMapLayout.size() ; x++)  {
            var name = tmpMapLayout.keySet()[x];
            if (name.length >0){
                
                var fieldNames = tmpMapLayout.get(name);
                var labelF = $("<label />").html(name);
                labelF.addClass("ui-block-a");
                labelF.css({"width" : "25%","height":"30px","padding-top":"1px","text-align":"right","color":"#466aa1","font-weight":"bold","font-size":"9pt","margin-left":"-14px"});
                
                var labelS = $("<label />");
                labelS.addClass("ui-block-b");
                labelS.css({"width" : "3%"});
                
                var li = $("<li />");
                li.addClass("ui-grid-b ui-li ui-li-static ui-body-c");
                li.css({"height":"35px"});
            
                if(type == "textarea") li.css({"height" : "70px"});
                
                li.append(labelF);
                li.append(labelS);
                
                var span = $("<span />");
                span.addClass("ui-block-c");
                span.css({"width" : "72%","border-style":"solid"});
                
                if(isIphoneDevice){
                    labelS.css({"width" : "4%"});
                    labelF.css({"width" : "40%"});
                    span.css({"width" : "56%"});
                    
                    if(name.length > 20){
                        li.css({"height" : "45px"});
                    }else{
                        li.css({"height" : "25px"});
                    }
                    
                }

                var tmpValue = '';
                var type,isReferenceFind = false;
                
                for (var y=0;y < fieldNames.length ; y++) {
                    var valueName;

                    if (item[fieldNames[y]] == undefined) {                        
                        if ($.trim(fieldNames[y]) == ',') valueName = ", ";
                        else valueName = " ";
                    }else {
                        valueName =  item[fieldNames[y]];
                        var refName,refInfo;
                        var fInfo = FieldInfoManager.getFieldInformation(entityName,fieldNames[y],'name');
                        type = fInfo['type'];
                        refName = fInfo['referenceTo'];

                        if (type == "date" || type == "datetime") {
                            
                            if (type == "datetime") {
                                var date = new Date(valueName);
                                valueName = dateFormat(date, "dd/mm/yyyy hh:MM TT","UTC:yyyy-mm-dd'T'HH:MM:ss'Z'");
                            }else {
                                var dateString = valueName.split('-');
                                var date = new Date(dateString[0],dateString[1],dateString[2]);
                                valueName = dateFormat(date, "mmm d, yyyy");
                            }
                            
                        }else if (type == "reference") {
                            
                            if (FieldInfoManager.getReferenceName(refName,valueName) != -1) {                                                                                   
                                
                                var tmpMap  = FieldInfoManager.getReferenceName(refName,valueName);
                                valueName = tmpMap.get('item')['Name'];
                                refInfo = tmpMap.get('info');
                                isReferenceFind = true;
                            }
                        }
            
                    }  

                    tmpValue = tmpValue + valueName;
                    
                    var labelN = $("<label />").html(valueName);
                    labelN.css({"font-size":"9pt","padding-top":"2px"});
                    
                    if(type == "reference" && isReferenceFind){
                        labelN.css({"border-bottom":"1px solid","color":"blue","width":"auto"});
                        labelN.attr ("onClick","oneToOneRelationShipClickHandler('"+entityName+"','"+refInfo[0]+"','"+refInfo[1]+"','"+currentIndex+"')");
                    }
                    
                    if(type == "boolean"){
                        labelN = $("<input type='checkbox' />");
                        labelN.attr("id",fieldNames[y]);
                        labelN.attr("onClick","detailCheckBoxClickHandler('"+valueName+"','"+fieldNames[y]+"')");
                        if(valueName == 'true'){
                            labelN.attr("checked","checked");
                        }
                    }
                    
                    span.append (labelN);
                    tmpValue = $.trim(tmpValue);
                    if (tmpValue == ",") tmpValue = '';
                    
                }
                
                if (tmpValue.length >0) li.append (span);
                $("#detailDisplay").append (li);
                
            }
            
        }
        
    }

}

function detailCheckBoxClickHandler(value,checkboxId){
    if (value == true) {
        $('#'+checkboxId).attr("checked","checked");
    }else { 
        $('#'+checkboxId).removeAttr("checked");
    }
    
}

function showImage(){
    
    $("#block-ui").show();
    $("#previewForm").show();
    document.getElementById('previewImage').src = document.getElementById('smallImage').src;
    
}

function createEditView(type,entityName,recordTypeId,item,recordIndex){
    
    var mapHeading = LayoutManager.getLayout(entityName + recordTypeId,"edit");
    
    if(type == "edit"){
    
        var photoDivider = $("<li />").html("Photo");
        photoDivider.addClass ("ui-li ui-li-divider ui-bar-d");
        photoDivider.css({"font-size":"11pt"});
        
        var liPhoto = $("<li />");
        liPhoto.css({"height":"45px"});
        //liPhoto.attr ("onClick","capturePhoto('"+item['Id']+"');");
        
        var aCapture = $("<a/>");
        aCapture.addClass("ui-btn");
        aCapture.attr ("id","cameraCapture");
        aCapture.css ({"width":"100%","height":"45px","margin-left":"-1px","margin-top":"1px"});
        
        var bigSpan = $("<span />");
        bigSpan.addClass("ui-btn-inner ui-grid-a");
        bigSpan.css ({"margin-top":"10px","height":"25px"});
        
        var spanTitle = $("<span />").html("Capture photo");
        spanTitle.addClass("ui-btn-text ui-block-a");
        spanTitle.css ({"text-align":"right","font-weight":"bold","font-size":"11pt","margin-left":"10%"});
        
        var spanImage = $("<span />").append("<img src='camera.png' width='25px' height='25px'/>");
        spanImage.attr ("onClick","capturePhoto('"+item['Id']+"');");
        spanImage.addClass ("ui-btn-inner ui-btn-icon-notext ui-block-b");
        spanImage.css({"margin-top":"-30px","margin-left":"56%","width":"10px"});

        var imageDisplay = $("<img id='smallImage' width='35px' height='35px' />");
        imageDisplay.attr("onClick","showImage()");
        imageDisplay.css({"display":"none","margin-left":"90%","margin-top":"-8px"});
        
        bigSpan.append (spanTitle);
        bigSpan.append (spanImage);
        bigSpan.append (imageDisplay);
        
        liPhoto.append(bigSpan);

        $("#editDisplay").append (photoDivider);
        $("#editDisplay").append (liPhoto);
    }
    
    for (var m =0 ; m < mapHeading.size() ; m++) {
        
        var heading  = mapHeading.keySet()[m];
        var liDivider = $("<li />").html(heading);
    
        liDivider.addClass ("ui-li ui-li-divider ui-bar-d");
        liDivider.attr ("data-role","list-divider");  
        
        if(isIphoneDevice){
            liDivider.css({"font-size":"11pt"});
        }
        
        $("#editDisplay").append (liDivider);
        var tmpMapLayout = mapHeading.get(heading);
        for (var x =0 ; x < tmpMapLayout.size() ; x++) {
            
            var name = tmpMapLayout.keySet()[x];
            var fieldNames = tmpMapLayout.get(name);
            // field name
            var labelFieldName = $("<label />").html(name);
            labelFieldName.addClass("ui-block-a");
            labelFieldName.css({"width" : "35%","text-align":"right","margin-left":"-14px","margin-top":"8px","font-size":"9pt","color":"#466aa1"});
            
            // space between field name and value
            var labelS = $("<label />").html("");
            labelS.addClass("ui-block-b");
            labelS.css({"width" : "2%"});
            
            // add field Name and space to table row
            var li = $("<li />").html(labelFieldName);
            li.append (labelS);
            
            // table for containing components
            var table = $("<table />");
            table.css({"width":"68%","margin-top":"0px","height":"30px"});
            table.addClass("ui-block-c");
            
            // tr for components in a row
            var tr = $("<tr />");
            tr.css ({"width":"100%"});
            
            if (name.length >0) {
                for (var y=0;y < fieldNames.length ; y++) {
                    
                    var tmpValue,refName,fInfo;
                    var component,displayId,type,controlId,holderText;
                    
                    if (item[fieldNames[y]] == undefined) tmpValue = '';                    
                    else tmpValue = item[fieldNames[y]];
                    
                    fInfo = FieldInfoManager.getFieldInformation(entityName,fieldNames[y],'name');
                    holderText = name;
                    type = fInfo['type'];
                    refName = fInfo['referenceTo'];
                    
                    var mapLayoutInfo = LayoutManager.getLayoutInfo(entityName + recordTypeId);
                    var layoutItem = mapLayoutInfo.get(fieldNames[y]);
                    
                    // create required sign for required field
                    var labelRequired = $("<td />").html("");
                    var idRequired = "fieldRequire"+fieldNames[y]+recordIndex;
                    labelRequired.attr ("id",idRequired);
                    if(isIphoneDevice){
                        labelRequired.css({"width" : "2px"});
                    }else{
                        labelRequired.css({"width" : "1%"});
                    }
                    
                    if(layoutItem["required"] == 'true'){
                        labelRequired.css({"background-color" : "red"});
                    }
                    
                    // add required field to table row
                    tr.append(labelRequired);
                    
                    // component Id to get value changed
                    controlId = fieldNames[y] + recordIndex;// + x;
                    
                    // component containing control
                    component = $("<td />");
                    component.css({"height" : "30px","margin-top":"0px"});
                    
                    //get control correspond to field type
                    var control = getControlWithType(recordIndex,entityName,type,tmpValue,controlId,fieldNames[0],entityName, recordTypeId,layoutItem["editable"],holderText,tr,refName,labelRequired);
                    
                    if(isIphoneDevice){
                        control.css({"font-size" : "10pt"});
                    }else{
                        control.css({"font-size" : "12pt"});
                    }
                    // add control to component
                    component.append (control);
                    // add component to table row
                    tr.append(component);
                }
                
                // add row to table
                table.append (tr);   
                
                // add table to 
                li.append (table);
                
                li.addClass("ui-grid-b ui-li ui-li-static ui-body-c");
                // add li to container of editview
                $("#editDisplay").append (li);
                
                if(name.length > 15){
                    li.css({"height" : "50px"});
                }else{
                    li.css({"height" : "35px"});
                }
                
                if(type == "textarea"){
                    li.css({"height" : "70px"});
                }
                
            }
            
        }
        
    }
      
}

function getControlWithType(recordIndex,entity,type,valueName,controlId,fieldName,entity,recordTypeId,isEdit,holderText,parent,refName,labelRequired){

    var control,height="23px";
    //field can edit in layout
    if(isEdit == 'true'){
        switch(type){
        
            //checkbox
            case "boolean":{
                control = $("<input type='checkbox' id='"+controlId+"' />").html("");
                if(valueName == 'true'){
                    control.attr("checked","checked");
                }
                
                if(recordIndex <= -1){
                    currentItem[fieldName] = "false";
                }
                control.attr("onClick","checkboxChangeHandler("+recordIndex+",'"+fieldName+"','"+controlId+"')");
                break;
                
            }
                
            //datetime picker   
            case "date":
            case "datetime":{
                control = $("<input type='"+type+"' id='"+controlId+"' data-role='datebox'\" />");
                control.attr("onfocusout","dateTimeChangeHandler("+recordIndex+",'"+fieldName+"','"+controlId+"','"+type+"')");
                
                if (valueName == null || valueName.length == 0 || valueName == undefined) {
                    var date = new Date();
                    if (type == 'date') valueName = dateFormat(date,"yyyy-mm-dd");
                    else if (type == 'datetime') valueName = dateFormat(date,"UTC:yyyy-mm-dd'T'HH:MM:ss'Z'"); 
                }
                
                currentItem[fieldName] = valueName;
                control.attr ('value',valueName);
                control.css({"width":"149px"});
                height="30px";
                break;
                
            }
                
            //combobox
            case "picklist":
            case "combobox":
            case "reference":{
                
                if(type == "picklist"){
                    
                    var option = $("<option value='' />").html("--None--");
                    control =  $("<select id='"+controlId+"' />").html("");
                    control.attr("onChange","picklistAndReferenceChangeHandler("+recordIndex+",'"+ entity+"','"+fieldName+"','"+controlId+"','"+[]+"')");
                    control.append(option);
                    control.css ({"width" : "100%"});
                    height="32px";
                    
                    var picklistValues = FieldInfoManager.getPickListValues(entity,fieldName, recordTypeId); // controllerName+recordIndex
                    var tm = FieldInfoManager.getFieldInformation(entity,fieldName,'name');
                    var mapPicklistConval;
                    var isDepend = false;
                    
                    if (tm['controllerName'] == undefined) {
                        
                        var listDepend = FieldInfoManager.getListDependPicklist(entity,fieldName);
                        if (listDepend.length > 0) {
                            control.removeAttr("onChange");
                            control.attr("onChange","picklistAndReferenceChangeHandler("+recordIndex+",'"+ entity+"','"+fieldName+"','"+controlId+"','"+listDepend+"')");
                        }   
                        
                    }else {
                        
                        var controllerVal = document.getElementById(tm['controllerName']+recordIndex).value;
                        mapPicklistConval = CascadingPickist.getMapCascad(entity+fieldName+tm['controllerName']);
                        picklistValues = mapPicklistConval.get(controllerVal);
                        
                        isDepend = true;
                        
                    }
                    
                    if (picklistValues == null) {
                        control.attr ('disabled','disabled'); 
                        labelRequired.css ({"background-color":""});

                    }else {
    
                        for(var i=0;i<picklistValues.length;i++){
                            var value = isDepend ? picklistValues[i] : picklistValues[i]['label'];
                            if (((valueName == undefined || valueName.length == 0 || valueName == null) &&  picklistValues[i]['defaultValue']== 'true') || valueName == value) 
                            {
                                
                                if(recordIndex > -1){
                                    currentList[recordIndex][fieldName] = value;
                                }else{
                                    currentItem[fieldName] = value;
                                }
                                option = $("<option value='"+value+"' selected='selected' />").html(value);
                                
                            } else {
                                option = $("<option value='"+value+"' />").html(value);
                            }    
                            
                            control.append(option);
                            
                        }        
                    }
                   
        
                }else if(type == "combobox"){
                        
                    control = $("<a>");
                    control.addClass("ui-btn ui-shadow ui-btn-icon-notext ui-btn-up-c");
                    control.attr("onClick","openComboBox("+recordIndex+",'"+controlId+"','"+holderText+"','"+fieldName+"')");
                  
                    var span = $("<span class='ui-btn-inner' />").append("<span style='margin:0px 0px 0px 3px' class='ui-icon ui-icon-search ui-icon-shadow' />");
                    var picklistValues = FieldInfoManager.getPickListValues(entity,fieldName, recordTypeId);
                    
                    control.append(span);
                    
                    mapRelatedListValue.put(controlId,picklistValues);
                    
                    var textId = "textInput" + "." + controlId;
                    var tmTd = $("<td/>").append("<input id='"+textId+"' onChange=comboTextChange("+recordIndex+",'"+textId+"','"+fieldName+"') type='text' value='"+valueName+"' id='"+textId+"'  style='width:90%;height:20px;font-size:10pt;' placeholder='"+holderText+"' />");
                    
                    parent.append(tmTd);
                    
                }else{
                    
                    var keyPrefix;
                    var findRef;
                    
                    if (valueName != null && valueName.length > 0) {
                        keyPrefix = valueName.substr(0,3);
                    }
                
                    if (keyPrefix != null) {
                        findRef = EntityInfoManager.findEntityInfo(keyPrefix)['name'];
                    }    

                    if (keyPrefix == null || findRef == undefined) { 
                        findRef = refName;
                    }    
                    
                    var referenceValues = FieldInfoManager.getReferenceListValues(findRef);
                    
                    control = $("<a />");
                    control.addClass("ui-btn ui-shadow ui-btn-icon-notext ui-btn-up-c");
                    control.attr("onClick","openReferenceList("+recordIndex+",'"+controlId+"','"+holderText+"','"+fieldName+"','"+findRef+"')");
                    
                    var span = $("<span class='ui-btn-inner' />").append("<span style='margin-top:0px;' class='ui-icon ui-icon-search ui-icon-shadow' />");
                    
                    control.append(span);

                    if (FieldInfoManager.getReferenceName(findRef,valueName) != -1) {                                                                                    
                        valueName = FieldInfoManager.getReferenceName(findRef,valueName).get('item')['Name'];
                    }
                    
                    var tmTd = $("<td/>").append("<input type='text' readonly='readonly' value='"+valueName+"' id='referenceText"+controlId+"' style='width:90%;height:20px;font-size:10pt;' placeholder='"+holderText+"' />");
                    
                    mapRelatedListValue.put(controlId,referenceValues);
                    parent.append(tmTd);
                    height="20px";
                    
                }
                
                break;
                
            }
                
            //textarea
            case "textarea":{
                control = $("<textarea id='"+controlId+"' placeholder='"+holderText+"' />").html(valueName);
                control.attr("onChange","textChangeHandler("+recordIndex+",'"+fieldName+"','"+controlId+"')");
                control.css ({"width" : "104%"});
                height = "60px";
                break;
            }
            
            //textbox
            default:{                
                
                var inputType = "text";
                
                if(type == "url") inputType = "url";
                if(type == "phone") inputType = "tel";
                if(type == "currency" || type == "int" || type == "double") inputType = "number";
                
                control = $("<input type='"+inputType+"' value='"+valueName+"' id='"+controlId+"' placeholder='"+holderText+"' />").html(valueName);
                control.css ({"width" : "100%"});
                control.attr("onChange","textChangeHandler("+recordIndex+",'"+fieldName+"','"+controlId+"')");
                break;
            }
        }
        
    }else{
        control = $("<label />").html(valueName);
    }
 
    control.css({"height":height});
    
    return control;
    
}

////////////************ All Control Actions ***********//////////////

function comboTextChange(recordIndex,textId,fieldName){
    var valueName = document.getElementById(textId).value;
    
    if(recordIndex > -1){
        currentList[recordIndex][fieldName] = valueName;
    }else{
        currentItem[fieldName] = valueName;
    }

}

//combobox list open
function openComboBox(recordIndex,comboId,labelText,fieldName,parentId){

    $("#relatedListDisplay").children().remove();
    var listValues = mapRelatedListValue.get(comboId);
    var newItem;
    
    if(recordIndex > -1){
        newItem = currentList[recordIndex];
    }else{
        newItem = currentItem;
    }
    
    var valueName = newItem[fieldName];
    
    for(var i=0;i<listValues.length;i++){
        var obj = listValues[i];
        var radioButton;
        
        var li = $("<li />");
        li.addClass("ui-btn ui-btn-icon-right ui-li ui-btn-up-c");
        
        var divli = $("<div />");
        divli.addClass("ui-btn-inner ui-li");
        
        var divtext = $("<div />");
        divtext.addClass("ui-btn-text");
        
        var radioButton = $("<span id='radio"+i+"' />");
        if(valueName == obj["value"]){
            radioButton.addClass("ui-icon ui-icon-radio-on ui-icon-shadow");
        }else{
            radioButton.addClass("ui-icon ui-icon-radio-off ui-icon-shadow");
        }
        
        var inputHidden = $('<input type="hidden" id="radio-choice-'+i+'" value="'+obj["value"]+'" >');
        radioButton.append(inputHidden);
        
        var a = $("<a />").html(obj["label"]);
        a.addClass("ui-link-inherit");
        a.css({"font-size":"15px"});
        a.attr("onClick","radioComboValueChange("+recordIndex+",'radio-choice-"+i+"','"+fieldName+"','"+comboId+"','radio"+i+"')");
        
        divtext.append(a);
        divli.append(divtext);
        divli.append(radioButton);
        li.append(divli);
        
        $("#relatedListDisplay").append(li);        
    }
    
    document.getElementById('header').innerHTML = labelText;
    
    $("#landing").trigger('create');
    
    $("#block-ui").show();
    $("#landing").show();
}

//checkbox event handler
function checkboxChangeHandler(recordIndex,fieldName,checkboxId){
    var value = document.getElementById(checkboxId).value == "on" ? "true" : "false";
    if(recordIndex > -1){
        currentList[recordIndex][fieldName] = value;
    }else{
        currentItem[fieldName] = value;
    }
}

//radio click handler
function radioComboValueChange(recordIndex,radioId,fieldName,parentId,aId){
    var valueName = document.getElementById(radioId).value;
    
    $("#relatedListDisplay").find(".ui-icon-radio-on").removeClass().addClass("ui-icon ui-icon-radio-off ui-icon-shadow");
    $("#"+aId).find(".ui-icon").removeClass().addClass("ui-icon ui-icon-radio-on ui-icon-shadow");
    
    if(recordIndex > -1){
        currentList[recordIndex][fieldName] = valueName;
    }else{
        currentItem[fieldName] = valueName;
    }
    
    document.getElementById("textInput" + "." + parentId).value = valueName;
    
    $("#block-ui").hide();
    $("#landing").hide();
    
}

//reference list open for choose
function openReferenceList(recordIndex,controlId,labelText,fieldName,refName){
    
    $("#relatedListDisplay").children().remove();
    
    var listValues = mapRelatedListValue.get(controlId);
    var newItem;
    if(recordIndex > -1){
        newItem = currentList[recordIndex];
    }else{
        newItem = currentItem;
    }
    var valueName = newItem == null ? "" : newItem[fieldName];
    
    for(var i=0;i<listValues.length;i++){
        var obj = listValues[i];
        var radioButton;
        
        var li = $("<li />");
        li.addClass("ui-btn ui-btn-icon-right ui-li ui-btn-up-c");
        
        var divli = $("<div />");
        divli.addClass("ui-btn-inner ui-li");
        
        var divtext = $("<div />");
        divtext.addClass("ui-btn-text");
        
        var radioButton = $("<span id='radio"+i+"' />");
        if(valueName == obj.Id){
            radioButton.addClass("ui-icon ui-icon-radio-on ui-icon-shadow");
        }else{
            radioButton.addClass("ui-icon ui-icon-radio-off ui-icon-shadow");
        }
        
        var inputHidden = $('<input type="hidden" id="radio-choice-'+i+'" value="'+obj.Id+'" >');
        radioButton.append(inputHidden);
        
        var a = $("<a />").html(obj.Name);
        a.addClass("ui-link-inherit");
        a.css({"font-size":"15px"});
        a.attr("onClick","radioValueChange("+recordIndex+",'radio-choice-"+i+"','"+fieldName+"','"+controlId+"','"+refName+"','radio"+i+"')");
        
        divtext.append(a);
        divli.append(divtext);
        divli.append(radioButton);
        li.append(divli);
        
        $("#relatedListDisplay").append(li);
            
    }

    document.getElementById('header').innerHTML = labelText;
    
    $("#landing").trigger('create');
    
    $("#block-ui").show();
    $("#landing").show();
    
}

//radio button change handler
function radioValueChange(recordIndex,radioId,fieldName,parentId,refName,aId){
    
    var value = document.getElementById(radioId).value;
    
    $("#relatedListDisplay").find(".ui-icon-radio-on").removeClass().addClass("ui-icon ui-icon-radio-off ui-icon-shadow");
    $("#"+aId).find(".ui-icon").removeClass().addClass("ui-icon ui-icon-radio-on ui-icon-shadow");
    
    if(recordIndex > -1){
        currentList[recordIndex][fieldName] = value;
    }else{
        currentItem[fieldName] = value;
    }
    
    if (FieldInfoManager.getReferenceName(refName,value) != -1) {                                                                                  
        value = FieldInfoManager.getReferenceName(refName,value).get('item')['Name'];
    }

    document.getElementById('referenceText'+parentId).value = value;
    $("#block-ui").hide();
    $("#landing").hide();
}

//picklist and reference event handler
function picklistAndReferenceChangeHandler(recordIndex,entity,fieldName,picklistId,stDepend){
    
    var listDependName = stDepend.split(',');
    var value = document.getElementById(picklistId).value;
    
    if(recordIndex > -1){
        currentList[recordIndex][fieldName] = value;
    }else{
        currentItem[fieldName] = value;
    }
    
    for (var x = 0; x<listDependName.length; x++) {
        $('#'+listDependName[x]+recordIndex).children().remove();
        $('#'+'fieldRequire'+listDependName[x]+recordIndex).css ({"background-color":""});
        var mapPicklistConval = CascadingPickist.getMapCascad(entity+listDependName[x]+fieldName);
        var tmpList = mapPicklistConval.get(value);
        
        var dependVal = "";
        var option = $("<option value='' />").html("--None--");
        $('#'+listDependName[x]+recordIndex).append(option);
    
        
        if (tmpList != null) {
            $('#'+listDependName[x]+recordIndex).removeAttr("disabled");
            $('#'+'fieldRequire'+listDependName[x]+recordIndex).css ({"background-color":"red"});
            $('#'+listDependName[x]+recordIndex).append(option);
            
            for(var i=0;i<tmpList.length;i++){
                var picklistVal = tmpList[i];
                                
                if (tmpList[i]['defaultValue']== 'true') 
                {
                    option = $("<option value='"+picklistVal+"' selected='selected' />").html(picklistVal);
                    dependVal = picklistVal;
                    
                } else {
                    
                    option = $("<option value='"+picklistVal+"' />").html(picklistVal);
                }    
                
                $('#'+listDependName[x]+recordIndex).append(option);
                
            }        
        } else  $('#'+listDependName[x]+recordIndex).attr("disabled","disabled");
        
        if(recordIndex > -1){
            currentList[recordIndex][listDependName[x]] = dependVal;
        }else{
            currentItem[listDependName[x]] = dependVal;
        }

    }
    
}

//datetime picker event handler
function dateTimeChangeHandler(recordIndex,fieldName,datetimeId,type){
    var value = $('#'+datetimeId).val();
    var item;
    
    if(recordIndex > -1){
        item = currentList[recordIndex];    
    }else{
        item = currentItem;
    }
    
    if (type == 'datetime') {
        
        var date = new Date(value);
        
        if (date == undefined) {
            value = value.substr(0,value.length-1) + ':00Z';
            value = dateFormat(value,"UTC:yyyy-mm-dd'T'HH:MM:ss.'000Z'");
        }else {
            value = dateFormat(value,"UTC:yyyy-mm-dd'T'HH:MM:ss.'000Z'");
        }
    }
    
    item[fieldName] = value;

}

//textbox event handler
function textChangeHandler(recordIndex,fieldName,textbox){
    var value = document.getElementById(textbox).value;
    if(recordIndex > -1){
        currentList[recordIndex][fieldName] = value;
    }else{
        currentItem[fieldName] = value;
    }

}




