Pod::Spec.new do |spec|

  spec.name         = "Flowter"
  spec.version      = "0.3.0"
  spec.summary      = "A lightweight and customizable UIViewController flow cordinator"
  spec.description  = "A lightweight, swifty and customizable UIViewController flow cordinators"

  spec.homepage     = "https://www.zazcar.com.br"
  spec.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  spec.author             = { "Paulo Cesar Saito" => "paulocsaito@gmail.com" }

  spec.platform     = :ios, "9.0"
  spec.requires_arc = true
  
  spec.source       = { :git => "https://github.com/Zazcar/Flowter.git", :tag => "v#{spec.version}" }
  spec.source_files = 'Flowter/Source/*.swift'
  spec.exclude_files = 'FlowterDemo'

  spec.test_spec do |test_spec|
    test_spec.dependency 'KIF'
    test_spec.requires_app_host = true
    test_spec.source_files = 'FlowterTests/*.{h,m,swift}'
    test_spec.exclude_files = 'FlowterTests/FlowterDemo*.swift'
  end
 
end
