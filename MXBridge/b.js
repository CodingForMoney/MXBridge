
if (!window.plus) {
    // 一个webview 有一个window ，有一个plus。
    function stringify(a) {
        return window.JSON3 ? window.JSON3.stringify(a) :JSON.stringify(a);
    }
    var __UUID__ = 0;
    function UUID() {
        return  'call' + (__UUID__++) + new Date().valueOf();
    }
    var plus = {
        version : "0.0.2", // 修改回调时删除记录的操作.
        //提供一些应用信息.
        appName : undefined,
        appVersion : undefined,
        osType : undefined,
        osVersion : undefined,
        // JS通过这个桥来调用Native。 这边只是接口，并没有真正与Native交互
        bridge : {
        OK:0,
        NO_RESULT:10001,
        PLUGIN_NOT_FOUND:10002,
        CLASS_NOT_FOUND_EXCEPTION:10003,
        PLUGIN_INIT_FAILED:10004,
        INVALID_ACTION:10005,
        JSON_EXCEPTION:10006,
        UNKNOWN_ERROR:10007,
        ERROR:10008,
            // 在Native中打印日志，两个参数，第一个参数放字符串，第二个参数表示日志等级 @"VERBOSE",@"DEBUG",@"INFO",@"WARN",@"ERROR" 。默认为Info
            log : function (log,logLevel) {
                if (typeof logLevel == "number") {
                    if (logLevel < 0 || logLevel > 4) {
                        logLevel = 2;
                    }
                }else{
                    logLevel = 2;
                }
                if(typeof log == "string") {
                    
                }else if (typeof log == "object") {
                    log = stringify(log);
                };
                plus.OCBridgeForJS.loggerWithLevel(log,logLevel);
                console.log(log);
            },
            // 异步调用，JS调用Native，一般建议使用异步回调，因为JS是单线程的。
            exec : function (pluginName, functionName, args) {
                if ( typeof pluginName != "string" || pluginName.length < 1) {
                    ret = {errorCode:plus.bridge.JSON_EXCEPTION,errorMsg:"未输入正确插件名"} ;
                    plus.bridge.log(ret);
                    return ret;
                };
                if ( typeof functionName != "string" || functionName.length < 1) {
                    ret = {errorCode:plus.bridge.JSON_EXCEPTION,errorMsg:"未输入正确函数名"} ;
                    plus.bridge.log(ret);
                    return ret;
                };
                if (args == null) {
                    args = undefined;// 不能传递 null到OC中，因为undeifned会被转换为 nil ，而null 会被转换为 NSNull.
                };
                var jscall = {
                    "pluginName" : pluginName,
                    "functionName" : functionName,
                    "arguments" : args
                };
                if(args instanceof Array && args.length > 0) {
                    jscall["callID"] = args[0];
                }else {
                    jscall["callID"] = UUID();
                }
                plus.OCBridgeForJS.callAsyn(jscall);
            },
            // 同步调用函数
            execSync : function (pluginName, functionName, args) {
                var ret;
                if ( typeof pluginName != "string" || pluginName.length < 1) {
                    ret = {errorCode:plus.bridge.JSON_EXCEPTION,errorMsg:"未输入正确插件名"} ;
                    plus.bridge.log(ret);
                    return ret;
                };
                if ( typeof functionName != "string" || functionName.length < 1) {
                    ret = {errorCode:plus.bridge.JSON_EXCEPTION,errorMsg:"未输入正确函数名"} ;
                    plus.bridge.log(ret);
                    return ret;
                };
                if (args == null) {
                    args = undefined;// 不能传递 null到OC中，因为undeifned会被转换为 nil ，而null 会被转换为 NSNull.
                };
                var jscall = {
                    "pluginName" : pluginName,
                    "functionName" : functionName,
                    "arguments" : args,
                    "callID" : UUID()
                };
                ret = plus.OCBridgeForJS.callSync(jscall);
                return ret;
            } ,
            //本地保存 callbackID。
        callbackId:function(success, fail) {
            var id = UUID();
            var list = {
                "success":success,
                "fail":fail
            };
            plus.JSbridgeForOC.callBackLists[id] = list;
            return id;
        }
        },
        
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
                window.setTimeout(function() {
                                  plus.JSbridgeForOC._callbackAsyn(callbackID,status,args);
                                  },0);
            },
            // 真正的回调函数.
            _callbackAsyn : function(callbackID , status ,args) {
                var callbackfuns = plus.JSbridgeForOC.callBackLists[callbackID];
                if (callbackfuns) {
                    if (status == plus.bridge.OK) {
                        callbackfuns.success && callbackfuns.success(args);
                    } else {
                        callbackfuns.fail && callbackfuns.fail(args);
                    }
//                    delete plus.JSbridgeForOC.callBackLists[callbackID];// 不再删除记录,每个都是唯一的.
                };
            }
        }
    };
    
    // 页面未加载，已经有window和document。
    window.plus = plus;
    // 安全键盘中需要， 不合理。
    window.callbacks = plus.JSbridgeForOC.callBackLists;
}

