Pod::Spec.new do |s|
  s.name         = "Advance"
  s.version      = "2.0.0.alpha1"
  s.summary      = "A powerful animation framework for iOS and OS X."
  s.description  = "Advance is a Swift framework that enables advanced animations and physics-based interactions."

  s.homepage     = "https://github.com/timdonnelly/Advance"

  s.license      = "BSD 2-clause \"Simplified\" License"

  s.authors      = "Tim Donnelly"
  s.social_media_url = 'http://twitter.com/timdonnelly'

  s.source       = { :git => "https://github.com/timdonnelly/Advance.git", :tag => "2.0.0.alpha1" }

  s.source_files = "Advance/**/*.swift"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "9.0"
end
