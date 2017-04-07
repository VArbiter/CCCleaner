Pod::Spec.new do |s|


  s.name         = "CCCleaner"
  s.version      = "1.0.2"
  s.summary      = "A simple cleaner to get bundle cache size and erase them from disk or/and memory ."

  s.description  = <<-DESC
            "CCCleaner is a simple cleaner to get bundle cache size and erase them from disk or/and memory ."
                   DESC

  s.homepage     = "https://github.com/VArbiter/CCCleaner"

  s.license      = "MIT"

  s.author       = { "冯明庆" => "elwinfrederick@163.com" }

  s.platform     = :ios
  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/VArbiter/CCCleaner.git", :tag => "#{s.version}" }

   s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
    s.dependency "SDWebImage"

end
