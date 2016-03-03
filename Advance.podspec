Pod::Spec.new do |s|
  s.name         = "Advance"
  s.version      = "0.9"
  s.summary      = "A powerful animation framework for iOS."
  s.description  = "Advance is a pure Swift framework that enables advanced animations and physics-based interactions."

  s.homepage     = "https://github.com/storehouse/Advance"

  s.license      = "BSD 2-clause \"Simplified\" License"

  s.author       = "Storehouse", "Tim Donnelly"
  s.social_media_url = 'http://twitter.com/storehousehq'

  s.source       = { :git => "https://github.com/storehouse/Advance.git", :tag => "0.9" }

  s.source_files = "Advance/**/*.swift"

  s.ios.deployment_target = "8.0"
end
