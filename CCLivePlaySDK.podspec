

Pod::Spec.new do |s|


  s.name         = "CCLivePlaySDK"
  s.version      = '3.4.1'
  s.summary      = "An iOS SDK for CCLive Service"

  s.description  = <<-DESC
	It's  an iOS SDK for CCLive Service，It helps iOS developers to use CClive easier.
                   DESC
  s.homepage     = "https://github.com/CCVideo"

  s.license      = 'Apache License, Version 2.0'

  s.author             = { "CClive" => "service@bokecc.com" }

  s.platform     = :ios, "8.0"


  s.source       = { :git => "https://github.com/CCVideo/Live_iOS_Play_SDK.git", :tag => s.version.to_s }

  s.vendored_frameworks = 'SDK/Live_iOS_Play_SDK(无连麦)/*.{framework}'
 s.resource = 'SDK/Live_iOS_Play_SDK(无连麦)/socketio.html'

end
