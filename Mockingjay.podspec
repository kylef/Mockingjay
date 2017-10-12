Pod::Spec.new do |spec|
  spec.name = 'Mockingjay'
  spec.version = '2.0.2'
  spec.summary = 'An elegant library for stubbing HTTP requests with ease in Swift.'
  spec.homepage = 'https://github.com/kylef/Mockingjay'
  spec.license = { :type => 'BSD', :file => 'LICENSE' }
  spec.author = { 'Kyle Fuller' => 'kyle@fuller.li' }
  spec.social_media_url = 'http://twitter.com/kylefuller'
  spec.source = { :git => 'https://github.com/kylef/Mockingjay.git', :tag => "#{spec.version}" }
  spec.ios.deployment_target = '8.0'
  spec.osx.deployment_target = '10.9'
  spec.requires_arc = true

  spec.subspec 'Core' do |core_spec|
    core_spec.dependency 'URITemplate', '~> 2.0.2'
    core_spec.source_files = 'Sources/Mockingjay/Mockingjay.{h,swift}',
        'Sources/Mockingjay/MockingjayProtocol.swift',
        'Sources/Mockingjay/{Matchers,Builders}.swift',
        'Sources/Mockingjay/NSURLSessionConfiguration.swift',
        'Sources/Mockingjay/MockingjayURLSessionConfiguration.m'
  end

  spec.subspec 'XCTest' do |xctest_spec|
    xctest_spec.dependency 'Mockingjay/Core'
    xctest_spec.source_files = 'Sources/Mockingjay/XCTest.swift'
    xctest_spec.frameworks = 'XCTest'
    xctest_spec.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }
  end
end

