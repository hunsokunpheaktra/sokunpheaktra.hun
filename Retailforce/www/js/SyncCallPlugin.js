//
//  MyClass.js
//  testPluginStackOverflow
//
//  Created by Carlos Williams on 2/03/12.
//  Copyright (c) 2012 Devgeeks. All rights reserved.
//

var SyncCallPlugin = {

    nativeFunction: function(types, success, fail, methodName) {
        return PhoneGap.exec(success, fail, "SyncCallPlugin", methodName, types);
    }

}