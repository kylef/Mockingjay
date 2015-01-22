Pod::Spec.new do |spec|
  spec.name = 'Mockingjay'
  spec.version = '0.1.0'
  spec.summary = 'Mock HTTP requests with ease.'
  spec.homepage = 'https://github.com/kylef/Mockingjay'
  spec.license = { :type => 'BSD', :file => 'LICENSE' }
  spec.author = { 'Kyle Fuller' => 'inbox@kylefuller.co.uk' }
  spec.social_media_url = 'http://twitter.com/kylefuller'
  spec.source = { :git => 'https://github.com/kylef/Mockingjay.swift.git', :tag => "#{spec.version}" }
  spec.source_files = 'Mockingjay/*.{h,swift}'
  spec.ios.deployment_target = '8.0'
  spec.osx.deployment_target = '10.9'
  spec.requires_arc = true
end

