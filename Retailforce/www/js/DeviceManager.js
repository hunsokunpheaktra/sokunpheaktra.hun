

function DeviceManager(){
    
}

DeviceManager.isiPhone = function(){
    
    var deviceName = deviceDetection();
    if(deviceName == "iPhone" || deviceName == "iPod"){
        return true;
    }else{
        return false;
    }
    
};

function deviceDetection(){
    
    var deviceType = "";
    var ua = navigator.userAgent; //Grab USER AGENT STRING
    var checker = {webOS: ua.match(/webOS/),iphone: ua.match(/iPhone/),ipad: ua.match(/iPad/),ipod: ua.match(/iPod/),blackberry: ua.match(/BlackBerry/),android: ua.match(/Android/), symbian: ua.match(/Symbian/)};
    
    //FIND PHONE OS TYPE
    if (checker.android){
        deviceType = "Android";
    }else if (checker.webOS){
        //Windows phone code here code here
        deviceType = "webOS";
    }else if (checker.iphone){
        deviceType = "iPhone";
    }else if (checker.ipad){
        //iPad code here
        deviceType = "iPad";
    }else if (checker.ipod){
        //iPod code here
        deviceType = "iPod";
    }else if (checker.blackberry){
        deviceType = "BlackBerry";
    }else if (checker.symbian){
        deviceType = "Symbian";
    }else{
        //unknown device code here
        deviceType = "Unknown";
    }
    
    return deviceType;
    
}
