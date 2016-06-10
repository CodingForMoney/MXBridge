
if (!window.mxbridge) {
    var __UUID__ = 0;
    function UUID() {
          return  'call' + (__UUID__++) + new Date().valueOf();
    }
    var mxbridge = {
        version : "0.0.1",
        //提供一些应用信息.
        appName : undefined,
        appVersion : undefined,
        osType : undefined,
        osVersion : undefined,
        // 调用时，系统的错误码
        OK:0,
        FAILED:-1,
        PLUGIN_NOT_FOUND:-2,
        METHOD_NOT_FOUND_EXCEPTION:-3,
        PLUGIN_INIT_FAILED:-4,
        ARGUMENTS_ERROR:-5,
        UNKNOWN_ERROR:-6,
        // 在Native中打印日志，两个参数，第一个参数放字符串，第二个参数表示日志等级 @"VERBOSE",@"DEBUG",@"INFO",@"WARN",@"ERROR" 。默认为Info
        log : function (log,logLevel) {
            if (typeof logLevel == "number") {
                if (logLevel < 0 || logLevel > 4) {
                    logLevel = 2;
                }
            }else{
                logLevel = 2;
            }
            if (typeof log == "object") {
                log = JSON.stringify(log);
            };
            mxbridge.OCBridgeForJS.loggerWithLevel(log,logLevel);
            console.log(log);
        },
        // 异步调用，JS调用Native，一般建议使用异步回调，因为JS是单线程的。
        exec : function (pluginName, functionName, arguments,successCallback,failCallback) {
            if ( typeof pluginName != "string" || pluginName.length < 1) {
                ret = {errorCode:mxbridge.ARGUMENTS_ERROR,errorMsg:"未输入正确插件名"} ;
                mxbridge.log(ret);
                return ret;
            };
            if ( typeof functionName != "string" || functionName.length < 1) {
                ret = {errorCode:mxbridge.ARGUMENTS_ERROR,errorMsg:"未输入正确函数名"} ;
                mxbridge.log(ret);
                return ret;
            };
            if (arguments == null) {
                arguments = undefined;// 不能传递 null到OC中，因为undeifned会被转换为 nil ，而null 会被转换为 NSNull.
            };
            var jscall = {
                "pluginName" : pluginName,
                "functionName" : functionName,
                "arguments" : arguments,
                "callID" : UUID()
            };
            var list = {
                "success":successCallback,
                "fail":failCallback
            };
            mxbridge.JSbridgeForOC.callBackLists[jscall.callID] = list;
            mxbridge.OCBridgeForJS.callAsyn(jscall);
        },
        // 同步调用函数
        execSync : function (pluginName, functionName, arguments) {
            var ret;
            if ( typeof pluginName != "string" || pluginName.length < 1) {
                ret = {errorCode:mxbridge.ARGUMENTS_ERROR,errorMsg:"未输入正确插件名"} ;
                mxbridge.log(ret);
                return ret;
            };
            if ( typeof functionName != "string" || functionName.length < 1) {
                ret = {errorCode:mxbridge.ARGUMENTS_ERROR,errorMsg:"未输入正确函数名"} ;
                mxbridge.log(ret);
                return ret;
            };
            if (arguments == null) {
                arguments = undefined;// 不能传递 null到OC中，因为undeifned会被转换为 nil ，而null 会被转换为 NSNull.
            };
            var jscall = {
                "pluginName" : pluginName,
                "functionName" : functionName,
                "arguments" : arguments,
                "callID" : UUID()
            };
            ret = mxbridge.OCBridgeForJS.callSync(jscall);
            return ret;
        } ,
        // JS调用OC , 通过这个桥,也就是这里是一个OC对象
        OCBridgeForJS : {
            //loggerWithLevel() 打日志
            //callSync() 同步调用。 
            //callAsyn() 异步调用
        },

        // OC调用JS， 通过这个桥，所以这个桥是一个JS对象
        JSbridgeForOC : {
                    // callbacklist , 异步函数调用使用。
            callBackLists : {} ,
            // 供Native进行回调时，通过这里传回 数据
            callbackAsyn : function (callbackID,status,args) {
                // 执行异步调用，然后OC对JS的调用立即返回。
                window.setTimeout(mxbridge.JSbridgeForOC.callbackFunctionMaker(callbackID,status,args),0);
            },
            // 创建一个无参函数。
            callbackFunctionMaker : function(callbackID , status, args) {
                return function() {
                    mxbridge.JSbridgeForOC._callbackAsyn(callbackID,status,args);
                };
            },
            // 真正的回调函数.
            _callbackAsyn : function(callbackID , status ,args) {
                var callbackfuns = mxbridge.JSbridgeForOC.callBackLists[callbackID];
                if (callbackfuns) {
                    if (status == mxbridge.OK) {
                        callbackfuns.success && callbackfuns.success(args);
                    } else {
                        callbackfuns.fail && callbackfuns.fail(args);
                    }
                    delete mxbridge.JSbridgeForOC.callBackLists[callbackID];
                };
            }
        }
    };
    window.mxbridge = mxbridge;
}else {
	window.mxbridge.log("不可能出现这个问题，每次切换页面会切换context.",4);
}
