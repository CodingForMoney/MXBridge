Pod::Spec.new do |s|
  s.name         = "MXBridge"
  s.version      = "0.2"
  s.summary      = "Bridge betweeen iOS and JavaScript"
  s.homepage     = "https://github.com/CodingForMoney/MXBridge"
  s.license      = { :type => "MIT"}
  s.author       = { "luoxianming" => "luoxianmingg@gmail.com" }
  s.ios.deployment_target = '7.0'
  s.source       = { :git => "https://github.com/CodingForMoney/MXBridge.git", :tag => s.version}
  s.weak_framework = "JavaScriptCore"
  s.source_files = "MXBridge/*.{h,m}"
  s.resources    = "MXBridge/bridgeJS.js"
end