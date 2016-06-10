Pod::Spec.new do |s|
  s.name         = "MXBridge"
  s.version      = "0.1"
  s.summary      = "a easy way for javaScript to call Objective-C in iOS"
  s.homepage     = "https://github.com/CodingForMoney/MXBridge"
  s.license      = { :type => "MIT"}
  s.author       = { "luoxianming" => "luoxianmingg@gmail.com" }
  s.ios.deployment_target = '7.0'
  s.source       = { :git => "https://github.com/CodingForMoney/MXBridge.git", :tag => s.version}
  s.weak_framework = "JavaScriptCore"
  s.source_files = "MXBridge/*.{h,m}"
  s.resources    = "MXBridge/bridgeJS.js"
end