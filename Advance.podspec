Pod::Spec.new do |s|
  s.name         = "Advance"
  s.version      = "0.9.1"
  s.summary      = "A powerful animation framework for iOS and OS X."
  s.description  = "Advance is a pure Swift framework that enables advanced animations and physics-based interactions."

  s.homepage     = "https://github.com/storehouse/Advance"

  s.license      = "BSD 2-clause \"Simplified\" License"

  s.authors      = "Storehouse", "Tim Donnelly"
  s.social_media_url = 'http://twitter.com/storehousehq'

  s.source       = { :git => "https://github.com/storehouse/Advance.git", :tag => "0.9" }

  s.source_files = "Advance/**/*.swift"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "9.0"
end
