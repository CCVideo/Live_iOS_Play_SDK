

Pod::Spec.new do |s|


  s.name         = "CCLivePlaySDK"
  s.version      = '3.3.0'
  s.summary      = "An iOS SDK for CCLive Service"

  s.description  = <<-DESC
	It's  an iOS SDK for CCLive Service，It helps the iOS developers to use the CClive easier.
                   DESC

  s.homepage     = "https://github.com/CCVideo"

  s.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }

  s.author             = { "CClive" => "service@bokecc.com" }

  s.platform     = :ios, "8.0"


  s.source       = { :git => "https://github.com/CCVideo/Live_iOS_Play_SDK.git", :tag => s.version.to_s }

  s.vendored_frameworks = 'SDK/Live_iOS_Play_SDK(无连麦)/*.{framework}'
 s.resource = 'SDK/Live_iOS_Play_SDK(无连麦)/socketio.html'

end
