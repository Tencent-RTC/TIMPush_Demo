
Pod::Spec.new do |spec|
  spec.name         = 'TXPushSDK_IOS'
  spec.version      = '1.0.0'
  spec.platform     = :ios
  spec.ios.deployment_target = '8.0'
  spec.license      = { :type => 'Proprietary',
      :text => <<-LICENSE
        copyright 2017 tencent Ltd. All rights reserved.
        LICENSE
       }
  spec.homepage     = 'https://cloud.tencent.com/document/product/269/3794'
  spec.documentation_url = 'https://cloud.tencent.com/document/product/269/9147'
  spec.authors      = 'tencent video cloud'
  spec.summary      = 'TXPushSDK_IOS'
  
  spec.requires_arc = true

  spec.source = { :git => 'https://github.com/tencentyun/TIMSDK.git', :tag => spec.version}
  spec.preserve_paths = 'Framework/PushSDK.framework'
  spec.public_header_files = 'Framework/PushSDK.framework/Headers/*.h'
  spec.vendored_frameworks = 'Framework/PushSDK.framework'
  spec.xcconfig = {'HEADER_SEARCH_PATHS' => '${PODS_ROOT}/TXPushSDK_IOS/Framework/PushSDK.framework/Headers/'}
  
  spec.resource_bundle = {
    "#{spec.module_name}_Privacy" => 'Framework/PushSDK.framework/PrivacyInfo.xcprivacy'
  }

end
