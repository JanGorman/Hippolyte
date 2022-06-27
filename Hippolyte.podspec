Pod::Spec.new do |s|

  s.name               = "Hippolyte"
  s.version            = "1.4.1"
  s.swift_version      = "5.0"
  s.summary            = "HTTP Stubbing in Swift"
                      
  s.description        = <<-DESC
                        Easily stub HTTP requests in your tests. Hippolyte makes your tests run fast and reliable without hitting the network.
                        DESC
                      
  s.homepage           = "https://github.com/JanGorman/Hippolyte"
                      
  s.license            = { :type => "MIT", :file => "LICENSE" }
                      
  s.author             = { "Jan Gorman" => "gorman.jan@gmail.com" }
  s.social_media_url   = "http://twitter.com/JanGorman"

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.13'

  s.source             = { :git => "https://github.com/JanGorman/Hippolyte.git", :tag => s.version}

  s.source_files       = "Classes", "Hippolyte/**/*.swift"

end