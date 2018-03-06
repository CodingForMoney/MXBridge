
if (!window.mxbridge) {
    var __UUID__ = 0;
    // 创建一次调用的唯一调用ID
    function UUID() {
          return  'call' + (__UUID__++) + new Date().valueOf();
    }
    var mxbridge = {
        version : "0.2.0", // 版本号
        isReady : false, // 是否初始化完成.
        //提供一些应用信息. 可自行补充其他信息
        appName : undefined,
        appVersion : undefined,
        osType : undefined,
        osVersion : undefined,
        // 调用时，系统的错误码
        OK:0, // 调用成功
        FAILED:-1, // 调用失败
        PLUGIN_NOT_FOUND:-2, // 找不到插件
        METHOD_NOT_FOUND_EXCEPTION:-3, // 找不到对应的方法
        PLUGIN_INIT_FAILED:-4, // 初始化创建失败
        ARGUMENTS_ERROR:-5, // 传递参数不合法
        UNKNOWN_ERROR:-6, // 位置错误
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
        // 异步调用，JS调用OC ， 参数是JSON对象，没有参数时，传null 或者 undefined .
        exec : function (pluginName, functionName, args , successCallback , failCallback) {
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
            if (args == null) {
                args = undefined;// 不能传递 null到OC中，因为undeifned会被转换为 nil ，而null 会被转换为 NSNull.
            };
            var jscall = {
                "pluginName" : pluginName,
                "functionName" : functionName,
                "arguments" : args,
                "invocationID" : UUID()
            };
            var list = {
                "success":successCallback,
                "fail":failCallback
            };
            mxbridge.JSbridgeForOC.callBackLists[jscall.invocationID] = list;
            mxbridge.OCBridgeForJS.callAsyn(jscall);
        },
        // 同步调用函数 . 参数是JSON对象，没有参数时，传null 或者 undefined .  返回值可以是一个string 也可以是一个object ，针对实际需求自行约定
        execSync : function (pluginName, functionName, args) {
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
            if (args == null) {
                args = undefined;// 不能传递 null到OC中，因为undeifned会被转换为 nil ，而null 会被转换为 NSNull.
            };
            var jscall = {
                "pluginName" : pluginName,
                "functionName" : functionName,
                "arguments" : args,
                "invocationID" : UUID()
            };
            ret = mxbridge.OCBridgeForJS.callSync(jscall);
            return ret;
        } ,
        // 安全模式 , 桥的调用不是同步的.
        execSafely : function (pluginName, functionName, args,successCallback,failCallback) {
            if (window.mxbridge && window.mxbridge.isReady) {
                window.mxbridge.exec(pluginName, functionName, args,successCallback,failCallback);
            } else {
                document.addEventListener("bridgeReady",  function() {
                                          window.mxbridge.exec(pluginName, functionName, args,successCallback,failCallback);
                                          }, true);
            }
        },
        // JS调用OC
        OCBridgeForJS : {
            //loggerWithLevel() 打日志
            //callSync() 同步调用。 
            //callAsyn() 异步调用
        },

        // OC调用JS
        JSbridgeForOC : {
                    // callbacklist , 异步函数调用使用。
            callBackLists : {} ,
            // 供Native进行回调时，通过这里传回 数据
            callbackAsyn : function (callbackID,status,args) {
                // 执行异步调用，然后OC对JS的调用立即返回。
                window.setTimeout(function() {
                                    mxbridge.JSbridgeForOC._callbackAsyn(callbackID,status,args);
                                  },0);
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
                    // 暂不提供 keepAlive的接口。
                    delete mxbridge.JSbridgeForOC.callBackLists[callbackID];
                };
            }
        }
    };
    window.mxbridge = mxbridge;
}
