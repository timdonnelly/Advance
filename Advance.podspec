Pod::Spec.new do |s|
  s.name         = "Advance"
  s.version      = "v2.0.0.alpha1"
  s.summary      = "A powerful animation framework for iOS and OS X."
  s.description  = "Advance is a Swift framework that enables advanced animations and physics-based interactions."

  s.homepage     = "https://github.com/timdonnelly/Advance"

  s.license      = "BSD 2-clause \"Simplified\" License"

  s.authors      = "Tim Donnelly"
  s.social_media_url = 'http://twitter.com/timdonnelly'

  s.source       = { :git => "https://github.com/timdonnelly/Advance.git", :tag => "v2.0.0.alpha1" }

  s.source_files = "Source/**/*.swift"

  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.11"
  s.tvos.deployment_target = "10.0"
end
