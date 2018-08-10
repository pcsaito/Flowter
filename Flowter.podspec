Pod::Spec.new do |s|

  s.name         = "Flowter"
  s.version      = "0.2"
  s.summary      = "A lightweight and customizable UIViewController flow cordinator"
  s.description  = "A lightweight, swifty and customizable UIViewController flow cordinators"

  s.homepage     = "https://www.zazcar.com.br"
  s.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author             = { "Paulo Cesar Saito" => "paulocsaito@gmail.com" }

  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/Zazcar/Flowter.git", :tag => "v#{s.version}" }
  s.source_files = 'Flowter/Source/*.swift'
  s.exclude_files = 'FlowterDemo'
    
  s.requires_arc = true

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"
  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"

end
