Pod::Spec.new do |s|
  s.name         = "Advance"
  s.version      = "3.1.1"
  s.summary      = "Physics-based animations for iOS, tvOS, and macOS."
  s.description  = "Advance is a Swift framework that enables advanced animations and physics-based interactions."

  s.homepage     = "https://github.com/timdonnelly/Advance"

  s.license      = "BSD 2-clause \"Simplified\" License"

  s.authors      = "Tim Donnelly"
  s.social_media_url = 'http://twitter.com/timdonnelly'

  s.source       = { :git => "https://github.com/timdonnelly/Advance.git", :tag => "3.1.1" }

  s.source_files = "Sources/Advance/**/*.swift"

  s.swift_version = '5.0'

  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.12"
  s.tvos.deployment_target = "10.0"

end
