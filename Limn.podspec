Pod::Spec.new do |s|

  s.name = 'Limn'
  s.module_name = 'Limn'
  s.version = '0.9.1'
  
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'A Swift library for inspecting and comparing values in Swift and Objective-C.'
  s.homepage = 'https://github.com/diogopribeiro/Limn'
  s.author = { 'Diogo Pereira Ribeiro' => 'diogopribeiro.apps@gmail.com' }
  s.source = { :git => 'https://github.com/diogopribeiro/Limn.git', :tag => "#{s.version}" }
  s.source_files = 'Sources/**/*.swift'
  
  s.swift_versions = ['5.6']
  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.13'
  s.watchos.deployment_target = '4.0'
  s.tvos.deployment_target = '11.0'

end
