Pod::Spec.new do |spec|

  spec.name         = "Flowter"
  spec.version      = "0.2"
  spec.summary      = "A lightweight and customizable UIViewController flow cordinator"
  spec.description  = "A lightweight, swifty and customizable UIViewController flow cordinators"

  spec.homepage     = "https://www.zazcar.com.br"
  spec.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  spec.author             = { "Paulo Cesar Saito" => "paulocsaito@gmail.com" }

  spec.platform     = :ios, "9.0"
  spec.source       = { :git => "https://github.com/Zazcar/Flowter.git", :tag => "v#{spec.version}" }
  spec.source_files  = "Flowter"

  # spec.resource  = "icon.png"
  # spec.resources = "Resources/*.png"
  # spec.preserve_paths = "FilesToSave", "MoreFilesToSave"

end
