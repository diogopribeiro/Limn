Pod::Spec.new do |s|

  s.name        = "Limn"
  s.version     = "0.9.0"
  s.summary     = "A Swift library for inspecting and comparing values in Swift and Objective-C."
  s.description = "Limn is a Swift library for inspecting and comparing values in Swift and Objective-C. It was
                   conceived as a more concise and complete alternative to Swift's dump() and over time it gained other
                   helpful features for debugging such as support for persistence, diffing and filtering of child
                   elements."
  s.authors     = "Diogo Pereira Ribeiro"
  s.license     = { :type => 'MIT License', :file => 'LICENSE' }
  s.homepage    = "https://github.com/diogopribeiro/Limn"
  s.platforms   = { :ios => "11.0", :osx => "10.13", :watchos => "4.0", :tvos => "11.0" }

  s.source              = { :git => 'https://github.com/diogopribeiro/Limn.git', :tag => "v#{s.version}" }
  s.source_files        = "Sources/**/*.{h,m,mm,swift}"
  s.swift_versions      = ['5.6']
  s.public_header_files = "Sources/**/*.{h}"

end
