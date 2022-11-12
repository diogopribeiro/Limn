Pod::Spec.new do |s|

  s.name        = "Limn"
  s.version     = "0.1.0"
  s.summary     = "A Swift library for inspecting and comparing values in Swift and Objective-C."
  s.description = "A Swift library for inspecting and comparing values in Swift and Objective-C via reflection.
                   Limn was originally developed as a more complete and concise alternative to Swift's `dump()` and
                   over time it gained other helpful features for debugging such as support for persistence, diffing
                   and filtering of child elements."
  s.authors     = "Diogo Pereira Ribeiro"
  s.license     = { :type => 'MIT License', :file => 'LICENSE' }
  s.homepage    = "https://github.com/diogopribeiro/Limn"
  s.platforms   = { :ios => "11.0", :osx => "10.13", :watchos => "4.0", :tvos => "11.0" }

  s.source              = { :git => 'https://github.com/diogopribeiro/Limn.git', :tag => s.version }
  s.source_files        = "Sources/**/*.{h,m,mm,swift}"
  s.public_header_files = "Sources/**/*.{h}"

end
